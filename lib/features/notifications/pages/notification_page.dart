import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:matrix/matrix_api_lite/model/event_types.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/features/notifications/blocs/notification_bloc.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    // Load notifications when page initializes
    context.read<NotificationBloc>().add(const LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final unreadCount = state is NotificationLoaded
            ? state.notifications.length
            : 0;

        return Scaffold(
          appBar: _buildAppBar(unreadCount),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(NotificationState state) {
    if (state is NotificationLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is NotificationError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load notifications',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<NotificationBloc>().add(const LoadNotifications());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is NotificationLoaded) {
      return _buildNotificationList(state);
    }

    return const SizedBox.shrink();
  }

  PreferredSizeWidget _buildAppBar(int unreadCount) {
    final theme = Theme.of(context);

    return AppBar(
      title: Row(
        children: [
          const Text('Notifications'),
          if (unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unreadCount',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (unreadCount > 0)
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              context.read<NotificationBloc>().add(
                const MarkAllNotificationsAsRead(),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Mark all as read',
          ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear_all',
              child: Row(
                children: [
                  Icon(Icons.delete_sweep),
                  SizedBox(width: 8),
                  Text('Clear all notifications'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Notification settings'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationList(NotificationLoaded state) {
    if (state.notifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: state.notifications.length,
      itemBuilder: (context, index) {
        final notification = state.notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(matrix.Notification notification) {
    final theme = Theme.of(context);

    String notificationContent = '';

    bool isInvite = false;

    if (notification.event.type == EventTypes.RoomMember) {
      final content = notification.event.content;
      final membership = content['membership'] ?? 'unknown';
      notificationContent =
          '${notification.event.senderId} has $membership you to the room.';
      isInvite = membership == 'invite';
    } else if (notification.event.type == EventTypes.Message) {
      final content = notification.event.content;
      final body = content['body'] as String? ?? 'You have a new message.';
      notificationContent = body;
    } else {
      notificationContent = 'You have a new message.';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.notifications)),
        title: Text(notificationContent, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room: ${notification.roomId}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isInvite)
              IconButton(
                icon: const Icon(Icons.done),
                onPressed: () {
                  final client = getIt<matrix.Client>();
                  client.joinRoomById(notification.roomId);
                },
                tooltip: 'Accept Invite',
              ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                context.read<NotificationBloc>().add(
                  DeleteNotification(notification.roomId),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification dismissed'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'Dismiss',
            ),
          ],
        ),
        onTap: () {
          context.read<NotificationBloc>().add(
            MarkNotificationAsRead(notification.roomId),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening room: ${notification.roomId}'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(0xE1),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear_all':
        _showClearAllDialog();
        break;
      case 'settings':
        _showNotificationSettings();
        break;
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text(
          'This will permanently delete all notifications. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotificationBloc>().add(
                const ClearAllNotifications(),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive notifications on this device'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Sound'),
              subtitle: const Text('Play sound for new notifications'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Desktop Notifications'),
              subtitle: const Text('Show desktop notifications'),
              value: Platform.isAndroid || Platform.isIOS ? false : true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
