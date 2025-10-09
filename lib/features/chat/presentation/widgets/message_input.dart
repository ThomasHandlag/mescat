import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

typedef MessageSendCallback = void Function(String content, String type);

class MessageInput extends StatefulWidget {
  final String roomId;
  final MessageSendCallback onSendMessage;
  final String? channelName;

  const MessageInput({
    super.key,
    required this.roomId,
    required this.onSendMessage,
    this.channelName,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
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
      widget.onSendMessage(message, MessageTypes.Text);
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Attachments preview
          if (_attachments.isNotEmpty) ...[
            _buildAttachmentsPreview(),
            const SizedBox(height: 2),
          ],

          // Main chat input
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 97, 97, 97),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Attach file button
                _buildActionButton(
                  icon: Icons.add,
                  onPressed: () {},
                  tooltip: 'Attach file',
                ),

                // Text input
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 20 * 24.0),
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      maxLines: null,
                      maxLength: 500,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      onSubmitted: (_) => _sendMessage(),
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
                  onPressed: () {},
                  tooltip: 'Add emoji',
                ),

                // Send button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: _isTyping || _attachments.isNotEmpty
                      ? _buildSendButton()
                      : _buildMicButton(),
                ),
              ],
            ),
          ),

          // Character counter (when approaching limit)
          if (_messageController.text.length > 500 * 0.8)
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 2),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_messageController.text.length}/500',
                  style: TextStyle(
                    fontSize: 12,
                    color: _messageController.text.length >= 500
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
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
        onPressed: _sendMessage,
        tooltip: 'Send message',
        color: canSend
            ? colorScheme.primary
            : colorScheme.onSurface.withAlpha(100),
        hoverColor: colorScheme.primary.withAlpha(60),
        splashRadius: 20,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }

  Widget _buildMicButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: IconButton(
        icon: const Icon(Icons.mic, size: 20),
        onPressed: () {
          // Handle voice message recording
          // HapticFeedback.lightImpact();
        },
        tooltip: 'Voice message',
        color: colorScheme.onSurface.withAlpha(190),
        hoverColor: colorScheme.primary.withAlpha(60),
        splashRadius: 20,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }

  Widget _buildAttachmentsPreview() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withAlpha(100)),
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
          const SizedBox(height: 2),
          Wrap(
            spacing: 2,
            runSpacing: 2,
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

  void _showEmojiPicker(BuildContext context) {
    // TODO: Implement emoji picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emoji picker coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _startVoiceRecording() {
    // TODO: Implement voice recording
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice messages coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _pickImage() {
    // TODO: Implement image picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image sharing coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _pickVideo() {
    // TODO: Implement video picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video sharing coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _pickFile() {
    // TODO: Implement file picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File sharing coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareLocation() {
    // TODO: Implement location sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location sharing coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
