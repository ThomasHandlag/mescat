import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/features/chat/blocs/chat_bloc.dart';
import 'package:mescat/features/chat/widgets/chat_skeleton.dart';
import 'package:mescat/features/chat/widgets/message_input.dart';
import 'package:mescat/features/chat/widgets/message_list.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  Client get client => getIt<Client>();

  Widget _buildChatList(ChatState state, String? initEventId) {
    if (state is ChatLoaded) {
      return MessageList(messages: state.messages, initEventId: initEventId);
    } else {
      return const ChatSkeleton();
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomId = GoRouterState.of(context).pathParameters['roomId'];
    final room = roomId != null ? client.getRoomById(roomId) : null;
    if (room == null) {
      return _buildEmptyState(context, 'Select a room to start chatting');
    }
    final initEventId = GoRouterState.of(context).pathParameters['eventId'];
    final state = context.watch<ChatBloc>().state;

    return Column(
      children: [
        Expanded(child: _buildChatList(state, initEventId)),
        Padding(
          padding: const EdgeInsets.only(
            bottom: UIConstraints.mSmallPadding,
            right: UIConstraints.mSmallPadding,
            left: UIConstraints.mSmallPadding,
          ),
          child: MessageInput(room: room),
        ),
      ],
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
