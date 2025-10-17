part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;
  final String? serverUrl;

  const LoginRequested({
    required this.username,
    required this.password,
    this.serverUrl,
  });

  @override
  List<Object?> get props => [username, password, serverUrl];
}

class RegisterRequested extends AuthEvent {
  final String username;
  final String password;
  final String? email;

  const RegisterRequested({
    required this.username,
    required this.password,
    this.email,
  });

  @override
  List<Object?> get props => [username, password, email];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class SetServer extends AuthEvent {
  final String serverUrl;

  const SetServer({required this.serverUrl});

  @override
  List<Object?> get props => [serverUrl];
}