import 'package:flutter/material.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/features/chat/presentation/widgets/message_bubble.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
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

  // void _handleSendMessage(String message, List<String>? attachments) {
  //   if (message.trim().isEmpty &&
  //       (attachments == null || attachments.isEmpty)) {
  //     return;
  //   }

  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (_scrollController.hasClients) {
  //       _scrollController.animateTo(
  //         _scrollController.position.maxScrollExtent,
  //         duration: const Duration(milliseconds: 300),
  //         curve: Curves.easeOut,
  //       );
  //     }
  //   });
  // }

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

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        final previousMessage = index > 0 ? widget.messages[index - 1] : null;
        final showSender =
            previousMessage?.senderId != message.senderId ||
            (message.timestamp
                    .difference(previousMessage?.timestamp ?? DateTime.now())
                    .inMinutes
                    .abs() >
                5);

        return MessageBubble(message: message, showSender: showSender);
      },
    );
  }
}
