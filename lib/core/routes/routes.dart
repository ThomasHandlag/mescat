import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/features/authentication/pages/auth_page.dart';
import 'package:mescat/features/chat/blocs/chat_bloc.dart';
import 'package:mescat/features/chat/pages/chat_page.dart';
import 'package:mescat/features/notifications/pages/notification_page.dart';
import 'package:mescat/features/spaces/pages/explore_space_page.dart';
import 'package:mescat/features/spaces/pages/space_home.dart';
import 'package:mescat/features/wallet/pages/meta_login_page.dart';
import 'package:mescat/features/wallet/pages/user_wallet_page.dart';
import 'package:mescat/features/wallet/pages/create_wallet_page.dart';
import 'package:mescat/shared/layouts/main_layout.dart';
import 'package:mescat/shared/layouts/platform_layout.dart';
import 'package:mescat/shared/pages/home_page.dart';
import 'package:mescat/shared/pages/loading_page.dart';
import 'package:mescat/shared/pages/settings_page.dart';

final class MescatRoutes {
  static const String auth = '/auth';
  static const String sync = '/';

  static const String exploreSpaces = '/explore-spaces';

  static const String space = '/space/:spaceId';
  static const String room = '/space/:spaceId/room/:roomId';

  static const String roomSettings = '/settings/roomId';
  static const String settings = '/settings';
  static const String profile = '/profile/:userId';
  static const String notifications = '/notifications';
  static const String verifyDevice = '/verify-device';
  static const String home = '/home';

  static const String walletAuth = '/wallet-auth';
  static const String wallet = '/wallet';
  static const String createWallet = '/create-wallet';

  static String spaceRoute(String spaceId) => '/space/$spaceId';
  static String roomRoute(String spaceId, String roomId) =>
      '/space/$spaceId/room/$roomId';

  static String profileRoute(String userId) => '/profile/$userId';

  static bool loggedIn() => client.isLogged();

