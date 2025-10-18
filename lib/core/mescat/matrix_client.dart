import 'package:matrix/matrix.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Core Matrix client singleton for handling Matrix protocol communication
class MatrixClientManager {
  final Client client;
  final SharedPreferences store;

  MatrixClientManager(this.client, this.store);

  final Logger logger = Logger();

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
}
