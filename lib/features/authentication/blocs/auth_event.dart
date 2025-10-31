part of 'auth_bloc.dart';

abstract class MescatEvent extends Equatable {
  const MescatEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends MescatEvent {
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

final class InitialEvent extends MescatEvent {}

class RegisterRequested extends MescatEvent {
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

class LogoutRequested extends MescatEvent {}

class CheckAuthStatus extends MescatEvent {}

class SetServer extends MescatEvent {
  final String serverUrl;

  const SetServer({required this.serverUrl});

  @override
  List<Object?> get props => [serverUrl];
}