  static Client get client => getIt<Client>();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'Main Navigator');

  static final GlobalKey<NavigatorState> walletNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'Wallet Navigator');

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: MescatRoutes.auth,
    refreshListenable: AuthStreams(),
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final loggedIn = MescatRoutes.loggedIn();
      if (!loggedIn && state.path != MescatRoutes.auth) {
        return MescatRoutes.auth;
      } else if (loggedIn && state.path == MescatRoutes.auth) {
        return MescatRoutes.sync;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: MescatRoutes.auth,
        name: 'auth',
        redirect: (context, state) => loggedIn() ? MescatRoutes.sync : null,
        pageBuilder: (context, state) =>
            const MaterialPage(child: PlatformLayout(child: AuthPage())),
      ),
      GoRoute(
        path: MescatRoutes.wallet,
        name: 'wallet',
        redirect: (context, state) => loggedIn() ? null : MescatRoutes.auth,
        pageBuilder: (context, state) =>
            const MaterialPage(child: PlatformLayout(child: UserWalletPage())),
        routes: [
          GoRoute(
            path: MescatRoutes.createWallet,
            name: 'create-wallet',
            redirect: (context, state) => loggedIn() ? null : MescatRoutes.auth,
            pageBuilder: (context, state) => const MaterialPage(
              child: PlatformLayout(child: CreateWalletPage()),
            ),
          ),
        ],
      ),
      GoRoute(
        path: MescatRoutes.walletAuth,
        name: 'wallet-auth',
        redirect: (context, state) => loggedIn() ? null : MescatRoutes.auth,
        pageBuilder: (context, state) =>
            const MaterialPage(child: PlatformLayout(child: MetaLoginPage())),
      ),

      GoRoute(
        path: MescatRoutes.notifications,
        name: 'notifications',
        redirect: (context, state) => loggedIn() ? null : MescatRoutes.auth,
        pageBuilder: (context, state) => const MaterialPage(
          child: PlatformLayout(child: NotificationPage()),
        ),
      ),
      GoRoute(
        path: MescatRoutes.exploreSpaces,
        name: 'explore-spaces',
        redirect: (context, state) => loggedIn() ? null : MescatRoutes.auth,
        pageBuilder: (context, state) => const MaterialPage(
          child: PlatformLayout(child: ExploreSpacePage()),
        ),
      ),
      GoRoute(
        path: MescatRoutes.settings,
        name: 'settings',
        redirect: (context, state) => loggedIn() ? null : MescatRoutes.auth,
        pageBuilder: (context, state) =>
            const MaterialPage(child: PlatformLayout(child: SettingsPage())),
      ),
      if (Platform.isAndroid || Platform.isIOS)
        GoRoute(
          path: MescatRoutes.room,
          name: 'room',
          pageBuilder: (context, state) {
            final params = state.pathParameters;
            final roomId = params['roomId'];
            final spaceId = params['spaceId'] ?? '0';
            context.read<ChatBloc>().add(SelectRoom(roomId ?? '0'));
            return MaterialPage<void>(
              child: PlatformLayout(child: ChatPage(spaceId: spaceId)),
            );
          },
        ),
      GoRoute(
        path: MescatRoutes.sync,
        name: 'sync',
        builder: (context, state) => const LoadingPage(),
      ),
      StatefulShellRoute.indexedStack(
        redirect: (context, state) => loggedIn() ? null : MescatRoutes.auth,
        builder: (context, state, child) {
          return PlatformLayout(child: MainLayout(child: child));
        },
        branches: [
          // StatefulShellBranch(
          //   initialLocation: MescatRoutes.sync,
          //   routes: [
          //     GoRoute(
          //       path: MescatRoutes.sync,
          //       name: 'sync',
          //       builder: (context, state) => const LoadingPage(),
          //     ),
          //   ],
          // ),
          StatefulShellBranch(
            initialLocation: MescatRoutes.home,
            routes: [
              GoRoute(
                path: home,
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
              GoRoute(
                path: space,
                name: 'space',
                builder: (context, state) => const SpaceHome(),
              ),
              if (!Platform.isAndroid && !Platform.isIOS)
                GoRoute(
                  path: MescatRoutes.room,
                  name: 'room',
                  pageBuilder: (context, state) {
                    final params = state.pathParameters;
                    final roomId = params['roomId'];
                    final spaceId = params['spaceId'] ?? '0';
                    context.read<ChatBloc>().add(SelectRoom(roomId ?? '0'));
                    return MaterialPage<void>(
                      child: ChatPage(spaceId: spaceId),
                    );
                  },
                ),
              // GoRoute(
              //   path: 'profile/:userId',
              //   name: 'profile',
              //   pageBuilder: (context, state) {
              //     final userId = state.pathParameters['userId']!;
              //     return MaterialPage(
              //       fullscreenDialog: true,
              //       child: ProfilePage(userId: userId),
              //     );
              //   },
              // ),
            ],
          ),
          // GoRoute(
          //   path: MescatRoutes.verifyDevice,
          //   pageBuilder: (context, state) => const MaterialPage(
          //     fullscreenDialog: true,
          //     child: VerifyDevicePage(),
          //   ),
          // ),
          // GoRoute(
          //   path: exploreSpaces,
          //   name: 'explore-spaces',
          //   pageBuilder: (context, state) => const MaterialPage(
          //     fullscreenDialog: true,
          //     child: ExploreSpacePage(),
          //   ),
          // ),
          // GoRoute(
          //   path: notifications,
          //   name: 'notifications',
          //   pageBuilder: (context, state) => const MaterialPage(
          //     fullscreenDialog: true,
          //     child: NotificationPage(),
          //   ),
          // ),
          // GoRoute(
          //   path: 'settings',
          //   name: 'settings',
          //   pageBuilder: (context, state) => const MaterialPage(
          //     fullscreenDialog: true,
          //     child: SettingsPage(),
          //   ),
          // ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(state.error?.toString() ?? 'Unknown error'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}

class AuthStreams extends ChangeNotifier {
  AuthStreams() {
    MescatRoutes.client.onLoginStateChanged.stream.listen((event) {
      notifyListeners();
    });
  }
}
