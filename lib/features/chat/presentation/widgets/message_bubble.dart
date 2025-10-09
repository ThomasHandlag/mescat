import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/features/authentication/presentation/blocs/auth_bloc.dart';
import 'package:mescat/features/chat/presentation/widgets/message_item.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/features/rooms/presentation/blocs/room_bloc.dart';

class MessageBubble extends StatelessWidget {
  final MCMessageEvent message;
  final bool showSender;

  const MessageBubble({
    super.key,
    required this.message,
    required this.showSender,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        if (showSender) ...[
          CircleAvatar(
            radius: 20,
            backgroundImage: message.senderAvatarUrl != null
                ? NetworkImage(message.senderAvatarUrl!)
                : null,
            child: message.senderAvatarUrl == null
                ? Text(
                    _getInitials(message.senderDisplayName ?? message.senderId),
                    style: const TextStyle(fontSize: 14),
                  )
                : null,
          ),
          const SizedBox(width: 12),
        ] else ...[
          const SizedBox(width: 52), // Same width as avatar + spacing
        ],

        // Message content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sender info
              if (showSender) ...[
                Row(
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
        return Text(
          message.body,
          style: Theme.of(context).textTheme.bodyMedium,
        );

      case MessageTypes.Image:
        {
          final imageMessage = message as MCImageEvent;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  imageMessage.file!.bytes,
                  fit: BoxFit.cover,
                  width: imageMessage.width.toDouble(),
                  height: imageMessage.height.toDouble(),
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
                if (context.read<AuthBloc>().state is AuthAuthenticated) {
                  final userId =
                      (context.read<AuthBloc>().state as AuthAuthenticated)
                          .user
                          .userId;
                  final existingReaction = reaction.reactEventIds.firstWhere(
                    (entry) => entry.value == userId,
                    orElse: () => MapEntry('', ''),
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
                // Handle adding reaction
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
