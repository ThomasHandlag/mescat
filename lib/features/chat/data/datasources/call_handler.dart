import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
// ignore: unnecessary_import
import 'package:flutter_webrtc/flutter_webrtc.dart' hide MediaDevices;
import 'package:logger/logger.dart';
import 'package:matrix/matrix.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc_impl;
import 'package:mescat/core/constants/app_constants.dart';

// ignore: depend_on_referenced_packages
import 'package:webrtc_interface/webrtc_interface.dart' hide Navigator;

class CallHandler implements WebRTCDelegate {
  final Client _client;
  final Logger logger = Logger();
  final audioAssetPlayer = AudioPlayer();

  final Map<String, MediaStream> _callStreams = {};

  Map<String, MediaStream> get callStreams => _callStreams;

  bool _isInCall = false;
  String? _activeRoomId;
  String? _activeCallId;

  CallHandler(this._client);

  Future<bool> joinCall(String roomId) async {
    _isInCall = true;
    _activeRoomId = roomId;

    logger.d('Joining call in room $roomId');
    final streamId = '${roomId}_${DateTime.now().millisecondsSinceEpoch}';
    _callStreams[streamId] = await createStream();
    await audioAssetPlayer.play(
      AssetSource('${Assets.audioAsset}/discord-join.mp3'),
    );

    return _isInCall;
  }

  Future<void> shareScreen() async {
    logger.d('Sharing screen in room $_activeRoomId');
    final streamId = 'screen_${DateTime.now().millisecondsSinceEpoch}';
    _callStreams[streamId] = await createStream(userScreen: true);
    // Implement screen sharing logic here
  }

  Future<void> leaveCall() async {
    if (_isInCall && _activeRoomId != null) {
      for (var stream in _callStreams.values) {
        await stream.dispose();
      }
      _isInCall = false;
      _callStreams.clear();

      logger.d('Left call in room $_activeRoomId');
      await audioAssetPlayer.play(
        AssetSource('${Assets.audioAsset}/discord-leave.mp3'),
      );
    }
  }

  Future<MediaStream> createStream({bool userScreen = false}) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {'facingMode': 'user'},
    };

    MediaStream stream = await webrtc_impl.navigator.mediaDevices.getUserMedia(
      mediaConstraints,
    );
    return stream;
  }

  @override
  bool get canHandleNewCall => !_isInCall;

  @override
  Future<RTCPeerConnection> createPeerConnection(
    Map<String, dynamic> configuration, [
    Map<String, dynamic> constraints = const {},
  ]) => webrtc_impl.createPeerConnection(configuration, constraints);

  @override
  Future<void> handleCallEnded(CallSession session) async {
    logger.d('Call ended: ${session.callId}');

    await audioAssetPlayer.play(AssetSource('${Assets.audioAsset}/discord-leave.mp3'));
    if (_activeCallId == session.callId) {}
  }

  @override
  Future<void> handleGroupCallEnded(GroupCallSession session) async {
    logger.d('Group call ended: ${session.groupCallId}');
    if (_activeRoomId == session.room.id) {}
  }

  @override
  Future<void> handleMissedCall(CallSession session) async {
    logger.d('Missed call in room ${session.room.id}');
    // Notify the user of a missed call if needed
  }

  @override
  Future<void> handleNewCall(CallSession session) async {
    logger.d('New call in room ${session.room.id}');

    // This is called when a new call is received through Matrix
    if (_isInCall) {
      // If already in a call, reject this one
      await session.reject();
      return;
    }

    _activeCallId = session.callId;
    _activeRoomId = session.room.id;

    // Assume it's a video call for now - in a production app,
    // we would inspect the SDP to determine if it's video or audio only
  }

  @override
  Future<void> handleNewGroupCall(GroupCallSession session) async {
    logger.d('New group call in room ${session.room.id}');
    // Handle group calls if supported
  }

  @override
  bool get isWeb => kIsWeb;

  @override
  EncryptionKeyProvider? get keyProvider => null;

  @override
  Future<void> playRingtone() async {
    // Play ringtone for incoming call
    await audioAssetPlayer.play(AssetSource('${Assets.audioAsset}/discord-calling.mp3'));
  }

  @override
  Future<void> registerListeners(CallSession session) async {
    logger.d('Registering listeners for call ${session.callId}');

    try {
      // The Matrix SDK's CallSession has various event streams we can listen to
      session.onCallStateChanged.stream.listen((state) {
        logger.d('Call state changed for call ${session.callId}');

        // Simply monitor state changes for now
        // In a real implementation, we would react to specific states
      });

      // In a complete implementation, you would handle other call events
      // like audio/video streams, remote state changes, etc.
    } catch (e) {
      logger.e('Error registering call session listeners: $e');
    }
  }

  @override
  Future<void> stopRingtone() async {
    // Stop the ringtone when the call is answered or rejected
    logger.d('Stopping ringtone');
    await audioAssetPlayer.stop();
  }

  @override
  MediaDevices get mediaDevices => webrtc_impl.navigator.mediaDevices;
}
