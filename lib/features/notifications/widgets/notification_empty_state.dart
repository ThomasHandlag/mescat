import 'package:flutter/material.dart';

/// Widget to display empty state for notifications
class NotificationEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;

  const NotificationEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.notifications_none,
    this.action,
  });

  factory NotificationEmptyState.noNotifications() {
    return const NotificationEmptyState(
      title: 'No notifications',
      subtitle: 'New notifications will appear here',
      icon: Icons.notifications_none,
    );
  }

  factory NotificationEmptyState.noUnread() {
    return const NotificationEmptyState(
      title: 'No unread notifications',
      subtitle: 'You\'re all caught up!',
      icon: Icons.check_circle_outline,
    );
  }

  factory NotificationEmptyState.filtered({required String filterName}) {
    return NotificationEmptyState(
      title: 'No $filterName notifications',
      subtitle: 'Try changing your filter or check back later',
      icon: Icons.filter_alt_off,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
