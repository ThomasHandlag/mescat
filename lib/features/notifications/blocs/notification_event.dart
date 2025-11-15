part of 'notification_bloc.dart';

/// Notification Events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Load notifications
class LoadNotifications extends NotificationEvent {
  const LoadNotifications();
}

/// Mark notification as read
class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Delete notification
class DeleteNotification extends NotificationEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Filter notifications by type
class FilterNotifications extends NotificationEvent {
  final String? filterType;

  const FilterNotifications(this.filterType);

  @override
  List<Object?> get props => [filterType];
}

/// Mark all notifications as read
class MarkAllNotificationsAsRead extends NotificationEvent {
  const MarkAllNotificationsAsRead();
}

/// Clear all notifications
class ClearAllNotifications extends NotificationEvent {
  const ClearAllNotifications();
}
