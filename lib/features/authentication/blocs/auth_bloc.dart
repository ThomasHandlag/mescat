import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/core/mescat/domain/usecases/mescat_usecases.dart';
import 'package:mescat/dependency_injection.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// Authentication BLoC
class MescatBloc extends Bloc<MescatEvent, MescatStatus> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SetServerUseCase setServerUseCase;
  final OAuthLoginUseCase oauthLoginUseCase;

  bool haveConnection = false;

  MescatBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.setServerUseCase,
    required this.oauthLoginUseCase,
  }) : super(Inititial()) {
    on<InitialEvent>(_onInit);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SSOLoginRequested>(_onOAuthLoginRequested);
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      if (result.contains(ConnectivityResult.mobile)) {
        haveConnection = true;
        add(CheckAuthStatus());
      } else if (result.contains(ConnectivityResult.wifi)) {
        haveConnection = true;
        add(CheckAuthStatus());
      } else if (result.contains(ConnectivityResult.ethernet)) {
        haveConnection = true;
        add(CheckAuthStatus());
      } else {
        haveConnection = false;
      }
    });
  }

  Future<void> _onInit(MescatEvent event, Emitter<MescatStatus> emit) async {
    final List<ConnectivityResult> connectivityResult = await (Connectivity()
        .checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      haveConnection = true;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      haveConnection = true;
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      haveConnection = true;
    } else {
      haveConnection = false;
    }

    if (haveConnection) {
      add(CheckAuthStatus());
    } else {
      emit(const NetworkError('No internet connection'));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<MescatStatus> emit,
  ) async {
    emit(Loading());

    if (!haveConnection) {
      emit(const NetworkError('No internet connection'));
      return;
    }

    final result = await loginUseCase(
      username: event.username,
      password: event.password,
      serverUrl: event.serverUrl,
    );

    await result.fold((failure) async => emit(AuthError(failure.message)), (
      success,
    ) async {
      final userResult = await getCurrentUserUseCase();
      userResult.fold((failure) => emit(AuthError(failure.message)), (user) {
        add(CheckAuthStatus());
      });
    });
  }

  Future<void> _onOAuthLoginRequested(
    SSOLoginRequested event,
    Emitter<MescatStatus> emit,
  ) async {
    emit(Loading());

    if (!haveConnection) {
      emit(const NetworkError('No internet connection'));
      return;
    }

    final result = await oauthLoginUseCase(loginToken: event.loginToken);

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
              avatarUrl: success.avatarUrl,
            ),
          ),
        ),
      );
    });
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<MescatStatus> emit,
  ) async {
    emit(Loading());

    if (!haveConnection) {
      emit(const NetworkError('No internet connection'));
      return;
    }

    final result = await registerUseCase(
      username: event.username,
      password: event.password,
      email: event.email,
    );

    result.fold((failure) => emit(AuthError(failure.message)), (success) async {
      if (success) {
        final userResult = await getCurrentUserUseCase();
        userResult.fold((failure) => emit(AuthError(failure.message)), (user) {
          add(CheckAuthStatus());
        });
      } else {
        emit(const AuthError('Registration failed'));
      }
    });
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<MescatStatus> emit,
  ) async {
    emit(Loading());

    final result = await logoutUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (success) => emit(Unauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<MescatStatus> emit,
  ) async {
    emit(Loading());
    if (!haveConnection) {
      emit(const NetworkError('No internet connection'));
      return;
    }
    final result = await getCurrentUserUseCase();

    await result.fold((failure) async => emit(Unauthenticated()), (user) async {
      final client = getIt<Client>();
      await client.roomsLoading;
      await client.accountDataLoading;

      emit(Authenticated(user));
    });
  }
}
