import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/routes/routes.dart';
import 'package:mescat/dependency_injection.dart';

import 'package:mescat/features/chat/blocs/chat_bloc.dart';
import 'package:mescat/features/rooms/widgets/invite_room.dart';
import 'package:mescat/features/settings/pages/room_setting_page.dart';
import 'package:mescat/features/rooms/widgets/expanse_channel.dart';
import 'package:mescat/features/settings/pages/space_setting_page.dart';
import 'package:mescat/features/spaces/blocs/space_bloc.dart';
import 'package:mescat/features/rooms/blocs/room_bloc.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/shared/pages/verify_device_page.dart';
import 'package:mescat/shared/util/mc_dialog.dart';

class RoomList extends StatelessWidget {
  const RoomList({super.key});

  @override
  Widget build(BuildContext context) {
    final client = getIt<Client>();
    return Container(
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
                BlocBuilder<SpaceBloc, SpaceState>(
                  builder: (context, state) {
                    if (state is SpaceLoaded) {
                      final selectedSpace =
                          state.spaces.indexWhere(
                                (space) =>
                                    space.spaceId ==
                                    state.selectedSpace?.spaceId,
                              ) !=
                              -1
                          ? state.spaces.firstWhere(
                              (space) =>
                                  space.spaceId == state.selectedSpace?.spaceId,
                            )
                          : null;

                      if (selectedSpace != null) {
                        return Text(
                          selectedSpace.name.toUpperCase(),
                          style: Theme.of(context).textTheme.titleMedium,
                        );
                      }
                    }
                    return Text(
                      'Mescat'.toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium,
                    );
                  },
                ),
                const Spacer(),
                BlocBuilder<SpaceBloc, SpaceState>(
                  builder: (context, state) {
                    if (state is SpaceLoaded) {
                      final selectedSpace =
                          state.spaces.indexWhere(
                                (space) =>
                                    space.spaceId ==
                                    state.selectedSpace?.spaceId,
                              ) !=
                              -1
                          ? state.spaces.firstWhere(
                              (space) =>
                                  space.spaceId == state.selectedSpace?.spaceId,
                            )
                          : null;

                      if (selectedSpace == null) {
                        return const SizedBox.shrink();
                      }
                      return IconButton(
                        onPressed: () {
                          showFullscreenDialog(
                            context,
                            SpaceSettingPage(room: selectedSpace.mRoom),
                          );
                        },
                        icon: const Icon(Icons.chevron_right),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),

          // Room list
          Expanded(
            child: BlocConsumer<SpaceBloc, SpaceState>(
              listener: (context, state) {
                if (state is SpaceLoaded) {
                  context.read<RoomBloc>().add(
                    LoadRooms(
                      spaceId: state.selectedSpace?.spaceId,
                      onComplete: (room) {
                        context.read<ChatBloc>().add(
                          LoadMessages(roomId: room.roomId),
                        );
                      },
                    ),
                  );
                }
              },
              builder: (context, spaceState) {
                return BlocBuilder<RoomBloc, RoomState>(
                  builder: (context, state) {
                    if (state is RoomLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is RoomLoaded) {
                      // Group rooms by type
                      final textChannels = state.rooms
                          .where((r) => r.type == RoomType.textChannel)
                          .toList();
                      final voiceChannels = state.rooms
                          .where((r) => r.type == RoomType.voiceChannel)
                          .toList();
                      final directMessages = state.rooms
                          .where((r) => r.type == RoomType.directMessage)
                          .toList();

                      return ListView(
                        children: [
                          if (spaceState is SpaceLoaded &&
                              spaceState.selectedSpace == null) ...[
                            ListTile(
                              onTap: () {},
                              leading: const Icon(Icons.store),
                              title: const Text('Store'),
                            ),
                          ],
                          if (client.isUnknownSession)
                            ListTile(
                              onTap: () => showFullscreenDialog(
                                context,
                                const VerifyDevicePage(),
                              ),
                              leading: const Icon(
                                Icons.warning,
                                color: Colors.amber,
                                size: 18,
                              ),
                              title: const Text(
                                'Verify Device',
                                style: TextStyle(
                                  color: Colors.amber,
                                  decoration: TextDecoration.underline,
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
                          if (spaceState is SpaceLoaded &&
                              spaceState.selectedSpace != null) ...[
                            // Text channels
                            _buildChannelExpansionTile(
                              'Text Channels',
                              textChannels,
                              state.selectedRoomId,
                              context,
                              RoomType.textChannel,
                            ),

                            // Voice channels
                            _buildChannelExpansionTile(
                              'Voice Channels',
                              voiceChannels,
                              state.selectedRoomId,
                              context,
                              RoomType.voiceChannel,
                            ),
                          ],

                          // Direct messages
                          if (directMessages.isNotEmpty)
                            _buildChannelExpansionTile(
                              'Direct Messages',
                              directMessages,
                              state.selectedRoomId,
                              context,
                              RoomType.directMessage,
                            ),
                        ],
                      );
                    }

                    if (state is RoomError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Error loading channels',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                context.read<RoomBloc>().add(const LoadRooms());
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelExpansionTile(
    String title,
    List<MatrixRoom> rooms,
    String? selectedRoomId,
    BuildContext context,
    RoomType roomType,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ExpanseChannel(
        title: title,
        trailing: IconButton(
          onPressed: () =>
              _showCreateRoomDialog(context, roomType: roomType, title: title),
          tooltip: 'Create $title',
          icon: Icon(
            Icons.add,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(0x99),
          ),
        ),
        children: rooms
            .map((room) => _buildRoomTile(context, room, selectedRoomId))
            .toList(),
      ),
    );
  }

  void _onSelectRoom(MatrixRoom room, BuildContext context) {
    context.read<RoomBloc>().add(SelectedRoom(room));
    if (Platform.isAndroid || Platform.isIOS) {
      context.read<ChatBloc>().add(SelectRoom(room.roomId));
    } else {
      context.go(MescatRoutes.roomRoute(room.roomId));
    }
  }

  Widget _buildRoomTile(
    BuildContext context,
    MatrixRoom room,
    String? selectedRoomId,
  ) {
    final isSelected = room.roomId == selectedRoomId;

    return GestureDetector(
      onTap: () {
        _onSelectRoom(room, context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              _getRoomIcon(room.type),
              size: 18,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurface.withAlpha(0xCC),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Tooltip(
                message: room.name,
                child: Text(
                  room.name ?? 'Unnamed Room',
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: () {
                if (Platform.isAndroid || Platform.isIOS) {
                  showFullscreenDialog(context, InviteRoom(room: room.room));
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InviteRoom(room: room.room),
                        ),
                      );
                    },
                  );
                }
              },
              icon: Icon(
                Icons.group_add,
                size: 16,
                color: isSelected
                    ? Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withAlpha(0x99)
                    : Theme.of(context).colorScheme.onSurface.withAlpha(0x66),
              ),
              tooltip: 'Invite Members',
            ),
            IconButton(
              onPressed: () {
                showFullscreenDialog(context, RoomSettingPage(room: room));
              },
              icon: Icon(
                Icons.settings,
                size: 16,
                color: isSelected
                    ? Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withAlpha(0x99)
                    : Theme.of(context).colorScheme.onSurface.withAlpha(0x66),
              ),
              tooltip: 'Channel Settings',
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRoomIcon(RoomType type) {
    switch (type) {
      case RoomType.textChannel:
        return Icons.tag;
      case RoomType.voiceChannel:
        return Icons.volume_up;
      case RoomType.directMessage:
        return Icons.person;
      case RoomType.space:
        return Icons.folder;
      case RoomType.category:
        return Icons.folder_open;
    }
  }

  void _showCreateRoomDialog(
    BuildContext context, {
    RoomType? roomType,
    String? title,
  }) {
    final nameController = TextEditingController();
    final topicController = TextEditingController();
    RoomType selectedType = roomType ?? RoomType.textChannel;
    bool isPublic = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Create ${title ?? 'Channel'}'),
          content: Scaffold(
            extendBody: Platform.isAndroid || Platform.isIOS,
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Channel Name',
                    hintText: 'general',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
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
                  subtitle: const Text('Anyone can join'),
                  value: isPublic,
                  onChanged: (value) {
                    setState(() {
                      isPublic = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final selectedSpace =
                      context.read<SpaceBloc>().state is SpaceLoaded
                      ? (context.read<SpaceBloc>().state as SpaceLoaded)
                            .selectedSpace
                      : null;
                  context.read<RoomBloc>().add(
                    CreateRoom(
                      name: nameController.text.trim(),
                      topic: topicController.text.trim().isEmpty
                          ? null
                          : topicController.text.trim(),
                      type: selectedType,
                      isPublic: isPublic,
                      parentSpaceId: selectedSpace?.spaceId,
                    ),
                  );
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
