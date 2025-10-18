part of 'mescat_usecases.dart';

/// Use case for getting current user
class GetCurrentUserUseCase {
  final MCRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<MCFailure, MCUser>> call() async {
    return await repository.getCurrentUser();
  }
}

class SetServerUseCase {
  final MCRepository repository;

  SetServerUseCase(this.repository);

  Future<Either<MCFailure, bool>> call(String serverUrl) async {
    return await repository.setServer(serverUrl);
  }
}
