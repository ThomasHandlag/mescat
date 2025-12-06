import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/features/chat/blocs/chat_bloc.dart';
import 'package:mescat/features/chat/widgets/input_action_banner.dart';
import 'package:mescat/features/chat/widgets/reaction_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

typedef MessageSendCallback = void Function(String content, String type);

class MessageInput extends StatefulWidget {
  final MatrixRoom? room;

  const MessageInput({super.key, required this.room});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isTyping = false;
  final List<String> _attachments = [];
  int _lines = 1;
  bool _viaToken = false;

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

  void _sendMessage() async {
    if (widget.room == null) return;
    final message = _messageController.text.trim();
    if (message.isNotEmpty || _attachments.isNotEmpty) {
      if (_attachments.isNotEmpty) {
        if (!_checkAttachmentSize()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('One or more attachments exceed the size limit.'),
            ),
          );
          return;
        }
        final client = getIt<Client>();
        final room = client.getRoomById(widget.room!.roomId);
        if (room != null) {
          for (final filePath in _attachments) {
            final file = MatrixFile(
              bytes: File(filePath).readAsBytesSync(),
              name: filePath.split(RegExp(r'[\\/]+')).last,
            );
            final eventId = await room.sendFileEvent(
              file,
              extraContent: {'body': message},
            );
          }
        }
      } else {
        // normal text send
        context.read<ChatBloc>().add(
          SendMessage(roomId: widget.room!.roomId, content: message),
        );
        setState(() {
          _isTyping = false;
        });
      }
    }
    _messageController.clear();
    _attachments.clear();
    setState(() {
      _isTyping = !_isTyping;
    });
  }

  void _editMessage(String eventId) {
    if (widget.room == null) return;
    context.read<ChatBloc>().add(
      EditMessage(
        roomId: widget.room!.roomId,
        eventId: eventId,
        newContent: _messageController.text.trim(),
      ),
    );
  }

  void _replyToMessage(String eventId) {
    if (widget.room == null) return;
    if (_attachments.isNotEmpty) {
      if (!_checkAttachmentSize()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('One or more attachments exceed the size limit.'),
          ),
        );
        return;
      }
      final client = getIt<Client>();
      final room = client.getRoomById(widget.room!.roomId);

      if (room != null) {
        final replyContent = {
          'msgtype': MessageTypes.File,
          'body': _messageController.text.trim(),
          'm.relates_to': {
            'm.in_reply_to': {'event_id': eventId},
          },
        };
        for (final filePath in _attachments) {
          final file = MatrixFile(
            bytes: File(filePath).readAsBytesSync(),
            name: filePath.split(RegExp(r'[\\/]+')).last,
          );
          room.sendFileEvent(file, extraContent: {...replyContent});
        }
      }
    } else {
      context.read<ChatBloc>().add(
        ReplyMessage(
          roomId: widget.room!.roomId,
          content: _messageController.text.trim(),
          replyToEventId: eventId,
        ),
      );
    }
    _messageController.clear();
    _attachments.clear();
    setState(() {
      _isTyping = !_isTyping;
    });
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  String get _placeholderText {
    if (widget.room?.name != null) {
      return 'Message #${widget.room!.name}';
    }
    return 'Type a message...';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 70, 70, 70),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_viaToken)
            ListTile(
              title: const Text('This message will be sent via Mesca Token'),
              trailing: IconButton(
                onPressed: () {
                  showAboutDialog(
                    context: context,
                    children: [
                      const Text(
                        'When enabled, this message will be sent using Mesca Tokens. These messages cannot be revoked or edited once sent.',
                      ),
                    ],
                  );
                },
                icon: const Icon(Icons.info),
              ),
            ),
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

                IconButton(
                  icon: Icon(
                    Icons.token,
                    size: 20,
                    color: _viaToken
                        ? colorScheme.primary
                        : colorScheme.onSurface.withAlpha(200),
                  ),
                  onPressed: () {
                    setState(() {
                      _viaToken = !_viaToken;
                    });
                  },
                  tooltip: 'Send Mesca Token',
                ),
                _buildActionButton(
                  icon: Icons.emoji_emotions_outlined,
                  onPressed: () => _showEmojiPicker(context),
                  tooltip: 'Add emoji',
                ),
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

    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
      tooltip: tooltip,
      color: colorScheme.onSurface.withAlpha(200),
      hoverColor: colorScheme.primary.withAlpha(60),
      splashRadius: 20,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }

  bool _validFileSize(Uint8List data) {
    const maxFileSize = 10 * 1024 * 1024;
    return data.lengthInBytes <= maxFileSize;
  }

  bool _checkAttachmentSize() {
    bool allValid = true;
    for (final filePath in _attachments) {
      final file = File(filePath);
      final data = file.readAsBytesSync();
      if (!_validFileSize(data)) {
        allValid = false;
        break;
      }
    }
    return allValid;
  }

  Widget _buildSendButton() {
    final colorScheme = Theme.of(context).colorScheme;
    final canSend =
        _messageController.text.isNotEmpty || _attachments.isNotEmpty;

    return BlocBuilder<ChatBloc, ChatState>(
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
    );
  }

  Widget _buildMicButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
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
                overflow: TextOverflow.ellipsis,
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
                    SizedBox(
                      width: 100,
                      child: Text(
                        attachment.split('/').last,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        overflow: TextOverflow.ellipsis,
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

Future<void> downloadFile(Uint8List data, String fileName) async {
  // pick a location to save the file
  final directory = await getApplicationDocumentsDirectory();

  final filePath = '${directory.path}/$fileName';

  final file = File(filePath);
  await file.writeAsBytes(data);
}
