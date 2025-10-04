import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    // Validate input
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email cannot be empty'));
    }
    
    if (password.isEmpty) {
      return const Left(ValidationFailure('Password cannot be empty'));
    }

    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure('Please enter a valid email'));
    }

    return await repository.login(email: email, password: password);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}