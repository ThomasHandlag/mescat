import 'package:matrix/matrix.dart';
import 'package:logger/logger.dart';

/// Core Matrix client singleton for handling Matrix protocol communication
class MatrixClientManager {
  final Client client;

  MatrixClientManager(this.client);

  final Logger _logger = Logger();

  /// Login with username and password
  Future<void> login({
    required String username,
    required String password,
  }) async {
    try {
      await client.login(
        LoginType.mLoginPassword,
        identifier: AuthenticationUserIdentifier(user: username),
        password: password,
      );

      _logger.i('Successfully logged in as $username');
    } catch (e, stackTrace) {
      _logger.e('Login failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Register new account
  Future<void> register({
    required String username,
    required String password,
    String? email,
  }) async {
    try {
      await client.register(username: username, password: password);

      _logger.i('Successfully registered user $username');
    } catch (e, stackTrace) {
      _logger.e('Registration failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await client.logout();
      _logger.i('Successfully logged out');
    } catch (e, stackTrace) {
      _logger.e('Logout failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Check if user is logged in
  bool get isLoggedIn => client.isLogged();

  /// Get current user ID
  String? get currentUserId => client.userID;

  /// Get user display name
  Future<String?> get currentUserDisplayName async {
    if (currentUserId == null) return null;
    final profile = await client.getUserProfile(currentUserId!);
    return profile.displayname;
  }

  /// Get user avatar URL
  Future<Uri?>? get currentUserAvatarUrl =>
      client.getAvatarUrl(currentUserId ?? '');

  /// Start syncing with the homeserver
  Future<void> startSync() async {
    if (isLoggedIn) {
      client.backgroundSync = true;
      _logger.i('Started Matrix sync');
    }
  }

  /// Stop syncing
  void stopSync() {
    client.backgroundSync = false;
    _logger.i('Stopped Matrix sync');
  }

  /// Dispose client resources
  Future<void> dispose() async {
    stopSync();
    await client.dispose();
    _logger.i('Matrix client disposed');
  }
}
