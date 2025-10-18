import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/features/rooms/presentation/blocs/room_bloc.dart';
import 'package:mescat/features/chat/presentation/widgets/message_input.dart';
import 'package:mescat/features/chat/presentation/widgets/message_list.dart';

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
              Expanded(
                child: MessageList(
                  messages: state.messages,
                  isLoading: state.isLoadingMessages,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: UIConstraints.smallPadding,
                  right: UIConstraints.smallPadding,
                  left: UIConstraints.smallPadding,
                ),
                child: MessageInput(
                  roomId: selectedRoom.roomId,
                  channelName: selectedRoom.name,
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
              ),
            ],
          );
        }

        return _buildEmptyState(context, 'Select a channel to start chatting');
      },
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
}
