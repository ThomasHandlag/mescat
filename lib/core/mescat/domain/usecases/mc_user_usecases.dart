part of 'mescat_usecases.dart';

/// Use case for getting current user
class GetCurrentUserUseCase {
  final MCRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<MCFailure, MCUser>> call() async {
    return await repository.getCurrentUser();
  }
}
