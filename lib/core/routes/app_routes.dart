import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mescat/features/authentication/presentation/blocs/auth_bloc.dart';
import 'package:mescat/features/authentication/presentation/pages/auth_page.dart';
import 'package:mescat/features/chat/presentation/pages/chat_page.dart';
import 'package:mescat/features/settings/presentation/pages/setting_page.dart';
import 'package:mescat/features/user_profile/presentation/pages/profile_page.dart';
import 'package:mescat/shared/pages/home_page.dart';
import 'package:mescat/shared/pages/loading_page.dart';

class AppRoutes {
  // Route paths
  static const String splash = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String settings = '/settings';
  static const String profile = '/profile';

  // Create router configuration
  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: splash,
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authBloc.state;
        final isAuthPage = state.matchedLocation == auth;
        final isSplash = state.matchedLocation == splash;

        // Handle loading state - stay on splash or current page
        if (authState is AuthLoading) {
          if (isSplash) return null;
          return splash;
        }

        // Handle authenticated state
        if (authState is AuthAuthenticated) {
          // If on auth page or splash, redirect to home
          if (isAuthPage || isSplash) return home;
          return null; // Stay on current page
        }

        // Handle unauthenticated state
        if (authState is AuthUnauthenticated || authState is AuthError) {
          // If not on auth page, redirect to auth
          if (!isAuthPage && !isSplash) return auth;
          if (isSplash) return auth;
          return null;
        }

        // Default: stay on splash for initial state
        if (authState is AuthInitial) {
          return splash;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: splash,
          name: 'splash',
          pageBuilder: (context, state) =>
              MaterialPage(key: state.pageKey, child: const LoadingPage()),
        ),
        GoRoute(
          path: auth,
          name: 'auth',
          pageBuilder: (context, state) =>
              MaterialPage(key: state.pageKey, child: const AuthPage()),
        ),
        GoRoute(
          path: home,
          name: 'home',
          pageBuilder: (context, state) =>
              MaterialPage(key: state.pageKey, child: const HomePage()),
          routes: [
            GoRoute(
              path: 'settings',
              name: 'settings',
              pageBuilder: (context, state) =>
                  MaterialPage(key: state.pageKey, child: const SettingPage()),
            ),
            GoRoute(
              path: 'profile',
              name: 'profile',
              pageBuilder: (context, state) =>
                  MaterialPage(key: state.pageKey, child: const ProfilePage()),
            ),
            GoRoute(
              path: chat,
              name: 'chat',
              pageBuilder: (context, state) =>
                  MaterialPage(key: state.pageKey, child: const ChatPage()),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found: ${state.matchedLocation}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper class to convert Stream to Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
