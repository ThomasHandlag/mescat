import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../rooms/presentation/blocs/room_bloc.dart';
import 'message_input.dart';
import 'message_list.dart';
import '../../../../core/matrix/domain/entities/matrix_entities.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomBloc, RoomState>(
      builder: (context, state) {
        if (state is RoomLoaded && state.selectedRoomId != null) {
          final selectedRoom = state.rooms.firstWhere(
            (room) => room.roomId == state.selectedRoomId,
            orElse: () => const MatrixRoom(roomId: ''),
          );
          
          if (selectedRoom.roomId.isEmpty) {
            return _buildEmptyState(context, 'Room not found');
          }
          
          return Column(
            children: [
              // Chat header
              _buildChatHeader(context, selectedRoom),
              
              // Messages
              Expanded(
                child: MessageList(
                  messages: state.messages,
                  isLoading: state.isLoadingMessages,
                ),
              ),
              
              // Message input
              MessageInput(
                roomId: selectedRoom.roomId,
                onSendMessage: (content, type) {
                  context.read<RoomBloc>().add(
                    SendMessage(
                      roomId: selectedRoom.roomId,
                      content: content,
                      type: type,
                    ),
                  );
                },
              ),
            ],
          );
        }
        
        return _buildEmptyState(context, 'Select a channel to start chatting');
      },
    );
  }

  Widget _buildChatHeader(BuildContext context, MatrixRoom room) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Room icon
          Icon(
            _getRoomIcon(room.type),
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
          
          const SizedBox(width: 12),
          
          // Room info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name ?? 'Unnamed Room',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (room.topic != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    room.topic!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          // Room actions
          Row(
            children: [
              // Member count
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    room.memberCount.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 16),
              
              // More options
              IconButton(
                onPressed: () => _showRoomOptions(context, room),
                icon: const Icon(Icons.more_vert),
                tooltip: 'Room Options',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(77),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
            ),
          ),
        ],
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

  void _showRoomOptions(BuildContext context, MatrixRoom room) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Room Info'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Show room info dialog
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(room.isMuted ? 'Unmute' : 'Mute'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Toggle mute
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Manage Members'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Show member management
            },
          ),
          if (room.type != RoomType.directMessage) ...[
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Leave Room'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show leave confirmation
              },
            ),
          ],
        ],
      ),
    );
  }
}