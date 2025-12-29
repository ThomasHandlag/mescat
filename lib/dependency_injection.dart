import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:get_it/get_it.dart';
import 'package:ipfsdart/ipfsdart.dart';
import 'package:logger/logger.dart';
import 'package:matrix/matrix.dart' hide Level;
import 'package:mescat/contracts/contracts.dart';
import 'package:mescat/core/notifications/event_pusher.dart';
import 'package:mescat/features/notifications/data/notification_service.dart';
import 'package:mescat/features/voip/data/call_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mescat/core/mescat/matrix_client.dart';
import 'package:mescat/core/mescat/data/repositories/mescat_repository_impl.dart';
import 'package:mescat/core/mescat/domain/repositories/mescat_repository.dart';
import 'package:mescat/core/mescat/domain/usecases/mescat_usecases.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final GetIt getIt = GetIt.instance;

final Logger _logger = Logger();

Future<Client> createMatrixClient(
  String clientName,
  String homeserverUrl,
) async {
  try {
    final directory = await getApplicationDocumentsDirectory();

    if (Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final client = Client(
      clientName,
      database: await MatrixSdkDatabase.init(
        clientName,
        database: await databaseFactory.openDatabase(
          '${directory.path}/database.sqlite',
        ),
      ),
      supportedLoginTypes: {
        AuthenticationTypes.password,
        AuthenticationTypes.sso,
      },
    );
    await client.init(newHomeserver: Uri.parse(homeserverUrl));
    return client;
  } catch (e, stackTrace) {
    _logger.log(
      Level.error,
      'Failed to initialize Matrix client',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}

Future<void> setupDependencyInjection() async {
  final matrixClient = await createMatrixClient("Mescat", "https://matrix.org");
  final sharedPref = await SharedPreferences.getInstance();
  final appLinks = AppLinks();
  final notificationService = NotificationService();
  final ipfsClient = IpfsClient.init(
    uri: Uri.parse(MescatContracts.ipfsApiUrl),
    authMethod: AuthMethod.bearer,
    password: MescatContracts.ipfsBearer,
  );
  await notificationService.initialize();

  matrixClient;

  getIt.registerSingleton<Client>(matrixClient);
  getIt.registerSingleton<AppLinks>(appLinks);
  getIt.registerSingleton<IpfsClient>(ipfsClient);
  getIt.registerLazySingleton<MatrixClientManager>(
    () => MatrixClientManager(matrixClient, sharedPref),
  );
  getIt.registerSingleton<NotificationService>(notificationService);
  getIt.registerLazySingleton<CallHandler>(
    () => CallHandler(matrixClient, sharedPref),
  );
  getIt.registerLazySingleton<MCRepository>(
    () => MCRepositoryImpl(getIt<MatrixClientManager>()),
  );

  getIt.registerLazySingleton<EventPusher>(
    () => EventPusher(
      clientManager: getIt<MatrixClientManager>(),
      notificationService: getIt<NotificationService>(),
    ),
  );

  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<MCRepository>()),
  );
  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(getIt<MCRepository>()),
  );
  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<MCRepository>()),
  );
  getIt.registerLazySingleton<OAuthLoginUseCase>(
    () => OAuthLoginUseCase(getIt<MCRepository>()),
  );
  getIt.registerLazySingleton<GetRoomUsecase>(
    () => GetRoomUsecase(getIt<MCRepository>()),
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
  getIt.registerLazySingleton<RemoveReactionUseCase>(
    () => RemoveReactionUseCase(getIt<MCRepository>()),
  );
  getIt.registerLazySingleton<DeleteMessageUseCase>(
    () => DeleteMessageUseCase(getIt<MCRepository>()),
  );
  getIt.registerLazySingleton<EditMessageUseCase>(
    () => EditMessageUseCase(getIt<MCRepository>()),
  );
  getIt.registerLazySingleton<ReplyMessageUseCase>(
    () => ReplyMessageUseCase(getIt<MCRepository>()),
  );
  getIt.registerLazySingleton<SetServerUseCase>(
    () => SetServerUseCase(getIt<MCRepository>()),
  );

  // Notification use cases
  getIt.registerLazySingleton<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(getIt<MCRepository>()),
  );
}
