part of 'mescat_usecases.dart';

/// Use case for user authentication
class LoginUseCase {
  final MCRepository repository;

  LoginUseCase(this.repository);

  Future<Either<MCFailure, bool>> call({
    required String username,
    required String password,
  }) async {
    return await repository.login(
      username: username,
      password: password,
    );
  }
}

class RegisterUseCase {
  final MCRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<MCFailure, bool>> call({
    required String username,
    required String password,
    String? email,
  }) async {
    return await repository.register(
      username: username,
      password: password,
      email: email,
    );
  }
}

class LogoutUseCase {
  final MCRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<MCFailure, bool>> call() async {
    return await repository.logout();
  }
}