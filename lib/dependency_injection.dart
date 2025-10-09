import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/mescat/matrix_client.dart';
import 'package:mescat/core/mescat/data/repositories/mescat_repository_impl.dart';
import 'package:mescat/core/mescat/domain/repositories/matrix_repository.dart';
import 'package:mescat/core/mescat/domain/usecases/mescat_usecases.dart';
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
  getIt.registerLazySingleton<MCRepository>(
    () => MCRepositoryImpl(getIt<MatrixClientManager>()),
  );

  // Add other dependencies here as they are implemented
  // Example:
  // getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<MCRepository>()),
  );
  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(getIt<MCRepository>()),
  );
  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<MCRepository>()),
  );
  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(getIt<MCRepository>()),
  );
  getIt.registerLazySingleton<CreateRoomUseCase>(
    () => CreateRoomUseCase(getIt<MCRepository>()),
  );
  getIt.registerLazySingleton<GetRoomsUseCase>(
    () => GetRoomsUseCase(getIt<MCRepository>()),
  );
  getIt.registerLazySingleton<GetMessagesUseCase>(
    () => GetMessagesUseCase(getIt<MCRepository>()),
  );
  getIt.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(getIt<MCRepository>()),
  );
  getIt.registerLazySingleton<CreateSpaceUseCase>(
    () => CreateSpaceUseCase(getIt<MCRepository>()),
  );
  getIt.registerLazySingleton<GetSpacesUseCase>(
    () => GetSpacesUseCase(getIt<MCRepository>()),
  );
  getIt.registerLazySingleton<JoinRoomUseCase>(
    () => JoinRoomUseCase(getIt<MCRepository>()),
  );
  getIt.registerLazySingleton<AddReactionUseCase>(
    () => AddReactionUseCase(getIt<MCRepository>()),
  );
  getIt.registerLazySingleton<GetRoomMembersUseCase>(
    () => GetRoomMembersUseCase(getIt<MCRepository>()),
  );
}
