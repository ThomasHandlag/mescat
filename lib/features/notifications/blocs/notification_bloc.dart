import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/core/mescat/domain/usecases/mescat_usecases.dart';
import 'package:matrix/matrix.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;

  NotificationBloc({required this.getNotificationsUseCase})
    : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());

    final result = await getNotificationsUseCase();

    result.fold((failure) => emit(NotificationError(failure.toString())), (
      data,
    ) {
      final notifications = data['notifications'] as List<Notification>;
      final nextToken = data['nextToken'] as String?;

      emit(
        NotificationLoaded(notifications: notifications, nextToken: nextToken),
      );
    });
  }
}
