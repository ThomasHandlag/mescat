import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/matrix/matrix_client.dart';
import 'package:mescat/core/matrix/data/repositories/matrix_repository_impl.dart';
import 'package:mescat/core/matrix/domain/repositories/matrix_repository.dart';
import 'package:mescat/core/matrix/domain/usecases/matrix_usecases.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/network/network_service.dart';

final GetIt getIt = GetIt.instance;

final Logger _logger = Logger();

Future<Client> createMatrixClient(String clientName, String homeserverUrl) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    sqfliteFfiInit();

    final client = Client(
      clientName,
      database: await MatrixSdkDatabase.init(
        clientName,
        database: await databaseFactoryFfi.openDatabase(
          '${directory.path}/database.sqlite',
        ),
      ),
      supportedLoginTypes: {
        AuthenticationTypes.password,
        AuthenticationTypes.sso,
      },
    );

    // Set homeserver URL
    await client.checkHomeserver(Uri.parse(homeserverUrl));

    return client;
  } catch (e, stackTrace) {
    _logger.e(
      'Failed to initialize Matrix client',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}

Future<void> setupDependencyInjection() async {
  final matrixClient = await createMatrixClient("Mescat", "https://matrix.org");
  // Regist core dependencies
  getIt.registerLazySingleton<NetworkService>(() => NetworkService());
  getIt.registerLazySingleton<MatrixClientManager>(
    () => MatrixClientManager(matrixClient),
  );
  getIt.registerLazySingleton<MatrixRepository>(
    () => MatrixRepositoryImpl(getIt<MatrixClientManager>()),
  );

  // Add other dependencies here as they are implemented
  // Example:
  // getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<MatrixRepository>()),
  );
  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(getIt<MatrixRepository>()),
  );
  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<MatrixRepository>()),
  );
  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(getIt<MatrixRepository>()),
  );
  getIt.registerLazySingleton<CreateRoomUseCase>(
    () => CreateRoomUseCase(getIt<MatrixRepository>()),
  );
  getIt.registerLazySingleton<GetRoomsUseCase>(
    () => GetRoomsUseCase(getIt<MatrixRepository>()),
  );
  getIt.registerLazySingleton<GetMessagesUseCase>(
    () => GetMessagesUseCase(getIt<MatrixRepository>()),
  );
  getIt.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(getIt<MatrixRepository>()),
  );
  getIt.registerLazySingleton<CreateSpaceUseCase>(
    () => CreateSpaceUseCase(getIt<MatrixRepository>()),
  );
  getIt.registerLazySingleton<GetSpacesUseCase>(
    () => GetSpacesUseCase(getIt<MatrixRepository>()),
  );
  getIt.registerLazySingleton<JoinRoomUseCase>(
    () => JoinRoomUseCase(getIt<MatrixRepository>()),
  );
  getIt.registerLazySingleton<AddReactionUseCase>(
    () => AddReactionUseCase(getIt<MatrixRepository>()),
  );
}
