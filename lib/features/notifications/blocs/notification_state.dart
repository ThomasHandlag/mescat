part of 'notification_bloc.dart';

/// Notification States
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NotificationInitial extends NotificationState {}

/// Loading state
class NotificationLoading extends NotificationState {}

/// Loaded state
class NotificationLoaded extends NotificationState {
  final List<Notification> notifications;
  final String? nextToken;

  const NotificationLoaded({required this.notifications, this.nextToken});

  @override
  List<Object?> get props => [notifications, nextToken];

  NotificationLoaded copyWith({
    List<Notification>? notifications,
    String? nextToken,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      nextToken: nextToken,
    );
  }
}

/// Error state
class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
