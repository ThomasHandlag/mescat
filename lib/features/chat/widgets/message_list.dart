import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/features/chat/blocs/chat_bloc.dart';
import 'package:mescat/features/chat/widgets/message_bubble.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MessageList extends StatefulWidget {
  final List<MCMessageEvent> messages;

  const MessageList({super.key, required this.messages});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();

  bool _isTop = false;
  DateTime? _lastLoadTime;
  static const _loadDebounceMs = 500;
  static const _scrollThreshold = 100.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    // Check if near top for showing load more button
    final isNearTop = position.pixels <= _scrollThreshold;
    if (isNearTop != _isTop) {
      setState(() {
        _isTop = isNearTop;
      });
    }

    // Auto-load when scrolling near top (if not already loading)
    if (position.pixels == 0 && _canLoadMore()) {
      _loadMoreMessages();
    }
  }

  bool _canLoadMore() {
    if (_lastLoadTime == null) return true;
    return DateTime.now().difference(_lastLoadTime!).inMilliseconds >
        _loadDebounceMs;
  }

  @override
  void didUpdateWidget(MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only auto-scroll to bottom for new messages (not when loading old ones)
    if (widget.messages.length > oldWidget.messages.length) {
      final oldCount = oldWidget.messages.length;
      final newCount = widget.messages.length;

      // Check if new messages were added at the end (not prepended)
      if (oldCount > 0 && newCount > 0) {
        final oldLastMsg = oldWidget.messages.last;
        final newLastMsg = widget.messages.last;

        if (oldLastMsg.eventId != newLastMsg.eventId) {
          // New message at the end, scroll to bottom
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        } else if (_scrollController.hasClients &&
            _scrollController.position.pixels < _scrollThreshold) {
          // Messages prepended while near top, maintain relative position
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final itemsAdded = newCount - oldCount;
            if (itemsAdded > 0 && _scrollController.hasClients) {
              // Adjust scroll to maintain visual position
              _scrollController.jumpTo(
                _scrollController.position.pixels + (itemsAdded * 80.0),
              );
            }
          });
        }
      } else if (oldCount == 0 && newCount > 0) {
        // First messages loaded, scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
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
    if (!_canLoadMore()) return;

    final state = context.read<ChatBloc>().state;
    if (state is ChatLoaded && state.isLoadingMore) return;

    setState(() {
      _lastLoadTime = DateTime.now();
    });

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
        final isInitialLoading = state is ChatLoading;

        if (isInitialLoading && widget.messages.isEmpty) {
          return Skeletonizer(
            enabled: true,
            enableSwitchAnimation: true,
            effect: ShimmerEffect(
              baseColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withAlpha(0x33),
              highlightColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withAlpha(0x66),
              duration: const Duration(milliseconds: 1800),
            ),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: 8,
              itemBuilder: (context, index) {
                final messageWidths = [
                  0.8,
                  0.6,
                  0.7,
                  0.5,
                  0.75,
                  0.65,
                  0.7,
                  0.6,
                ];
                final lineWidths = [0.9, 0.7, 0.85, 0.6, 0.8, 0.75, 0.7, 0.65];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 80 + (index * 10) % 40,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withAlpha(0xCC),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 60,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withAlpha(0x66),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...List.generate(
                              index % 3 == 0 ? 3 : (index % 2 == 0 ? 2 : 1),
                              (lineIndex) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width *
                                      (lineIndex ==
                                              (index % 3 == 0
                                                  ? 2
                                                  : (index % 2 == 0 ? 1 : 0))
                                          ? lineWidths[index %
                                                    lineWidths.length] *
                                                0.7
                                          : messageWidths[index %
                                                messageWidths.length]),
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withAlpha(0x99),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }

        if (widget.messages.isEmpty) {
          return _buildEmptyState(
            context,
            'No messages yet. Start the conversation!',
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
            if (_isTop && state is ChatLoaded && state.nextToken != null)
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: !state.hasMoreMessages
                      ? const SizedBox.shrink()
                      : state.isLoadingMore
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withAlpha(0xF0),
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: _loadMoreMessages,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  size: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Load more',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
          ],
        );
      },
    );
  }
}
