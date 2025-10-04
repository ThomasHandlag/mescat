import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../features/chat/domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;
  final Function()? onReply;
  final Function()? onReact;
  final Function()? onEdit;
  final Function()? onDelete;

  const MessageBubble({
    super.key,
    required this.message,
    this.isCurrentUser = false,
    this.onReply,
    this.onReact,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding / 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          _buildAvatar(colorScheme),
          
          const SizedBox(width: AppConstants.defaultPadding),
          
          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (username and timestamp)
                _buildMessageHeader(theme),
                
                const SizedBox(height: 2),
                
                // Message content
                if (message.content.isNotEmpty)
                  _buildMessageContent(theme),
                
                // Attachments
                if (message.attachments.isNotEmpty)
                  _buildAttachments(colorScheme),
                
                // Edit indicator
                if (message.isEdited)
                  _buildEditIndicator(colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primaryContainer,
      ),
      child: message.authorAvatarUrl != null
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: message.authorAvatarUrl!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildAvatarPlaceholder(colorScheme),
                errorWidget: (context, url, error) => _buildAvatarPlaceholder(colorScheme),
              ),
            )
          : _buildAvatarPlaceholder(colorScheme),
    );
  }

  Widget _buildAvatarPlaceholder(ColorScheme colorScheme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primaryContainer,
      ),
      child: Center(
        child: Text(
          message.authorUsername.isNotEmpty 
              ? message.authorUsername[0].toUpperCase()
              : 'U',
          style: TextStyle(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageHeader(ThemeData theme) {
    return Row(
      children: [
        // Username
        Text(
          message.authorUsername,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isCurrentUser 
                ? theme.colorScheme.primary 
                : theme.colorScheme.onSurface,
          ),
        ),
        
        const SizedBox(width: AppConstants.smallPadding),
        
        // Timestamp
        Text(
          _formatTimestamp(message.timestamp),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageContent(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SelectableText(
        message.content,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildAttachments(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.smallPadding),
      child: Wrap(
        spacing: AppConstants.smallPadding,
        runSpacing: AppConstants.smallPadding,
        children: message.attachments.map((attachment) {
          return _buildAttachmentTile(attachment, colorScheme);
        }).toList(),
      ),
    );
  }

  Widget _buildAttachmentTile(String attachment, ColorScheme colorScheme) {
    final isImage = _isImageFile(attachment);
    
    if (isImage) {
      return Container(
        constraints: const BoxConstraints(
          maxWidth: 300,
          maxHeight: 200,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: attachment,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 100,
              color: colorScheme.surface,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              height: 100,
              color: colorScheme.surface,
              child: const Icon(Icons.error),
            ),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_drive_file,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Text(
              attachment.split('/').last,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildEditIndicator(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        '(edited)',
        style: TextStyle(
          fontSize: 11,
          color: colorScheme.onSurface.withOpacity(0.5),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  bool _isImageFile(String url) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return imageExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }
}