import 'package:go_router/go_router.dart';
import 'package:mescat/features/authentication/presentation/pages/auth_page.dart';
import 'package:mescat/features/chat/presentation/pages/chat_page.dart';
import 'package:mescat/features/user_profile/presentation/pages/profile_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';
  static const String chat = '/chat';
  static const String profile = '/profile';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(path: login, builder: (context, state) => const AuthPage()),

      GoRoute(
        path: chat,
        builder: (context, state) {
          final serverId = state.uri.queryParameters['serverId'];
          final channelId = state.uri.queryParameters['channelId'];
          return ChatPage(serverId: serverId ?? '', channelId: channelId ?? '');
        },
      ),
      GoRoute(path: profile, builder: (context, state) => const ProfilePage()),
    ],
  );
}
