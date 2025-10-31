/// Matrix Configuration Constants
class MatrixConfig {
  // Default homeserver configurations
  static const String defaultHomeserver = 'https://matrix.org';
  static const String defaultClientName = 'MescatApp';

  // Application identifiers
  static const String appName = 'Mescat';
  static const String appVersion = '1.0.0';

  // Database configuration
  static const String databaseName = 'mescat_matrix.db';

  // Sync settings
  static const Duration syncTimeout = Duration(seconds: 30);
  static const Duration syncRetryDelay = Duration(seconds: 5);
  static const int maxSyncRetries = 3;

  // Room settings
  static const int maxRoomNameLength = 100;
  static const int maxRoomTopicLength = 500;
  static const int maxMessageLength = 4096;

  // File upload settings
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const List<String> supportedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
  ];

  static const List<String> supportedVideoTypes = [
    'video/mp4',
    'video/webm',
    'video/quicktime',
  ];

  static const List<String> supportedAudioTypes = [
    'audio/mp3',
    'audio/wav',
    'audio/ogg',
    'audio/m4a',
  ];

  // Encryption settings
  static const bool enableE2EE = true;
  static const Duration deviceKeyRotationInterval = Duration(days: 7);

  // Voice/Video call settings
  static const List<String> stunServers = [
    'stun:stun.l.google.com:19302',
    'stun:stun1.l.google.com:19302',
  ];

  // Notification settings
  static const String notificationChannelId = 'mescat_messages';
  static const String notificationChannelName = 'Messages';

  // Rate limiting
  static const Duration messageSendCooldown = Duration(milliseconds: 500);
  static const int maxMessagesPerMinute = 60;

  // UI settings
  static const int maxVisibleMessages = 100;
  static const Duration typingIndicatorTimeout = Duration(seconds: 10);

  // Matrix event types for Discord-like features
  static const String eventTypeServerCreate = 'm.space.create';
  static const String eventTypeChannelCreate = 'm.room.create';
  static const String eventTypeVoiceChannel = 'm.room.voice_channel';
  static const String eventTypeTextChannel = 'm.room.text_channel';
  static const String eventTypeCategory = 'm.room.category';

  // Custom state event types
  static const String stateTypeServerInfo = 'io.mescat.server.info';
  static const String stateTypeChannelInfo = 'io.mescat.channel.info';
  static const String stateTypeUserRoles = 'io.mescat.user.roles';
  static const String stateTypePermissions = 'io.mescat.permissions';
  static const String appLink = 'dev.mescat.org';
}

final class MatrixEventTypes {
  static const msc3401 = 'org.matrix.msc3401.call.member';
}
