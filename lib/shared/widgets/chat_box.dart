import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mescat/core/constants/app_constants.dart';

class ChatBox extends StatefulWidget {
  final Function(String message, List<String>? attachments)? onSendMessage;
  final Function()? onAttachFile;
  final Function()? onEmojiPicker;
  final String? placeholder;
  final bool enabled;
  final int maxLines;
  final String? channelName;

  const ChatBox({
    super.key,
    this.onSendMessage,
    this.onAttachFile,
    this.onEmojiPicker,
    this.placeholder,
    this.enabled = true,
    this.maxLines = 5,
    this.channelName,
  });

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;
  final List<String> _attachments = [];

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onMessageChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onMessageChanged);
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onMessageChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _isTyping) {
      setState(() {
        _isTyping = hasText;
      });
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty || _attachments.isNotEmpty) {
      widget.onSendMessage?.call(message, _attachments.isEmpty ? null : _attachments);
      _messageController.clear();
      _attachments.clear();
      setState(() {
        _isTyping = false;
      });
    }
  }



  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  String get _placeholderText {
    if (widget.placeholder != null) return widget.placeholder!;
    if (widget.channelName != null) {
      return 'Message #${widget.channelName}';
    }
    return 'Type a message...';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withAlpha(100),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Attachments preview
          if (_attachments.isNotEmpty) ...[
            _buildAttachmentsPreview(),
            const SizedBox(height: AppConstants.smallPadding),
          ],
          
          // Main chat input
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _focusNode.hasFocus 
                    ? colorScheme.primary.withAlpha(145)
                    : colorScheme.outline.withAlpha(100),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Attach file button
                _buildActionButton(
                  icon: Icons.add,
                  onPressed: widget.enabled ? widget.onAttachFile : null,
                  tooltip: 'Attach file',
                ),
                
                // Text input
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: widget.maxLines * 24.0,
                    ),
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      enabled: widget.enabled,
                      maxLines: null,
                      maxLength: AppConstants.maxMessageLength,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      onSubmitted: widget.enabled ? (_) => _sendMessage() : null,
                      decoration: InputDecoration(
                        hintText: _placeholderText,
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withAlpha(180),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        counterText: '', // Hide character counter
                      ),
                      style: const TextStyle(fontSize: 16),
                      onChanged: (text) {
                        // Handle typing indicator here if needed
                      },
                    ),
                  ),
                ),
                
                // Emoji button
                _buildActionButton(
                  icon: Icons.emoji_emotions_outlined,
                  onPressed: widget.enabled ? widget.onEmojiPicker : null,
                  tooltip: 'Add emoji',
                ),
                
                // Send button
                AnimatedContainer(
                  duration: AppConstants.shortAnimation,
                  child: _isTyping || _attachments.isNotEmpty
                      ? _buildSendButton()
                      : _buildMicButton(),
                ),
              ],
            ),
          ),
          
          // Character counter (when approaching limit)
          if (_messageController.text.length > AppConstants.maxMessageLength * 0.8)
            Padding(
              padding: const EdgeInsets.only(
                top: AppConstants.smallPadding,
                right: AppConstants.smallPadding,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_messageController.text.length}/${AppConstants.maxMessageLength}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _messageController.text.length >= AppConstants.maxMessageLength
                        ? colorScheme.error
                        : colorScheme.onSurface.withAlpha(180),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.all(4),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        tooltip: tooltip,
        color: colorScheme.onSurface.withAlpha(200),
        hoverColor: colorScheme.primary.withAlpha(60),
        splashRadius: 20,
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    final colorScheme = Theme.of(context).colorScheme;
    final canSend = _isTyping || _attachments.isNotEmpty;
    
    return Padding(
      padding: const EdgeInsets.all(4),
      child: IconButton(
        icon: const Icon(Icons.send_rounded, size: 20),
        onPressed: canSend && widget.enabled ? _sendMessage : null,
        tooltip: 'Send message',
        color: canSend ? colorScheme.primary : colorScheme.onSurface.withAlpha(100),
        hoverColor: colorScheme.primary.withAlpha(60),
        splashRadius: 20,
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.all(4),
      child: IconButton(
        icon: const Icon(Icons.mic, size: 20),
        onPressed: widget.enabled ? () {
          // Handle voice message recording
          HapticFeedback.lightImpact();
        } : null,
        tooltip: 'Voice message',
        color: colorScheme.onSurface.withAlpha(190),
        hoverColor: colorScheme.primary.withAlpha(60),
        splashRadius: 20,
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
      ),
    );
  }

  Widget _buildAttachmentsPreview() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withAlpha(100),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attachment,
                size: 16,
                color: colorScheme.onSurface.withAlpha(190),
              ),
              const SizedBox(width: 4),
              Text(
                'Attachments (${_attachments.length})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withAlpha(190),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Wrap(
            spacing: AppConstants.smallPadding,
            runSpacing: AppConstants.smallPadding,
            children: _attachments.asMap().entries.map((entry) {
              final index = entry.key;
              final attachment = entry.value;
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      size: 14,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      attachment.split('/').last,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _removeAttachment(index),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Extension for additional functionality
extension ChatBoxHelper on ChatBox {
  static void showEmojiPicker(BuildContext context) {
    // Implement emoji picker modal
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text('Emoji Picker - To be implemented'),
        ),
      ),
    );
  }
}