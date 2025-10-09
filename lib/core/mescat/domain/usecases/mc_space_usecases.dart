part of 'mescat_usecases.dart';

/// Use case for getting user's spaces
class GetSpacesUseCase {
  final MCRepository repository;

  GetSpacesUseCase(this.repository);

  Future<Either<MCFailure, List<MatrixSpace>>> call() async {
    return await repository.getSpaces();
  }
}

/// Use case for creating spaces (Discord servers)
class CreateSpaceUseCase {
  final MCRepository repository;

  CreateSpaceUseCase(this.repository);

  Future<Either<MCFailure, MatrixSpace>> call({
    required String name,
    String? description,
    bool isPublic = false,
  }) async {
    return await repository.createSpace(
      name: name,
      description: description,
      isPublic: isPublic,
    );
  }
}
