import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_vodozemac/flutter_vodozemac.dart' as vod;
import 'package:matrix/matrix.dart';
import 'package:rive/rive.dart';

import 'package:mescat/core/mescat/matrix_client.dart';
import 'package:mescat/features/authentication/presentation/pages/auth_page.dart';
import 'package:mescat/features/chat/presentation/blocs/chat_bloc.dart';
import 'package:mescat/features/voip/presentation/blocs/call_bloc.dart';
import 'package:mescat/shared/pages/home_page.dart';
import 'package:mescat/shared/pages/loading_page.dart';
import 'package:mescat/features/members/presentation/blocs/member_bloc.dart';
import 'package:mescat/core/themes/app_themes.dart';
import 'package:mescat/features/authentication/presentation/blocs/auth_bloc.dart';
import 'package:mescat/features/rooms/presentation/blocs/room_bloc.dart';
import 'package:mescat/features/spaces/presentation/blocs/space_bloc.dart';
import 'package:mescat/dependency_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await vod.init();
  await setupDependencyInjection();
  await RiveNative.init();
  runApp(const MescatBlocProvider());
}

final class MescatBlocProvider extends StatelessWidget {
  const MescatBlocProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            loginUseCase: getIt(),
            registerUseCase: getIt(),
            logoutUseCase: getIt(),
            getCurrentUserUseCase: getIt(),
            setServerUseCase: getIt(),
          )..add(CheckAuthStatus()),
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
            eventPusher: getIt(),
          ),
        ),
        BlocProvider(
          create: (context) =>
              CallBloc(eventPusher: getIt(), callHandler: getIt()),
        ),
        BlocProvider(
          create: (context) => RoomBloc(
            getRoomsUseCase: getIt(),
            // getMessagesUseCase: getIt(),
            // sendMessageUseCase: getIt(),
            createRoomUseCase: getIt(),
            joinRoomUseCase: getIt(),
            // addReactionUseCase: getIt(),
            // removeReactionUseCase: getIt(),
            // deleteMessageUseCase: getIt(),
            // editMessageUseCase: getIt(),
            // replyMessageUseCase: getIt(),
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
          create: (context) => ChatBloc(
            getMessagesUseCase: getIt(),
            sendMessageUseCase: getIt(),
            addReactionUseCase: getIt(),
            removeReactionUseCase: getIt(),
            deleteMessageUseCase: getIt(),
            editMessageUseCase: getIt(),
            replyMessageUseCase: getIt(),
            eventPusher: getIt(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Mescat',
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: ThemeMode.system,
        home: MescatApp(client: getIt<MatrixClientManager>().client),
      ),
    );
  }
}

class MescatApp extends StatelessWidget {
  const MescatApp({super.key, required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const HomePage();
        } else if (state is AuthLoading || state is AuthInitial) {
          return const LoadingPage();
        } else {
          final navigator = Navigator.of(context);
          log('Can pop: ${navigator.canPop()}');
          return const AuthPage();
        }
      },
    );
  }
}
