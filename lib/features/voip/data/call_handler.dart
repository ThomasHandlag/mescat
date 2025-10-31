import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc_impl;
import 'package:logger/logger.dart';
import 'package:matrix/matrix.dart' hide Level;
import 'package:webrtc_interface/webrtc_interface.dart' hide Navigator;
import 'package:mescat/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MescatCallType { group, direct, none }

class CallHandler implements WebRTCDelegate {
  final Client client;
  final SharedPreferences _store;
  final Logger logger = Logger();
  final audioAssetPlayer = AudioPlayer();

  late VoIP voIP;

  final Map<String, MediaStream> _remoteStreams = {};

  final Map<String, MediaStream> _localStreams = {};

  Map<String, MediaStream> get remoteStreams => _remoteStreams;
  Map<String, MediaStream> get localStreams => _localStreams;

  bool _isInCall = false;

  String? _activeRoomId;

  MescatCallType? callState = MescatCallType.none;

  CallSession? _directSession;
  GroupCallSession? _groupSession;

  GroupCallSession? get groupSession => _groupSession;
  CallSession? get callSession => _directSession;

  static bool _voiceOpen = false;
  static bool _headphoneOpen = false;

  static bool get voiceOpen => _voiceOpen;
  static bool get headphoneOpen => _headphoneOpen;

  CallHandler(this.client, this._store) {
    voIP = VoIP(client, this);
    init();
  }

  void init() {
    _voiceOpen = _store.getBool('audio_call') ?? true;
    _headphoneOpen = _store.getBool('headphone_call') ?? true;
  }

  Future<bool> joinGroupCall(String roomId) async {
    init();
    _isInCall = true;
    callState = MescatCallType.group;
    _activeRoomId = roomId;

    final room = client.getRoomById(roomId);

    if (room == null) {
      return false;
    }

    final session = await voIP.fetchOrCreateGroupCall(
      roomId,
      room,
      CallBackend.fromJson({'type': 'mesh'}),
      'm.call',
      'm.room',
    );

    _groupSession = session;

    try {
      await session.enter();
      await audioAssetPlayer.play(
        AssetSource('${Assets.audioAsset}/discord-join.mp3'),
      );
    } catch (e, stackTrace) {
      logger.log(Level.error, 'Failed to join call: $e');
      logger.log(Level.trace, 'Stack trace: $stackTrace');
      return false;
    }

    return _isInCall;
  }

  Future<void> inviteCall() async {
    callState = MescatCallType.direct;
  }

  Future<void> shareScreen() async {
    logger.log(Level.info, 'Sharing screen in room $_activeRoomId');
  }

  Future<void> leaveCall() async {
    if (_isInCall && callState != MescatCallType.none) {
      for (var stream in _remoteStreams.values) {
        await stream.dispose();
      }
      _groupSession?.leave();
      callState = MescatCallType.none;
      _isInCall = false;
      _remoteStreams.clear();
    }
  }

  void toggleVideo() {}

  void toggleAudio() {}

  @override
  MediaDevices get mediaDevices => webrtc_impl.navigator.mediaDevices;

  @override
  bool get canHandleNewCall =>
      voIP.currentCID == null && voIP.currentGroupCID == null;

  @override
  Future<RTCPeerConnection> createPeerConnection(
    Map<String, dynamic> configuration, [
    Map<String, dynamic> constraints = const {},
  ]) => webrtc_impl.createPeerConnection(configuration, constraints);

  @override
  Future<void> handleCallEnded(CallSession session) async {
    await audioAssetPlayer.play(
      AssetSource('${Assets.audioAsset}/discord-leave.mp3'),
    );

    _remoteStreams.clear();
    _isInCall = false;
  }

  @override
  Future<void> handleGroupCallEnded(GroupCallSession session) async {
    await audioAssetPlayer.play(
      AssetSource('${Assets.audioAsset}/discord-leave.mp3'),
    );

    _remoteStreams.clear();
    _isInCall = false;
    callState = MescatCallType.none;
  }

  @override
  Future<void> handleMissedCall(CallSession session) async {
    logger.log(Level.warning, 'Missed call in room ${session.room.id}');
  }

  @override
  Future<void> handleNewCall(CallSession session) async {
    final wLocalStreams = session.getLocalStreams;
    final wRemoteStreams = session.getRemoteStreams;

    for (final stream in wRemoteStreams) {
      if (stream.stream != null) {
        _remoteStreams[stream.id] = stream.stream!;
      }
    }

    for (final stream in wLocalStreams) {
      if (stream.stream != null) {
        _remoteStreams[stream.id] = stream.stream!;
      }
    }
  }

  @override
  Future<void> handleNewGroupCall(GroupCallSession session) async {
    // Handle group calls if supported
    for (var stream in session.backend.userMediaStreams) {
      if (stream.stream != null) {
        _remoteStreams[stream.id] = stream.stream!;
      }
    }
  }

  @override
  bool get isWeb => kIsWeb;

  @override
  EncryptionKeyProvider? get keyProvider => throw UnimplementedError();

  @override
  Future<void> playRingtone() async {
    await audioAssetPlayer.play(
      AssetSource('${Assets.audioAsset}/discord-calling.mp3'),
    );
  }

  @override
  Future<void> registerListeners(CallSession session) async {}

  @override
  Future<void> stopRingtone() async {
    await audioAssetPlayer.stop();
  }
}
