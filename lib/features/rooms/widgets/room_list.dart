import 'dart:io';

import 'package:flutter/material.dart' hide Visibility;
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import 'package:mescat/core/constants/matrix_constants.dart';
import 'package:mescat/core/routes/routes.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/features/rooms/widgets/room_item.dart';
import 'package:mescat/features/rooms/widgets/expanse_channel.dart';
import 'package:mescat/features/settings/pages/space_setting_page.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/shared/pages/verify_device_page.dart';
import 'package:mescat/shared/util/extensions.dart';
import 'package:mescat/shared/util/mc_dialog.dart';
import 'package:mescat/shared/widgets/input_field.dart';
// import 'package:mescat/shared/util/mc_dialog.dart';

final class _Room {
  const _Room({required this.type, required this.room});

  final RoomType type;
  final Room room;
}

class RoomList extends StatelessWidget {
  const RoomList({super.key});

  Client get client => getIt<Client>();

  List<Room> getRoomsInSpace(String spaceId) {
    return client.rooms.where((room) {
      return room.spaceParents.any((space) => space.roomId == spaceId) &&
          !room.isSpace;
    }).toList();
  }

  Room? getSpace(String id) {
    try {
      return client.rooms.firstWhere((room) => room.id == id && room.isSpace);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final spaceId = GoRouterState.of(context).pathParameters['spaceId'];

    final space = spaceId != null ? getSpace(spaceId) : null;

    final bool isHome =
        GoRouterState.of(context).path == MescatRoutes.home || space == null;

    final rooms = spaceId != null
        ? getRoomsInSpace(spaceId)
        : client.rooms.where((room) => room.isDirectChat).toList();

    final textChannels = rooms
        .where((r) => r.getRoomType() == RoomType.textChannel)
        .map((r) => _Room(type: RoomType.textChannel, room: r))
        .toList();
    final voiceChannels = rooms
        .where((r) => r.getRoomType() == RoomType.voiceChannel)
        .map((r) => _Room(type: RoomType.voiceChannel, room: r))
        .toList();

    final directMessages = rooms
        .where((r) => r.isDirectChat)
        .map((r) => _Room(type: RoomType.directMessage, room: r))
        .toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(60),
            width: 0.5,
          ),
          top: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(60),
            width: 0.5,
          ),
          right: BorderSide.none,
        ),
        borderRadius: Platform.isWindows
            ? const BorderRadius.only(topLeft: Radius.circular(8))
            : null,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            height: kToolbarHeight,
            child: Row(
              children: [
                Text(
                  space != null ? (space.name) : 'Mescat',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    if (space == null) return;
                    showFullscreenDialog(
                      context,
                      SpaceSettingPage(room: space),
                    );
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),

          // Room list
          Expanded(
            child: ListView(
              children: [
                if (isHome) ...[
                  ListTile(
                    onTap: () {},
                    leading: const Icon(Icons.store),
                    title: const Text('Store'),
                  ),
                ],
                if (client.isUnknownSession)
                  ListTile(
                    onTap: () =>
                        showFullscreenDialog(context, const VerifyDevicePage()),
                    leading: Icon(
                      Icons.warning,
                      color: Theme.of(context).colorScheme.error,
                      size: 18,
                    ),
                    title: Text(
                      'Verify Device',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        showAboutDialog(
                          context: context,
                          children: [
                            const Text(
                              'Verifying your device helps keep your account secure and ensures that your communications remain private. By verifying, you confirm that this device is trusted to access your messages and data.',
                            ),
                          ],
                        );
                      },
                      icon: const Icon(Icons.help, size: 18),
                    ),
                  ),
                if (!isHome) ...[
                  // Text channels
                  _buildChannelExpansionTile(
                    'Text Channels',
                    textChannels,
                    context,
                    RoomType.textChannel,
                    spaceId!,
                  ),

                  // Voice channels
                  _buildChannelExpansionTile(
                    'Voice Channels',
                    voiceChannels,
                    context,
                    RoomType.voiceChannel,
                    spaceId,
                  ),
                ],

                // Direct messages
                if (directMessages.isNotEmpty)
                  _buildChannelExpansionTile(
                    'Direct Messages',
                    directMessages,
                    context,
                    RoomType.directMessage,
                    '',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelExpansionTile(
    String title,
    List<_Room> rooms,
    BuildContext context,
    RoomType roomType,
    String spaceID,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ExpanseChannel(
        title: title,
        trailing: IconButton(
          onPressed: () => _showCreateRoomDialog(
            context,
            roomType: roomType,
            title: title,
            spaceId: spaceID,
          ),
          tooltip: 'Create $title',
          icon: Icon(
            Icons.add,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(0x99),
          ),
        ),
        children: rooms.map((room) => _buildRoomTile(context, room)).toList(),
      ),
    );
  }

  Widget _buildRoomTile(BuildContext context, _Room room) {
    return RoomItem(room: room.room, roomType: room.type);
  }

  void _showCreateRoomDialog(
    BuildContext context, {
    RoomType? roomType,
    String? title,
    required String spaceId,
  }) {
    final nameController = TextEditingController();
    final topicController = TextEditingController();
    RoomType selectedType = roomType ?? RoomType.textChannel;
    bool isPublic = false;

    showMCAdaptiveDialog(
      context: context,
      title: Text(
        'Create ${title ?? 'Room'}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () async {
            if (nameController.text.trim().isNotEmpty) {
              final List<String> userIds = [];
              if (roomType != RoomType.directMessage && isPublic) {
                userIds.addAll(
                  (await client.getRoomById(spaceId)?.requestParticipants())!
                      .map((member) => member.id)
                      .toList()
                      .where((id) => id != client.userID),
                );
              }
              final id = await client.createRoom(
                name: nameController.text.trim(),
                creationContent: selectedType == RoomType.voiceChannel
                    ? {'type': MatrixEventTypes.msc3417}
                    : null,
                initialState: [
                  StateEvent(content: {}, type: EventTypes.GroupCallMember),
                ],
                topic: topicController.text.trim().isEmpty
                    ? null
                    : topicController.text.trim(),
                preset: isPublic
                    ? CreateRoomPreset.publicChat
                    : CreateRoomPreset.privateChat,
                invite: userIds,
                visibility: isPublic ? Visibility.public : Visibility.private,
              );

              final roomExist = (await client.getJoinedRooms()).contains(id);

              final room = client.getRoomById(id);

              if (roomExist && spaceId.isNotEmpty) {
                await client.setRoomStateWithKey(
                  spaceId,
                  EventTypes.SpaceChild,
                  id,
                  {
                    'via': [client.homeserver?.host ?? 'matrix.org'],
                    'order': DateTime.now().millisecondsSinceEpoch.toString(),
                  },
                );

                // Set the space as a parent in the room using proper Matrix client API
                await client.setRoomStateWithKey(
                  id,
                  EventTypes.SpaceParent,
                  spaceId,
                  {
                    'via': [client.homeserver?.host ?? 'matrix.org'],
                    'canonical': true,
                  },
                );

                if (roomType == RoomType.voiceChannel && room != null) {
                  await room.enableGroupCalls();
                }
              }

              Navigator.of(context).pop();
            }
          },
          child: const Text('Create'),
        ),
      ],
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InputField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Channel Name',
                hintText: 'general',
              ),
            ),
            const SizedBox(height: 16),
            InputField(
              controller: topicController,
              decoration: const InputDecoration(
                labelText: 'Topic (optional)',
                hintText: 'What\'s this channel about?',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Public Channel'),
              value: isPublic,
              onChanged: (value) {
                setState(() {
                  isPublic = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
