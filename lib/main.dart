import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_vodozemac/flutter_vodozemac.dart' as vod;
import 'package:mescat/core/routes/routes.dart';
import 'package:mescat/features/notifications/blocs/notification_bloc.dart';
import 'package:rive/rive.dart';

// import 'package:mescat/core/utils/app_bloc_observer.dart';
import 'package:mescat/features/home_server/cubits/server_cubit.dart';
import 'package:mescat/features/chat/blocs/chat_bloc.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';
import 'package:mescat/features/members/blocs/member_bloc.dart';
import 'package:mescat/core/themes/app_themes.dart';
import 'package:mescat/features/authentication/blocs/auth_bloc.dart';
import 'package:mescat/features/rooms/blocs/room_bloc.dart';
import 'package:mescat/features/spaces/blocs/space_bloc.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/l10n/mescat_localizations.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:mescat/meta_const.dart';

Future<void> initWeb3Auth() async {
  late final Uri redirectUrl;

  if (Platform.isAndroid) {
    redirectUrl = Uri.parse('mescat://chat');
    // w3a://com.example.w3aflutter/auth
  } else {
    redirectUrl = Uri.parse('com.example.mescat://chat');
    // com.example.w3aflutter://auth
  }

  await Web3AuthFlutter.init(
    Web3AuthOptions(
      clientId: MetaConst.appClientId,
      network: Network.sapphire_devnet,
      redirectUrl: redirectUrl,
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await vod.init();
  await setupDependencyInjection();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.blueAccent),
  );

  await RiveNative.init();

  if (Platform.isAndroid || Platform.isIOS) {
    await initWeb3Auth();
  }
  // Bloc.observer = AppBlocObserver();
  runApp(const MescatBlocProvider());
  if (!Platform.isAndroid && !Platform.isIOS) {
    appWindow.show();
    doWhenWindowReady(() {
      final window = appWindow;
      window.alignment = Alignment.center;
      window.show();
    });
  }
}

final class MescatBlocProvider extends StatelessWidget {
  const MescatBlocProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MescatBloc(
            loginUseCase: getIt(),
            registerUseCase: getIt(),
            logoutUseCase: getIt(),
            getCurrentUserUseCase: getIt(),
            setServerUseCase: getIt(),
            oauthLoginUseCase: getIt(),
          ),
        ),
        BlocProvider(
          create: (context) => ChatBloc(
            getMessagesUseCase: getIt(),
            sendMessageUseCase: getIt(),
            addReactionUseCase: getIt(),
            removeReactionUseCase: getIt(),
            deleteMessageUseCase: getIt(),
            editMessageUseCase: getIt(),
            replyMessageUseCase: getIt(),
            getRoomUseCase: getIt(),
            eventPusher: getIt(),
          ),
        ),
        BlocProvider(
          create: (context) =>
              CallBloc(eventPusher: getIt(), callHandler: getIt()),
        ),
        BlocProvider(create: (context) => ServerCubit()..loadServersList()),
        BlocProvider(
          create: (context) => RoomBloc(
            getRoomsUseCase: getIt(),
            createRoomUseCase: getIt(),
            joinRoomUseCase: getIt(),
            eventPusher: getIt(),
          ),
        ),
        BlocProvider(
          create: (context) => SpaceBloc(
            getSpacesUseCase: getIt(),
            createSpaceUseCase: getIt(),
            eventPusher: getIt(),
          ),
        ),
        BlocProvider(
          create: (context) => MemberBloc(getRoomMembersUseCase: getIt()),
        ),
        BlocProvider(
          create: (context) =>
              NotificationBloc(getNotificationsUseCase: getIt()),
        ),
      ],
      child: const MescatApp(),
    );
  }
}

class MescatApp extends StatelessWidget {
  const MescatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mescat',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: MescatRoutes(
        bloc: context.read<MescatBloc>(),
        roomBloc: context.read<RoomBloc>(),
      ).goRouter,
    );
  }
}
