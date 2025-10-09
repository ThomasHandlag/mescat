import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'message_actions.dart';

class MessageItem extends StatefulWidget {
  final Widget child;
  final MCMessageEvent message;
  final bool isCurrentUser;
  final VoidCallback? onReply;
  final VoidCallback? onReact;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPin;
  final VoidCallback? onReport;

  const MessageItem({
    super.key,
    required this.child,
    required this.message,
    this.isCurrentUser = false,
    this.onReply,
    this.onReact,
    this.onEdit,
    this.onDelete,
    this.onPin,
    this.onReport,
  });

  @override
  State<MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  void _handleCopyMessage() {
    Clipboard.setData(ClipboardData(text: widget.message.body));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleDeleteMessage() {
    if (widget.onDelete != null) {
      widget.onDelete!();
    }
  }

  void _handlePinMessage() {
    if (widget.onPin != null) {
      widget.onPin!();
    }
  }

  void _handleReplyMessage() {
    if (widget.onReply != null) {
      widget.onReply!();
    }
  }

  void _handleReactToMessage() {
    if (widget.onReact != null) {
      widget.onReact!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
      },
      onExit: (_) {
        setState(() => _isHovered = false);
      },
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _isHovered ? const Color.fromARGB(255, 79, 79, 79) : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            widget.child,

            if (_isHovered)
              Positioned(
                top: -24,
                right: 0,
                child: MessageActions(
                  message: widget.message,
                  isCurrentUser: widget.isCurrentUser,
                  onReply: _handleReplyMessage,
                  onReact: _handleReactToMessage,
                  onEdit: widget.onEdit,
                  onDelete: _handleDeleteMessage,
                  onPin: _handlePinMessage,
                  onReport: widget.onReport,
                  onCopy: _handleCopyMessage,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
