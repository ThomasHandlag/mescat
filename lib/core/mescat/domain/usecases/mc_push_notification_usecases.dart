part of 'mescat_usecases.dart';

/// Use case for registering push notifications with Matrix homeserver
class RegisterPushNotificationUseCase {
  final MCRepository repository;

  RegisterPushNotificationUseCase(this.repository);

  Future<Either<MCFailure, bool>> call({
    required String pushkey,
    required String appId,
    String? pushGatewayUrl,
    String? deviceDisplayName,
    String? lang,
  }) async {
    return await repository.registerPusher(
      pushkey: pushkey,
      appId: appId,
      pushGatewayUrl: pushGatewayUrl,
      deviceDisplayName: deviceDisplayName,
      lang: lang,
    );
  }
}

/// Use case for unregistering push notifications
class UnregisterPushNotificationUseCase {
  final MCRepository repository;

  UnregisterPushNotificationUseCase(this.repository);

  Future<Either<MCFailure, bool>> call({
    required String pushkey,
    required String appId,
  }) async {
    return await repository.unregisterPusher(
      pushkey: pushkey,
      appId: appId,
    );
  }
}
