import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/features/chat/presentation/widgets/chat_view.dart';
import 'package:mescat/features/members/presentation/widgets/space_members.dart';
import 'package:mescat/features/rooms/presentation/blocs/room_bloc.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  bool _showMembers = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildChatHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.push_pin)),
        IconButton(
          onPressed: () {
            setState(() {
              _showMembers = !_showMembers;
            });
          },
          icon: const Icon(Icons.group),
          tooltip: 'Room Options',
        ),
        SizedBox(
          width: 250,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.onSurface.withAlpha(20),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              isDense: true,
            ),
            onSubmitted: (value) {},
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<RoomBloc, RoomState>(
          builder: (context, state) {
            if (state is RoomLoaded && state.selectedRoomId != null) {
              final selectedRoom = state.rooms.firstWhere(
                (room) => room.roomId == state.selectedRoomId,
                orElse: () => const MatrixRoom(roomId: ''),
              );

              if (selectedRoom.roomId.isEmpty) {
                return const Text('Room not found');
              }

              return Row(
                children: [
                 const Icon(Icons.tag, size: 16),
                  Text(
                    selectedRoom.name ?? 'Unnamed Room',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              );
            }

            return const Text('Select a channel to start chatting');
          },
        ),
        actions: [_buildChatHeader(context)],
      ),
      body: Row(
        children: [
          const Expanded(child: ChatView()),
          if (_showMembers)
            Container(
              width: 250,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).dividerColor.withAlpha(50),
                  ),
                ),
              ),
              child: const SpaceMembersList(),
            ),
        ],
      ),
    );
  }
}
