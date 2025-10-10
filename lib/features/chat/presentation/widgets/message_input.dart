import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/features/chat/presentation/widgets/input_action_banner.dart';
import 'package:mescat/features/chat/presentation/widgets/reaction_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mescat/features/rooms/presentation/blocs/room_bloc.dart';
import 'package:mescat/shared/util/mc_dialog.dart';
import 'package:mescat/shared/widgets/mc_button.dart';
// import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

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

final class _Attachment {
  final String path;
  final FileType type;

  _Attachment({required this.path, required this.type});
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isTyping = false;
  final List<_Attachment> _attachments = [];

  // Voice recording state
  // final AudioRecorder _audioRecorder = AudioRecorder();
  // bool _isRecording = false;
  // bool _isRecordingLocked = false;
  // String? _recordingPath;
  // Timer? _recordingTimer;
  // Duration _recordingDuration = Duration.zero;

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
    // _recordingTimer?.cancel();
    // _audioRecorder.dispose();
    super.dispose();
  }

  void _onMessageChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
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
    context.read<RoomBloc>().add(
      EditMessage(
        roomId: widget.roomId,
        eventId: eventId,
        newContent: _messageController.text.trim(),
      ),
    );
  }

  void _replyToMessage(String eventId) {
    context.read<RoomBloc>().add(
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<RoomBloc, RoomState>(
            builder: (context, state) {
              if (state is RoomLoaded &&
                  state.inputAction.action != InputAction.none) {
                return InputActionBanner(
                  inputAction: state.inputAction,
                  onCancel: () {
                    context.read<RoomBloc>().add(
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: false
                  ? colorScheme.errorContainer.withAlpha(100)
                  : const Color.fromARGB(255, 97, 97, 97),
              borderRadius: BorderRadius.circular(10),
              border: false
                  ? Border.all(
                      color: colorScheme.error.withAlpha(100),
                      width: 2,
                    )
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Attach file button
                _buildActionButton(
                  icon: Icons.add,
                  onPressed: () => _pickFile(),
                  tooltip: 'Attach file',
                ),

                // Text input
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 20 * 24.0),
                    child: BlocListener<RoomBloc, RoomState>(
                      listener: (context, state) {
                        if (state is RoomLoaded &&
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
                ),

                // Emoji button
                _buildActionButton(
                  icon: Icons.emoji_emotions_outlined,
                  onPressed: () => _showEmojiPicker(context),
                  tooltip: 'Add emoji',
                ),

                // Send button or voice recording
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: false
                      ? _buildRecordingInterface()
                      : (_isTyping || _attachments.isNotEmpty)
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
      child: BlocBuilder<RoomBloc, RoomState>(
        builder: (context, state) {
          return IconButton(
            icon: const Icon(Icons.send_rounded, size: 20),
            onPressed: canSend
                ? () {
                    if (state is RoomLoaded &&
                        state.inputAction.action == InputAction.edit &&
                        state.inputAction.targetEventId != null) {
                      _editMessage(state.inputAction.targetEventId!);
                    } else if (state is RoomLoaded &&
                        state.inputAction.action == InputAction.reply &&
                        state.inputAction.targetEventId != null) {
                      _replyToMessage(state.inputAction.targetEventId!);
                    } else {
                      _sendMessage();
                    }
                    context.read<RoomBloc>().add(
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

    if (false) {
      return _buildRecordingInterface();
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: false ? null : _startVoiceRecording,
        onLongPressStart: (_) => _startVoiceRecording(),
        onLongPressEnd: (_) {
          if (!false) {
            _stopVoiceRecording();
          }
        },
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: false
                ? colorScheme.error.withAlpha(100)
                : Colors.transparent,
          ),
          child: Icon(
            Icons.mic,
            size: 20,
            color: false
                ? colorScheme.error
                : colorScheme.onSurface.withAlpha(190),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingInterface() {
    final colorScheme = Theme.of(context).colorScheme;
    // final minutes = _recordingDuration.inMinutes;
    // final seconds = _recordingDuration.inSeconds % 60;
    final minutes = 10;
    final seconds = 130;
    final timeText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Recording indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),

          // Recording time
          Text(
            timeText,
            style: TextStyle(
              color: colorScheme.onErrorContainer,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),

          // Lock button (to keep recording when releasing)
          if (!false)
            GestureDetector(
              onTap: () {
                // setState(() {
                //   _isRecordingLocked = true;
                // });
              },
              child: Icon(
                Icons.lock_open,
                size: 16,
                color: colorScheme.onErrorContainer.withAlpha(180),
              ),
            ),

          // if (_isRecordingLocked) ...[
          if (false) ...[
            // Cancel button
            GestureDetector(
              onTap: _cancelVoiceRecording,
              child: Icon(
                Icons.close,
                size: 20,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(width: 8),

            // Send button
            GestureDetector(
              onTap: () => _stopVoiceRecording(send: true),
              child: Icon(
                Icons.send,
                size: 20,
                color: colorScheme.onErrorContainer,
              ),
            ),
          ],
        ],
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
            children: _attachments.indexed.map((attachment) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colorScheme.outline.withAlpha(100)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      padding: const EdgeInsets.all(2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        spacing: 4,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          McButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                const Color(0xFFFF0000),
                              ),
                            ),
                            onPressed: () => _removeAttachment(attachment.$1),
                            child: const Icon(Icons.close),
                          ),
                          McButton(
                            onPressed: () => showImageDialog(context, attachment.$2.path),
                            child: const Icon(Icons.remove_red_eye),
                          ),
                        ],
                      ),
                    ),
                    if (attachment.$2.type == FileType.image) ...[
                      Image.file(
                        File(attachment.$2.path),
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                    ] else if (attachment.$2.type == FileType.video) ...[
                      // Placeholder for video thumbnail
                      Container(
                        width: 100,
                        height: 100,
                        color: colorScheme.onSurface.withAlpha(50),
                        child: const Icon(
                          Icons.videocam,
                          size: 40,
                          color: Colors.white70,
                        ),
                      ),
                    ] else if (attachment.$2.type == FileType.audio) ...[
                      // Placeholder for audio file
                      Container(
                        width: 100,
                        height: 100,
                        color: colorScheme.onSurface.withAlpha(50),
                        child: const Icon(
                          Icons.audiotrack,
                          size: 40,
                          color: Colors.white70,
                        ),
                      ),
                    ] else ...[
                      // Generic file icon
                      Container(
                        width: 100,
                        height: 100,
                        color: colorScheme.onSurface.withAlpha(50),
                        child: const Icon(
                          Icons.insert_drive_file,
                          size: 40,
                          color: Colors.white70,
                        ),
                      ),
                    ],
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

  Future<void> _startVoiceRecording() async {
    // Request microphone permission
    final permission = await Permission.microphone.request();
    if (permission != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Microphone permission is required to record voice messages',
            ),
          ),
        );
      }
      return;
    }

    // try {
    //   // Get temporary directory for recording
    //   final directory = await getTemporaryDirectory();
    //   final fileName =
    //       'voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a';
    //   _recordingPath = '${directory.path}/$fileName';

    //   // Start recording
    //   await _audioRecorder.start(
    //     const RecordConfig(
    //       encoder: AudioEncoder.aacLc,
    //       bitRate: 128000,
    //       sampleRate: 44100,
    //     ),
    //     path: _recordingPath!,
    //   );

    //   if (mounted) {
    //     setState(() {
    //       _isRecording = true;
    //       _recordingDuration = Duration.zero;
    //     });
    //   }

    //   // Start timer to track recording duration
    //   _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    //     if (mounted) {
    //       setState(() {
    //         _recordingDuration = Duration(seconds: timer.tick);
    //       });
    //     }
    //   });
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Failed to start recording: $e')),
    //     );
    //   }
    // }
  }

  Future<void> _stopVoiceRecording({bool send = true}) async {
    // try {
    //   await _audioRecorder.stop();
    //   _recordingTimer?.cancel();

    //   if (mounted) {
    //     setState(() {
    //       _isRecording = false;
    //       _isRecordingLocked = false;
    //     });
    //   }

    //   if (send && _recordingPath != null) {
    //     // Add the voice message to attachments or send directly
    //     final file = File(_recordingPath!);
    //     if (await file.exists()) {
    //       widget.onSendMessage(_recordingPath!, MessageTypes.Audio);
    //     }
    //   }

    //   _recordingPath = null;
    //   _recordingDuration = Duration.zero;
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(
    //       context,
    //     ).showSnackBar(SnackBar(content: Text('Failed to stop recording: $e')));
    //   }
    // }
  }

  Future<void> _cancelVoiceRecording() async {
    await _stopVoiceRecording(send: false);

    // // Delete the recording file
    // if (_recordingPath != null) {
    //   final file = File(_recordingPath!);
    //   if (await file.exists()) {
    //     await file.delete();
    //   }
    // }
  }

  void _pickFile({FileType fileType = FileType.any}) async {
    final filePickerResult = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: fileType,
    );
    if (filePickerResult != null && filePickerResult.files.isNotEmpty) {
      if (filePickerResult.files.first.path != null) {
        setState(() {
          _attachments.addAll(
            filePickerResult.files.map(
              (file) => _Attachment(
                path: file.path!,
                type: _mapFileExtensionToFileType(file.extension),
              ),
            ),
          );
        });
      }
    }
  }

  FileType _mapFileExtensionToFileType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return FileType.image;
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
      case 'webm':
        return FileType.video;
      case 'mp3':
      case 'wav':
      case 'm4a':
      case 'aac':
        return FileType.audio;
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'xls':
      case 'xlsx':
      case 'ppt':
      case 'pptx':
      case 'txt':
        return FileType.custom;
      default:
        return FileType.any;
    }
  }

  // void _shareLocation() {}
}
