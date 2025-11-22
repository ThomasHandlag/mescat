import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/core/routes/stream_routing.dart';
import 'package:mescat/features/authentication/blocs/auth_bloc.dart';
import 'package:mescat/features/authentication/pages/auth_page.dart';
import 'package:mescat/features/chat/blocs/chat_bloc.dart';
import 'package:mescat/features/chat/pages/chat_page.dart';
import 'package:mescat/features/notifications/pages/notification_page.dart';
import 'package:mescat/features/settings/pages/room_setting_page.dart';
import 'package:mescat/features/spaces/pages/explore_space_page.dart';
import 'package:mescat/shared/layouts/app_layout.dart';
import 'package:mescat/shared/pages/home_page.dart';
import 'package:mescat/shared/pages/loading_page.dart';
import 'package:mescat/shared/pages/profile_page.dart';
import 'package:mescat/shared/pages/settings_page.dart';
import 'package:mescat/shared/pages/verify_device_page.dart';
import 'package:mescat/shared/widgets/app_bloc_listener.dart';

final class MescatRoutes {
  static const String auth = '/auth';
  static const String loading = '/';

  static const String space = '/space/:spaceId';
  static const String spaceSettings = '/space/:spaceId/settings';
  static const String exploreSpaces = '/explore-spaces';

  static const String room = '/room/:roomId';
  static const String roomSettings = '/space/:spaceId/room/:roomId/settings';
  static const String directRoom = '/room/:roomId';
  static const String directRoomSettings = '/room/:roomId/settings';

  static const String settings = '/settings';
  static const String profile = '/profile/:userId';
  static const String notifications = '/notifications';
  static const String verifyDevice = '/verify-device';
  static const String home = '/';

  static String spaceRoute(String spaceId) => '/space/$spaceId';
  static String spaceSettingsRoute(String spaceId) =>
      '/space/$spaceId/settings';
  static String roomRoute(String roomId) => '/room/$roomId';
  static String roomSettingsRoute(String spaceId, String roomId) =>
      '/space/$spaceId/room/$roomId/settings';
  static String directRoomRoute(String roomId) => '/room/$roomId';
  static String directRoomSettingsRoute(String roomId) =>
      '/room/$roomId/settings';
  static String profileRoute(String userId) => '/profile/$userId';

  MescatRoutes({required this.bloc})
    : goRouter = GoRouter(
        navigatorKey: _rootNavigatorKey,
        initialLocation: MescatRoutes.loading,
        redirect: (context, state) {
          final authState = bloc.state;

          if (authState is Authenticated) {
            final isLoggingIn = state.matchedLocation == MescatRoutes.auth;
            final isLoading = state.matchedLocation == MescatRoutes.loading;

            if (isLoggingIn || isLoading) {
              return '/room/0';
            }
            return null;
          } else if (authState is Unauthenticated) {
            if (state.matchedLocation == MescatRoutes.auth) {
              return null;
            }
            return MescatRoutes.auth;
          } else {
            return MescatRoutes.loading;
          }
        },
        refreshListenable: StreamRouting([bloc.stream]),
        routes: [
          GoRoute(
            path: MescatRoutes.auth,
            name: 'auth',
            pageBuilder: (context, state) =>
                const MaterialPage(child: AppLayout(child: AuthPage())),
            builder: (context, state) => const AuthPage(),
          ),
          ShellRoute(
            navigatorKey: _shellNavigatorKey,
            pageBuilder: (context, state, child) {
              return MaterialPage(
                child: AppLayout(child: AppBlocListener(child: child)),
              );
            },
            routes: [
              ShellRoute(
                pageBuilder: (context, state, child) {
                  return MaterialPage(child: HomePage(child: child));
                },
                routes: [
                  GoRoute(
                    path: MescatRoutes.room,
                    name: 'room',
                    pageBuilder: (context, state) {
                      final params = state.pathParameters;
                      final roomId = params['roomId'];
                      context.read<ChatBloc>().add(SelectRoom(roomId ?? '0'));
                      return MaterialPage<void>(
                        child: ChatPage(context: context),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: roomSettings,
                        name: 'direct-room-settings',
                        pageBuilder: (context, state) {
                          final extra = state.extra as Map<String, dynamic>?;
                          final room = extra?['room'] as MatrixRoom?;
                          if (room == null) {
                            return const MaterialPage(
                              child: Scaffold(
                                body: Center(child: Text('Room not found')),
                              ),
                            );
                          }
                          return MaterialPage(
                            fullscreenDialog: true,
                            child: RoomSettingPage(room: room),
                          );
                        },
                      ),
                    ],
                  ),
                  // Profile
                  GoRoute(
                    path: 'profile/:userId',
                    name: 'profile',
                    pageBuilder: (context, state) {
                      final userId = state.pathParameters['userId']!;
                      return MaterialPage(
                        fullscreenDialog: true,
                        child: ProfilePage(userId: userId),
                      );
                    },
                  ),
                  GoRoute(
                    path: MescatRoutes.loading,
                    name: 'loading',
                    builder: (context, state) => const LoadingPage(),
                  ),
                ],
              ),
              GoRoute(
                path: MescatRoutes.verifyDevice,
                pageBuilder: (context, state) => const MaterialPage(
                  fullscreenDialog: true,
                  child: VerifyDevicePage(),
                ),
              ),
              GoRoute(
                path: exploreSpaces,
                name: 'explore-spaces',
                pageBuilder: (context, state) => const MaterialPage(
                  fullscreenDialog: true,
                  child: ExploreSpacePage(),
                ),
              ),
              GoRoute(
                path: notifications,
                name: 'notifications',
                pageBuilder: (context, state) => const MaterialPage(
                  fullscreenDialog: true,
                  child: NotificationPage(),
                ),
              ),
              GoRoute(
                path: 'settings',
                name: 'settings',
                pageBuilder: (context, state) => const MaterialPage(
                  fullscreenDialog: true,
                  child: SettingsPage(),
                ),
              ),
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

  final MescatBloc bloc;

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  final GoRouter goRouter;
}
