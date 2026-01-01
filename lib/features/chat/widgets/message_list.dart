import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/features/chat/blocs/chat_bloc.dart';
import 'package:mescat/features/chat/widgets/message_bubble.dart';

class MessageList extends StatefulWidget {
  final List<MCMessageEvent> messages;
  final String? initEventId;

  const MessageList({super.key, required this.messages, this.initEventId});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 100,
  );

  static const _scrollThreshold = 100.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _scrollToBottom();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final isNearTop = position.pixels <= _scrollThreshold;
    if (isNearTop) {
      _loadMoreMessages();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 0),
        curve: Curves.linear,
      );
    }
  }

  void _loadMoreMessages() {
    final state = context.read<ChatBloc>().state;
    if (state is ChatLoaded && state.isLoadingMore) return;
    context.read<ChatBloc>().add(const LoadMoreMessages());
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (widget.messages.isEmpty) {
          return _buildEmptyState(
            context,
            'No messages yet. Start the conversation!',
          );
        }

        final loadMore = state is ChatLoaded && state.isLoadingMore ? const CircularProgressIndicator() : const SizedBox.shrink();

        return Stack(
          children: [
            ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: widget.messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Center(child: loadMore);
                }
                final message = widget.messages[index - 1];
                final previousMessage = index > 1
                    ? widget.messages[index - 2]
                    : null;
                final showSender =
                    previousMessage?.senderId != message.senderId ||
                    (message.timestamp
                            .difference(
                              previousMessage?.timestamp ?? DateTime.now(),
                            )
                            .inMinutes
                            .abs() >
                        5);

                return MessageBubble(message: message, showSender: showSender);
              },
            ),
          ],
        );
      },
    );
  }
}
