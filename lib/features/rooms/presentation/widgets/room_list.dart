import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/spaces/presentation/blocs/space_bloc.dart';
import '../blocs/room_bloc.dart';
import '../../../../core/matrix/domain/entities/matrix_entities.dart';

class RoomList extends StatelessWidget {
  const RoomList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Channels',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _showCreateRoomDialog(context),
                  icon: const Icon(Icons.add),
                  tooltip: 'Create Channel',
                ),
              ],
            ),
          ),
          
          // Room list
          Expanded(
            child: BlocListener<SpaceBloc, SpaceState>(listener: (context, state) {
              if (state is SpaceLoaded) {
                context.read<RoomBloc>().add(LoadRooms(spaceId: state.selectedSpaceId));
              }
            }, child: BlocBuilder<RoomBloc, RoomState>(
              builder: (context, state) {
                if (state is RoomLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
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
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(0x4D),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No channels yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(0xAD),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first channel',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(0x4F),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  // Group rooms by type
                  final textChannels = state.rooms.where((r) => r.type == RoomType.textChannel).toList();
                  final voiceChannels = state.rooms.where((r) => r.type == RoomType.voiceChannel).toList();
                  final directMessages = state.rooms.where((r) => r.type == RoomType.directMessage).toList();
                  
                  return ListView(
                    children: [
                      // Text channels
                      if (textChannels.isNotEmpty) ...[
                        _buildChannelCategory('Text Channels', Icons.tag),
                        ...textChannels.map((room) => _buildRoomTile(
                          context,
                          room,
                          state.selectedRoomId,
                        )),
                      ],
                      
                      // Voice channels
                      if (voiceChannels.isNotEmpty) ...[
                        _buildChannelCategory('Voice Channels', Icons.volume_up),
                        ...voiceChannels.map((room) => _buildRoomTile(
                          context,
                          room,
                          state.selectedRoomId,
                        )),
                      ],
                      
                      // Direct messages
                      if (directMessages.isNotEmpty) ...[
                        _buildChannelCategory('Direct Messages', Icons.person),
                        ...directMessages.map((room) => _buildRoomTile(
                          context,
                          room,
                          state.selectedRoomId,
                        )),
                      ],
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
                            context.read<RoomBloc>().add(LoadRooms());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),)
          ),
        ],
      ),
    );
  }

  Widget _buildChannelCategory(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomTile(BuildContext context, MatrixRoom room, String? selectedRoomId) {
    final isSelected = room.roomId == selectedRoomId;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          _getRoomIcon(room.type),
          size: 20,
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : null,
        ),
        title: Text(
          room.name ?? 'Unnamed Room',
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : null,
            fontWeight: isSelected ? FontWeight.w600 : null,
          ),
        ),
        trailing: room.unreadCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  room.unreadCount.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () {
          context.read<RoomBloc>().add(SelectRoom(room.roomId));
        },
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

  void _showCreateRoomDialog(BuildContext context) {
    final nameController = TextEditingController();
    final topicController = TextEditingController();
    RoomType selectedType = RoomType.textChannel;
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
                decoration: const InputDecoration(
                  labelText: 'Channel Type',
                ),
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
                  final selectedSpaceId = context.read<SpaceBloc>().state is SpaceLoaded
                      ? (context.read<SpaceBloc>().state as SpaceLoaded).selectedSpaceId
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