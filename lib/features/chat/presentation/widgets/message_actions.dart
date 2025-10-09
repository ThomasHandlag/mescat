import 'package:flutter/material.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';

class MessageActions extends StatelessWidget {
  final MCMessageEvent message;
  final bool isCurrentUser;
  final VoidCallback? onReply;
  final VoidCallback? onReact;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;
  final VoidCallback? onPin;
  final VoidCallback? onReport;

  const MessageActions({
    super.key,
    required this.message,
    this.isCurrentUser = false,
    this.onReply,
    this.onReact,
    this.onEdit,
    this.onDelete,
    this.onCopy,
    this.onPin,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(0x1A),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add reaction
          _buildActionButton(
            context,
            icon: Icons.add_reaction_outlined,
            tooltip: 'Add Reaction',
            onPressed: onReact,
          ),
          
          // Reply
          _buildActionButton(
            context,
            icon: Icons.reply,
            tooltip: 'Reply',
            onPressed: onReply,
          ),
          
          // Copy message
          _buildActionButton(
            context,
            icon: Icons.content_copy,
            tooltip: 'Copy Text',
            onPressed: onCopy,
          ),
          
          // Edit (only for current user)
          if (isCurrentUser)
            _buildActionButton(
              context,
              icon: Icons.edit,
              tooltip: 'Edit',
              onPressed: onEdit,
            ),
          
          // Pin message
          _buildActionButton(
            context,
            icon: Icons.push_pin,
            tooltip: 'Pin Message',
            onPressed: onPin,
          ),
          
          // More actions
          _buildActionButton(
            context,
            icon: Icons.more_horiz,
            tooltip: 'More',
            onPressed: () => _showMoreActions(context),
          ),
          
          // Delete (only for current user)
          if (isCurrentUser)
            _buildActionButton(
              context,
              icon: Icons.delete_outline,
              tooltip: 'Delete',
              onPressed: onDelete,
              isDestructive: true,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    VoidCallback? onPressed,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 16,
              color: isDestructive 
                  ? colorScheme.error
                  : colorScheme.onSurface.withAlpha(0xCC),
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withAlpha(0x4D),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            
            // Actions
            _buildMoreActionTile(
              context,
              icon: Icons.content_copy,
              title: 'Copy Message',
              onTap: () {
                Navigator.pop(context);
                onCopy?.call();
              },
            ),
            
            _buildMoreActionTile(
              context,
              icon: Icons.copy_all,
              title: 'Copy Message Link',
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement copy message link
              },
            ),
            
            _buildMoreActionTile(
              context,
              icon: Icons.mark_chat_unread,
              title: 'Mark Unread',
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement mark unread
              },
            ),
            
            if (!isCurrentUser)
              _buildMoreActionTile(
                context,
                icon: Icons.flag,
                title: 'Report Message',
                onTap: () {
                  Navigator.pop(context);
                  onReport?.call();
                },
                isDestructive: true,
              ),
            
            if (isCurrentUser) ...[
              _buildMoreActionTile(
                context,
                icon: Icons.edit,
                title: 'Edit Message',
                onTap: () {
                  Navigator.pop(context);
                  onEdit?.call();
                },
              ),
              
              _buildMoreActionTile(
                context,
                icon: Icons.delete,
                title: 'Delete Message',
                onTap: () {
                  Navigator.pop(context);
                  onDelete?.call();
                },
                isDestructive: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMoreActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? colorScheme.error : colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? colorScheme.error : colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }
}