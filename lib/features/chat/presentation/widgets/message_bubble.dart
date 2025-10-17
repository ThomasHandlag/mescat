import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:matrix/matrix.dart';

import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/features/authentication/presentation/blocs/auth_bloc.dart';
import 'package:mescat/features/chat/presentation/widgets/message_item.dart';
import 'package:mescat/features/chat/presentation/widgets/reaction_picker.dart';
import 'package:mescat/features/rooms/presentation/blocs/room_bloc.dart';
// import 'package:mescat/shared/util/string_util.dart';

class MessageBubble extends StatelessWidget {
  final MCMessageEvent message;
  final bool showSender;

  const MessageBubble({
    super.key,
    required this.message,
    required this.showSender,
  });

  void _showUserProfile(BuildContext context, String userId) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx + 40,
        buttonPosition.dy,
        buttonPosition.dx + button.size.width + 40,
        buttonPosition.dy,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 200, maxHeight: 300),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: message.senderAvatarUrl != null
                        ? NetworkImage(message.senderAvatarUrl!)
                        : null,
                    child: message.senderAvatarUrl == null
                        ? Text(
                            _getInitials(
                              message.senderDisplayName ?? message.senderId,
                            ),
                            style: const TextStyle(fontSize: 14),
                          )
                        : null,
                  ),
                  title: Text(
                    message.senderDisplayName ?? message.senderId,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    userId,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(0x80),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'User ID: $userId',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        if (showSender) ...[
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _showUserProfile(context, message.senderId),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: message.senderAvatarUrl != null
                    ? NetworkImage(message.senderAvatarUrl!)
                    : null,
                child: message.senderAvatarUrl == null
                    ? Text(
                        _getInitials(
                          message.senderDisplayName ?? message.senderId,
                        ),
                        style: const TextStyle(fontSize: 14),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ] else ...[
          const SizedBox(width: 52),
        ],

        // Message content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showSender) ...[
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      message.senderDisplayName ?? message.senderId,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: message.isCurrentUser
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimestamp(message.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(0x60),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              MessageItem(
                message: message,
                isCurrentUser: message.isCurrentUser,
                onDelete: () => context.read<RoomBloc>().add(
                  DeleteMessage(
                    roomId: message.roomId,
                    eventId: message.eventId,
                  ),
                ),
                onEdit: () => context.read<RoomBloc>().add(
                  SetInputAction(
                    action: InputAction.edit,
                    targetEventId: message.eventId,
                    initialContent: message.body,
                  ),
                ),
                onReply: () => context.read<RoomBloc>().add(
                  SetInputAction(
                    action: InputAction.reply,
                    targetEventId: message.eventId,
                    initialContent: switch (message.msgtype) {
                      MessageTypes.Text => message.body,
                      _ => 'Attachment ${message.file?.name ?? ''}',
                    },
                  ),
                ),
                onReact: () => showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      constraints: const BoxConstraints(
                        maxWidth: 300,
                        maxHeight: 400,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: SingleChildScrollView(
                          child: ReactionPicker(
                            onReactionSelected: (reaction) {
                              Navigator.of(context).pop();
                              context.read<RoomBloc>().add(
                                AddReaction(
                                  roomId: message.roomId,
                                  eventId: message.eventId,
                                  emoji: reaction,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                child:
                    _buildMessageContent(context, message) ??
                    const SizedBox.shrink(),
              ),
              if (message.reactions.isNotEmpty) ...[
                _buildReactionsRow(context, message.reactions),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget? _buildMessageContent(BuildContext context, MCMessageEvent message) {
    switch (message.msgtype) {
      case MessageTypes.Text:
        {
          final textSpanLists = List<TextSpan>.empty(growable: true);
          if (message.isEdited) {
            textSpanLists.add(
              const TextSpan(
                text: '(edited) ',
                style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.repliedEvent != null)
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text.rich(
                      TextSpan(
                        text:
                            'Replying to ${message.repliedEvent?.senderName}: ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(0x80),
                        ),
                        children: [
                          TextSpan(
                            text: message.repliedEvent!.content,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(0xB3),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Text.rich(
                TextSpan(text: message.body, children: textSpanLists),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              // if (isValidYoutubeUrl(message.body))
            ],
          );
        }

      case MessageTypes.Image:
        {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  message.file!.bytes,
                  fit: BoxFit.cover,
                  width: message.width?.toDouble(),
                  height: message.height?.toDouble(),
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 300,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (message.file != null && message.file!.name.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    message.file!.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(0x80),
                    ),
                  ),
                ),
            ],
          );
        }

      case MessageTypes.File:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.attach_file,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'File: ${message.body}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        );

      case MessageTypes.Audio:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.audiotrack,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Audio message',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: () {}, icon: const Icon(Icons.play_arrow)),
            ],
          ),
        );

      case MessageTypes.Video:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.videocam,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Video message',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      default:
        return null;
    }
  }

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return '?';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildReactionsRow(
    BuildContext context,
    List<MCReactionEvent> reactions,
  ) {
    return Flex(
      direction: Axis.horizontal,
      children: reactions.map((reaction) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              if (reaction.isCurrentUser) {
                if (context.read<AuthBloc>().state is Authenticated) {
                  final userId =
                      (context.read<AuthBloc>().state as Authenticated)
                          .user
                          .userId;
                  final existingReaction = reaction.reactEventIds.firstWhere(
                    (entry) => entry.value == userId,
                    orElse: () => const MapEntry('', ''),
                  );
                  if (existingReaction.key.isNotEmpty) {
                    context.read<RoomBloc>().add(
                      RemoveReaction(
                        roomId: reaction.roomId,
                        eventId: existingReaction.key,
                        emoji: reaction.key,
                      ),
                    );
                  }
                }
              } else {
                context.read<RoomBloc>().add(
                  AddReaction(
                    roomId: reaction.roomId,
                    eventId: message.eventId,
                    emoji: reaction.key,
                  ),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: reaction.isCurrentUser
                      ? Theme.of(context).colorScheme.outline
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              child: Text(
                '${reaction.key} ${reaction.senderDisplayNames.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
