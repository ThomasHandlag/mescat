part of 'mescat_usecases.dart';

/// Use case for getting notifications
class GetNotificationsUseCase {
  final MCRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<Either<MCFailure, Map<String ,dynamic>>> call() async {
    return await repository.getNotifications();
  }
}