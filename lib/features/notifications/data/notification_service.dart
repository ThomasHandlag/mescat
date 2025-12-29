import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mescat/core/constants/app_config.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    AndroidInitializationSettings? androidSettings;
    DarwinInitializationSettings? iosSettings;
    WindowsInitializationSettings? windowsSettings;
    LinuxInitializationSettings? linuxSettings;
    
    if (Platform.isAndroid) {
      androidSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    } else if (Platform.isIOS) {
      iosSettings = const DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
    } else if (Platform.isMacOS) {
      iosSettings = const DarwinInitializationSettings();
    } else if (Platform.isLinux) {
      linuxSettings = const LinuxInitializationSettings(
        defaultActionName: 'Open',
      );
    } else if (Platform.isWindows) {
      windowsSettings = const WindowsInitializationSettings(
        appName: AppConfig.appName,
        appUserModelId: 'mescat.dev',
        guid: '49aa6628-8197-4069-84cd-80a276ff027e',
      );
    }

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
      windows: windowsSettings,
      linux: linuxSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();

    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      if (Platform.isAndroid && await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    } else if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> showMessageNotification({
    required String roomId,
    required String roomName,
    required String senderName,
    required String message,
    required String eventId,
    String? avatarUrl,
  }) async {
    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'messages_channel',
      'Messages',
      description: 'Notifications for new messages',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    // Android notification details
    final androidDetails = AndroidNotificationDetails(
      androidChannel.id,
      androidChannel.name,
      channelDescription: androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: MessagingStyleInformation(
        Person(name: senderName),
        conversationTitle: roomName,
        groupConversation: true,
        messages: [Message(message, DateTime.now(), Person(name: senderName))],
      ),
      category: AndroidNotificationCategory.message,
    );

    // iOS notification details
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Show notification
    await _notifications.show(
      roomId.hashCode, // Use room ID hash as notification ID
      roomName,
      '$senderName: $message',
      notificationDetails,
      payload: '$roomId|$eventId',
    );
  }

  Future<void> showCallNotification({
    required String roomId,
    required String roomName,
    required String callerName,
    required String callId,
    bool isVideo = false,
  }) async {
    const androidChannel = AndroidNotificationChannel(
      'calls_channel',
      'Calls',
      description: 'Notifications for incoming calls',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    final androidDetails = AndroidNotificationDetails(
      androidChannel.id,
      androidChannel.name,
      channelDescription: androidChannel.description,
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.call,
      fullScreenIntent: true,
      ongoing: true,
      actions: [
        const AndroidNotificationAction(
          'accept',
          'Accept',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'decline',
          'Decline',
          showsUserInterface: false,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      callId.hashCode,
      'Incoming ${isVideo ? 'Video' : 'Voice'} Call',
      '$callerName is calling you in $roomName',
      notificationDetails,
      payload: 'call|$roomId|$callId',
    );
  }

  Future<void> showInviteNotification({
    required String roomId,
    required String roomName,
    required String inviterName,
  }) async {
    const androidChannel = AndroidNotificationChannel(
      'invites_channel',
      'Room Invites',
      description: 'Notifications for room invitations',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    final androidDetails = AndroidNotificationDetails(
      androidChannel.id,
      androidChannel.name,
      channelDescription: androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.social,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _notifications.show(
      roomId.hashCode,
      'Room Invitation',
      '$inviterName invited you to $roomName',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'invite|$roomId',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    final parts = payload.split('|');
    final type = parts[0];

    switch (type) {
      case 'call':
        // Handle call notification tap
        // Navigate to call screen
        break;
      case 'invite':
        // Handle invite notification tap
        // Navigate to room invitation
        break;
      default:
        // Handle message notification tap
        // Navigate to chat room
        break;
    }
  }
}
