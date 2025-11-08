part of 'auth_bloc.dart';

abstract class MescatStatus extends Equatable {
  const MescatStatus();

  @override
  List<Object?> get props => [];
}

class Inititial extends MescatStatus {}

class Authenticating extends MescatStatus {}

class Loading extends MescatStatus {}

class Authenticated extends MescatStatus {
  final MCUser user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends MescatStatus {}

class AuthError extends MescatStatus {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class NetworkError extends MescatStatus {
  final String message;

  const NetworkError(this.message);

  @override
  List<Object?> get props => [message];
}
