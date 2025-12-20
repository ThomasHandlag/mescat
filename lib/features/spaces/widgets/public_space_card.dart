import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/shared/widgets/mc_image.dart';

/// Widget to display a public space card with Discord-like styling
class PublicSpaceCard extends StatelessWidget {
  final PublishedRoomsChunk space;
  final VoidCallback? onTap;

  const PublicSpaceCard({super.key, required this.space, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Space Header with Avatar and Badges
            _buildHeader(context, colorScheme),

            // Space Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Space Name
                    _buildSpaceName(context, theme),

                    const SizedBox(height: 8),

                    // Description
                    Expanded(child: _buildDescription(context, theme)),

                    const SizedBox(height: 12),

                    // Tags
                    _buildTags(),
                  ],
                ),
              ),
            ),

            // Stats Footer
            _buildFooter(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withAlpha(190),
            colorScheme.secondary.withAlpha(128),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Avatar
          Positioned(left: 16, bottom: -20, child: _buildAvatar(colorScheme)),

          // Badges
          Positioned(top: 8, right: 8, child: _buildBadges(colorScheme)),
        ],
      ),
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.surface, width: 4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: space.avatarUrl != null
            ? McImage(uri: space.avatarUrl!)
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.blueGrey,
      child: Center(
        child: Text(
          space.name != null ? _getInitials(space.name!) : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBadges(ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (space.guestCanJoin)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium, size: 12, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'PARTNER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        if (space.worldReadable) ...[
          if (space.guestCanJoin) const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 12, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'VERIFIED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSpaceName(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 28.0),
      child: Text(
        space.name ?? 'Unnamed Space',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDescription(BuildContext context, ThemeData theme) {
    return Text(
      space.topic ?? 'No description available.',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withAlpha(179),
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTags() {
    return Text(space.joinRule ?? 'No Rules');
  }

  Widget _buildFooter(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: colorScheme.outline.withAlpha(51)),
        ),
      ),
      child: Row(
        children: [
          // Member count
          Icon(
            Icons.people,
            size: 14,
            color: colorScheme.onSurface.withAlpha(128),
          ),
          const SizedBox(width: 6),
          Text(
            '${_formatCount(space.numJoinedMembers)} members',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withAlpha(179),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '?';
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
