// Core constants for the application
class AppConstants {
  // API
  static const String baseUrl = 'https://api.mescat.com';
  static const String apiVersion = 'v1';
  
  // WebSocket
  static const String wsUrl = 'wss://ws.mescat.com';
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_mode';
  
  // Chat
  static const int maxMessageLength = 2000;
  static const int maxFileSize = 8 * 1024 * 1024; // 8MB
  
  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}