import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/core/mescat/domain/usecases/mescat_usecases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// Authentication BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SetServerUseCase setServerUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.setServerUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUseCase(
      username: event.username,
      password: event.password,
      serverUrl: event.serverUrl,
    );

    await result.fold((failure) async => emit(AuthError(failure.message)), (
      success,
    ) async {
      final userResult = await getCurrentUserUseCase();
      userResult.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(
          Authenticated(
            user.copyWith(
              accessToken: success.accessToken,
              refreshToken: success.refreshToken,
            ),
          ),
        ),
      );
    });
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      username: event.username,
      password: event.password,
      email: event.email,
    );

    result.fold((failure) => emit(AuthError(failure.message)), (success) async {
      if (success) {
        final userResult = await getCurrentUserUseCase();
        userResult.fold(
          (failure) => emit(AuthError(failure.message)),
          (user) => emit(Authenticated(user)),
        );
      } else {
        emit(const AuthError('Registration failed'));
      }
    });
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await logoutUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (success) => emit(Unauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 3000));
    final result = await getCurrentUserUseCase();

    result.fold(
      (failure) => emit(Unauthenticated()),
      (user) => emit(Authenticated(user)),
    );
  }
}
