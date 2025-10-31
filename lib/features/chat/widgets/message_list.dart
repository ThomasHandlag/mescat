import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/features/chat/blocs/chat_bloc.dart';
import 'package:mescat/features/chat/widgets/message_bubble.dart';

class MessageList extends StatefulWidget {
  final List<MCMessageEvent> messages;
  final bool isLoading;

  const MessageList({
    super.key,
    required this.messages,
    this.isLoading = false,
  });

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();

  bool _isTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels == 0) {
          if (!_isTop) {
            setState(() {
              _isTop = true;
            });
          }
        } else {
          if (_isTop) {
            setState(() {
              _isTop = false;
            });
          }
        }
      }
    });
  }

  @override
  void didUpdateWidget(MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
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
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  void _loadMoreMessages() {
    context.read<ChatBloc>().add(const LoadMoreMessages());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.messages.isEmpty) {
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
              'No messages yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(0xB3),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to send a message!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(0x80),
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: widget.messages.length,
          itemBuilder: (context, index) {
            final message = widget.messages[index];
            final previousMessage = index > 0
                ? widget.messages[index - 1]
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
        if (MCEvent.endToken != null && _isTop)
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoaded) {
                    if (state.isLoadingMessages) {
                      return const CircularProgressIndicator();
                    }

                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _loadMoreMessages(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF505050),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(0x1A),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Load more messages',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(0xB3),
                                ),
                          ),
                        ),
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
}
