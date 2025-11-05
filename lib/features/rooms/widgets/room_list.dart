import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/chat/blocs/chat_bloc.dart';
import 'package:mescat/features/chat/pages/chat_page.dart';
import 'package:mescat/features/chat/widgets/collapse_call_view.dart';
import 'package:mescat/features/rooms/pages/room_setting_page.dart';
import 'package:mescat/features/rooms/widgets/expanse_channel.dart';
import 'package:mescat/features/spaces/blocs/space_bloc.dart';
import 'package:mescat/features/rooms/blocs/room_bloc.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';
import 'package:mescat/shared/util/mc_dialog.dart';
import 'package:mescat/shared/util/widget_overlay_service.dart';

class RoomList extends StatelessWidget {
  const RoomList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              BlocBuilder<SpaceBloc, SpaceState>(
                builder: (context, state) {
                  String spaceName = 'Space Name';
                  if (state is SpaceLoaded) {
                    final selectedSpace =
                        state.spaces.indexWhere(
                              (space) => space.spaceId == state.selectedSpaceId,
                            ) !=
                            -1
                        ? state.spaces.firstWhere(
                            (space) => space.spaceId == state.selectedSpaceId,
                          )
                        : null;
                    spaceName = selectedSpace?.name ?? 'Space Name';
                  }
                  return Text(
                    spaceName,
                    style: Theme.of(context).textTheme.titleMedium,
                  );
                },
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),

        // Room list
        Expanded(
          child: BlocListener<SpaceBloc, SpaceState>(
            listener: (context, state) {
              if (state is SpaceLoaded) {
                context.read<RoomBloc>().add(
                  LoadRooms(
                    spaceId: state.selectedSpaceId,
                    onComplete: (room) {
                      context.read<ChatBloc>().add(
                        LoadMessages(roomId: room.roomId),
                      );
                    },
                  ),
                );
              }
            },
            child: BlocBuilder<RoomBloc, RoomState>(
              builder: (context, state) {
                if (state is RoomLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is RoomLoaded) {
                  if (state.rooms.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(0x4D),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No channels yet',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(0xAD),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first channel',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(0x4F),
                                ),
                          ),
                        ],
                      ),
                    );
                  }

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
                      // Text channels
                      if (textChannels.isNotEmpty)
                        _buildChannelExpansionTile(
                          'Text Channels',
                          textChannels,
                          state.selectedRoomId,
                          context,
                        ),

                      // Voice channels
                      if (voiceChannels.isNotEmpty)
                        _buildChannelExpansionTile(
                          'Voice Channels',
                          voiceChannels,
                          state.selectedRoomId,
                          context,
                        ),

                      // Direct messages
                      if (directMessages.isNotEmpty)
                        _buildChannelExpansionTile(
                          'Direct Messages',
                          directMessages,
                          state.selectedRoomId,
                          context,
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
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChannelExpansionTile(
    String title,
    List<MatrixRoom> rooms,
    String? selectedRoomId,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ExpanseChannel(
        title: title,
        trailing: GestureDetector(
          onTap: () => _showCreateRoomDialog(
            context,
            roomType: rooms.isNotEmpty ? rooms.first.type : null,
          ),
          child: Tooltip(
            message: 'Create Channel',
            child: Icon(
              Icons.add,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(0x99),
            ),
          ),
        ),
        children: rooms
            .map((room) => _buildRoomTile(context, room, selectedRoomId))
            .toList(),
      ),
    );
  }

  void _onSelectRoom(MatrixRoom room, BuildContext context) {
    context.read<RoomBloc>().add(
      SelectRoom(
        room,
        canRejoin: context.read<CallBloc>().state is! CallInProgress,
        roomType: room.type,
        showFloatWidget: () {
          final callState = context.read<CallBloc>().state;
          if (callState is CallInProgress) {
            WidgetOverlayService.show(
              context,
              onExpand: () {
                showFullscreenDialog(context, ChatPage(parentContext: context));
              },
              child: const CollapseCallView(),
            );
          }
        },
        onComplete: ({required roomId}) {
          if (room.canHaveCall) {
            if (context.read<CallBloc>().state is! CallInProgress) {
              context.read<CallBloc>().add(JoinCall(room: room.room));
            }
          } else {
            context.read<ChatBloc>().add(LoadMessages(roomId: roomId));
          }
          if (Platform.isAndroid || Platform.isIOS) {
            WidgetOverlayService.hide();
            showFullscreenDialog(context, ChatPage(parentContext: context));
          }
        },
      ),
    );
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
              onPressed: () {},
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

  void _showCreateRoomDialog(BuildContext context, {RoomType? roomType}) {
    final nameController = TextEditingController();
    final topicController = TextEditingController();
    RoomType selectedType = roomType ?? RoomType.textChannel;
    bool isPublic = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Channel'),
          content: Column(
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
              DropdownButtonFormField<RoomType>(
                initialValue: selectedType,
                decoration: const InputDecoration(labelText: 'Channel Type'),
                items: const [
                  DropdownMenuItem(
                    value: RoomType.textChannel,
                    child: Text('Text Channel'),
                  ),
                  DropdownMenuItem(
                    value: RoomType.voiceChannel,
                    child: Text('Voice Channel'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedType = value;
                    });
                  }
                },
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final selectedSpaceId =
                      context.read<SpaceBloc>().state is SpaceLoaded
                      ? (context.read<SpaceBloc>().state as SpaceLoaded)
                            .selectedSpaceId
                      : null;
                  context.read<RoomBloc>().add(
                    CreateRoom(
                      name: nameController.text.trim(),
                      topic: topicController.text.trim().isEmpty
                          ? null
                          : topicController.text.trim(),
                      type: selectedType,
                      isPublic: isPublic,
                      parentSpaceId: selectedSpaceId,
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
