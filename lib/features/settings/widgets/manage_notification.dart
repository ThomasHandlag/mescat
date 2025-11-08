import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

enum NotificationLevel {
  all,
  mentionsOnly,
  muted;

  String get displayName {
    switch (this) {
      case NotificationLevel.all:
        return 'All Messages';
      case NotificationLevel.mentionsOnly:
        return 'Mentions Only';
      case NotificationLevel.muted:
        return 'Muted';
    }
  }

  String get description {
    switch (this) {
      case NotificationLevel.all:
        return 'Get notified for all messages';
      case NotificationLevel.mentionsOnly:
        return 'Only get notified when mentioned';
      case NotificationLevel.muted:
        return 'No notifications for this room';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationLevel.all:
        return Icons.notifications_active;
      case NotificationLevel.mentionsOnly:
        return Icons.alternate_email;
      case NotificationLevel.muted:
        return Icons.notifications_off;
    }
  }
}

class ManageNotification extends StatefulWidget {
  const ManageNotification({super.key, required this.room});

  final Room room;

  @override
  State<ManageNotification> createState() => _ManageNotificationState();
}

class _ManageNotificationState extends State<ManageNotification> {
  bool _isLoading = false;
  NotificationLevel? _currentLevel;
  PushRuleState? _pushRuleState;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  void _loadNotificationSettings() {
    setState(() {
      _pushRuleState = widget.room.pushRuleState;
      _currentLevel = _getPushRuleStateAsLevel(_pushRuleState);
    });
  }

  NotificationLevel _getPushRuleStateAsLevel(PushRuleState? state) {
    switch (state) {
      case PushRuleState.notify:
        return NotificationLevel.all;
      case PushRuleState.mentionsOnly:
        return NotificationLevel.mentionsOnly;
      case PushRuleState.dontNotify:
        return NotificationLevel.muted;
      case null:
        return NotificationLevel.all;
    }
  }

  PushRuleState _getLevelAsPushRuleState(NotificationLevel level) {
    switch (level) {
      case NotificationLevel.all:
        return PushRuleState.notify;
      case NotificationLevel.mentionsOnly:
        return PushRuleState.mentionsOnly;
      case NotificationLevel.muted:
        return PushRuleState.dontNotify;
    }
  }

  Future<void> _updateNotificationLevel(NotificationLevel level) async {
    if (_currentLevel == level) return;

    setState(() => _isLoading = true);

    try {
      final pushRuleState = _getLevelAsPushRuleState(level);
      await widget.room.setPushRuleState(pushRuleState);

      setState(() {
        _currentLevel = level;
        _pushRuleState = pushRuleState;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification set to ${level.displayName}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating notifications: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Current Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _currentLevel?.icon ?? Icons.notifications,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Setting',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              Text(
                                _currentLevel?.displayName ?? 'Loading...',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_currentLevel != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _currentLevel!.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Notification Level Options
            Text(
              'Notification Levels',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),

            ...NotificationLevel.values.map((level) {
              final isSelected = _currentLevel == level;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    level.icon,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    level.displayName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  ),
                  subtitle: Text(level.description),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  selected: isSelected,
                  onTap: _isLoading
                      ? null
                      : () => _updateNotificationLevel(level),
                ),
              );
            }),

            const SizedBox(height: 24),
            Text(
              'Additional Settings',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.volume_up),
                    title: const Text('Sound'),
                    subtitle: const Text('Play sound for notifications'),
                    trailing: Switch(
                      value: true, // This would be connected to actual sound settings
                      onChanged: (value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sound settings coming soon'),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.vibration),
                    title: const Text('Vibration'),
                    subtitle: const Text('Vibrate for notifications'),
                    trailing: Switch(
                      value: true, // This would be connected to actual vibration settings
                      onChanged: (value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vibration settings coming soon'),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.brightness_2),
                    title: const Text('Do Not Disturb'),
                    subtitle: const Text('Respect system DND settings'),
                    trailing: Switch(
                      value: true, // This would be connected to actual DND settings
                      onChanged: (value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('DND settings coming soon'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Keywords Section
            Text(
              'Keywords',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),

            Card(
              child: ListTile(
                leading: const Icon(Icons.tag),
                title: const Text('Custom Keywords'),
                subtitle: const Text('Get notified when these words are mentioned'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Keyword management coming soon'),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Info Card
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Notification settings only apply to this room. '
                        'You can change global notification settings in app settings.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_isLoading)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
