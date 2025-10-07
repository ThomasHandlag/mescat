import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/themes/app_themes.dart';
import 'features/authentication/presentation/pages/auth_page.dart';
import 'shared/pages/home_page.dart';
import 'features/authentication/presentation/blocs/auth_bloc.dart';
import 'features/rooms/presentation/blocs/room_bloc.dart';
import 'features/spaces/presentation/blocs/space_bloc.dart';
import 'dependency_injection.dart';
import 'package:flutter_vodozemac/flutter_vodozemac.dart' as vod;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();

  await vod.init();
  
  // Setup dependency injection
  await setupDependencyInjection();
  
  runApp(const MescatApp());
}

class MescatApp extends StatelessWidget {
  const MescatApp({super.key});

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
          )..add(CheckAuthStatus()),
        ),
        BlocProvider(
          create: (context) => RoomBloc(
            getRoomsUseCase: getIt(),
            getMessagesUseCase: getIt(),
            sendMessageUseCase: getIt(),
            createRoomUseCase: getIt(),
            joinRoomUseCase: getIt(),
          ),
        ),
        BlocProvider(
          create: (context) => SpaceBloc(
            getSpacesUseCase: getIt(),
            createSpaceUseCase: getIt(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Mescat - Matrix Chat',
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: ThemeMode.system,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const HomePage();
            } else if (state is AuthUnauthenticated || state is AuthError) {
              return const AuthPage();
            } else {
              // Loading state
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
        routes: {
          '/auth': (context) => const AuthPage(),
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}
