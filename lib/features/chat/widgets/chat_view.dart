import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:mescat/features/chat/blocs/chat_bloc.dart';
import 'package:mescat/features/chat/widgets/chat_skeleton.dart';
import 'package:mescat/features/chat/widgets/message_input.dart';
import 'package:mescat/features/chat/widgets/message_list.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: state is ChatLoaded
                  ? MessageList(messages: state.messages)
                  : state is ChatLoading
                  ? const ChatSkeleton()
                  : _buildEmptyState(
                      context,
                      'Select a room to start chatting',
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: UIConstraints.mSmallPadding,
                right: UIConstraints.mSmallPadding,
                left: UIConstraints.mSmallPadding,
              ),
              child: state.selectedRoom != null
                  ? MessageInput(room: state.selectedRoom)
                  : const SizedBox.shrink(),
            ),
          ],
        );
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
