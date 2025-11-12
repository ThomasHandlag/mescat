import 'dart:io';

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
      padding: const EdgeInsets.all(2),
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
      child: Platform.isIOS || Platform.isAndroid
          ? _buildMobile(context)
          : _buildDesktop(context),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Row(
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

        // Delete (only for current user)
        if (isCurrentUser)
          _buildActionButton(
            context,
            icon: Icons.delete_outline,
            tooltip: 'Delete',
            onPressed: onDelete,
            isDestructive: true,
          ),

        // More actions
        _buildActionButton(
          context,
          icon: Icons.more_horiz,
          tooltip: 'More',
          onPressed: () =>
              _showMoreActions(context, onCopy, onReport, onEdit, onDelete),
        ),
      ],
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

  void _showMoreActions(
    BuildContext context,
    VoidCallback? onCopy,
    VoidCallback? onReport,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  ) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );

    showMenu(
      popUpAnimationStyle: AnimationStyle.noAnimation,
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy - 8,
        buttonPosition.dx + button.size.width,
        buttonPosition.dy + button.size.height + 8,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withAlpha(0x4D),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Actions
        PopupMenuItem(
          child: _buildMoreActionTile(
            context,
            icon: Icons.content_copy,
            title: 'Copy Message',
            onTap: () {
              onCopy?.call();
            },
          ),
        ),
        PopupMenuItem(
          child: _buildMoreActionTile(
            context,
            icon: Icons.copy_all,
            title: 'Copy Message Link',
            onTap: () {},
          ),
        ),
        PopupMenuItem(
          child: _buildMoreActionTile(
            context,
            icon: Icons.mark_chat_unread,
            title: 'Mark Unread',
            onTap: () {},
          ),
        ),
        if (!isCurrentUser)
          PopupMenuItem(
            child: _buildMoreActionTile(
              context,
              icon: Icons.flag,
              title: 'Report Message',
              onTap: () {
                onReport?.call();
              },
              isDestructive: true,
            ),
          ),
        if (isCurrentUser) ...[
          PopupMenuItem(
            child: _buildMoreActionTile(
              context,
              icon: Icons.edit,
              title: 'Edit Message',
              onTap: () {
                onEdit?.call();
              },
            ),
          ),
          PopupMenuItem(
            child: _buildMoreActionTile(
              context,
              icon: Icons.delete,
              title: 'Delete Message',
              onTap: () {
                onDelete?.call();
              },
              isDestructive: true,
            ),
          ),
        ],
      ],
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
        size: 16,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? colorScheme.error : colorScheme.onSurface,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(
            thickness: 4,
            indent: 120,
            endIndent: 120,
            radius: BorderRadius.all(Radius.circular(5)),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildMobileActionTile(
                  context,
                  icon: Icons.content_copy,
                  title: 'Copy Message',
                  onTap: () {
                    onCopy?.call();
                  },
                ),
                _buildMobileActionTile(
                  context,
                  icon: Icons.flag,
                  title: 'Report Message',
                  onTap: () {
                    onReport?.call();
                  },
                  isDestructive: true,
                ),
                if (isCurrentUser)
                  _buildMobileActionTile(
                    context,
                    icon: Icons.edit,
                    title: 'Edit Message',
                    onTap: () {
                      onEdit?.call();
                    },
                  ),
                if (isCurrentUser)
                  _buildMobileActionTile(
                    context,
                    icon: Icons.delete,
                    title: 'Delete Message',
                    onTap: () {
                      onDelete?.call();
                    },
                    isDestructive: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileActionTile(
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
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? colorScheme.error : colorScheme.onSurface,
          fontSize: 16,
        ),
      ),
      onTap: () {
        onTap();
        Navigator.of(context).pop();
      },
    );
  }
}
