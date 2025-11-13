import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:mescat/features/chat/blocs/chat_bloc.dart';
import 'package:mescat/features/chat/widgets/input_action_banner.dart';
import 'package:mescat/features/chat/widgets/reaction_picker.dart';
import 'package:file_picker/file_picker.dart';

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
  int _lines = 1;

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
    final text = _messageController.text;
    setState(() {
      _lines = '\n'.allMatches(text).length + 1;
    });
    if (hasText != _isTyping) {
      if (mounted) {
        setState(() {
          _isTyping = hasText;
        });
      }
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

  void _editMessage(String eventId) {
    context.read<ChatBloc>().add(
      EditMessage(
        roomId: widget.roomId,
        eventId: eventId,
        newContent: _messageController.text.trim(),
      ),
    );
  }

  void _replyToMessage(String eventId) {
    context.read<ChatBloc>().add(
      ReplyMessage(
        roomId: widget.roomId,
        content: _messageController.text.trim(),
        replyToEventId: eventId,
      ),
    );
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
      decoration: const BoxDecoration(color: Color.fromARGB(255, 70, 70, 70)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state is ChatLoaded &&
                  state.inputAction.action != InputAction.none) {
                return InputActionBanner(
                  inputAction: state.inputAction,
                  onCancel: () {
                    context.read<ChatBloc>().add(
                      const SetInputAction(action: InputAction.none),
                    );
                    _messageController.clear();
                    _focusNode.unfocus();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
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
                  icon: Icons.attach_file_outlined,
                  onPressed: () => _pickFile(),
                  tooltip: 'Attach file',
                ),
                // Text input
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxHeight: UIConstraints.mMessageInputHeight + (10 * 16),
                    ),
                    height:
                        (_lines > 1 ? (_lines * 16) : 0) +
                        UIConstraints.mMessageInputHeight,
                    child: BlocListener<ChatBloc, ChatState>(
                      listener: (context, state) {
                        if (state is ChatLoaded &&
                            state.inputAction.action != InputAction.none) {
                          if (state.inputAction.action == InputAction.edit) {
                            _messageController.text =
                                state.inputAction.initialContent ?? '';
                          }
                          _focusNode.requestFocus();
                        }
                      },
                      child: TextField(
                        controller: _messageController,
                        expands: true,
                        focusNode: _focusNode,
                        maxLines: null,
                        maxLength: 500,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        onSubmitted: (_) => _sendMessage(),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: _placeholderText,
                          hintStyle: TextStyle(
                            color: colorScheme.onSurface.withAlpha(180),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          counterText: '', // Hide character counter
                        ),
                        style: const TextStyle(fontSize: 16),
                        onChanged: (text) {
                          // Handle typing indicator here if needed
                        },
                      ),
                    ),
                  ),
                ),

                // Emoji button
                _buildActionButton(
                  icon: Icons.emoji_emotions_outlined,
                  onPressed: () => _showEmojiPicker(context),
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
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          return IconButton(
            icon: const Icon(Icons.send_rounded, size: 20),
            onPressed: canSend
                ? () {
                    if (state is ChatLoaded &&
                        state.inputAction.action == InputAction.edit &&
                        state.inputAction.targetEventId != null) {
                      _editMessage(state.inputAction.targetEventId!);
                    } else if (state is ChatLoaded &&
                        state.inputAction.action == InputAction.reply &&
                        state.inputAction.targetEventId != null) {
                      _replyToMessage(state.inputAction.targetEventId!);
                    } else {
                      _sendMessage();
                    }
                    context.read<ChatBloc>().add(
                      const SetInputAction(action: InputAction.none),
                    );
                  }
                : null,
            tooltip: 'Send message',
            color: canSend
                ? colorScheme.primary
                : colorScheme.onSurface.withAlpha(100),
            hoverColor: colorScheme.primary.withAlpha(60),
            splashRadius: 20,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          );
        },
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
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          constraints: const BoxConstraints(maxWidth: 300, maxHeight: 400),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ReactionPicker(onReactionSelected: onReactionSelected),
            ),
          ),
        );
      },
    );
  }

  void onReactionSelected(String emoji) {
    // Insert the selected emoji at the current cursor position
    final text = _messageController.text;
    final selection = _messageController.selection;
    if (selection.isValid) {
      final newText = text.replaceRange(selection.start, selection.end, emoji);
      final newSelectionIndex = selection.start + emoji.length;
      _messageController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newSelectionIndex),
      );
    } else {
      // If no valid selection, append to the end
      _messageController.text += emoji;
      _messageController.selection = TextSelection.collapsed(
        offset: _messageController.text.length,
      );
    }
  }

  void _startVoiceRecording() {}

  void _pickFile() async {
    final filePickerResult = await FilePicker.platform.pickFiles();
    if (filePickerResult != null && filePickerResult.files.isNotEmpty) {
      final filePath = filePickerResult.files.first.path;
      if (filePath != null) {
        setState(() {
          _attachments.add(filePath);
        });
      }
    }
  }

  // void _shareLocation() {}
}
