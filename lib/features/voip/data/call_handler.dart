import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc_impl;
import 'package:logger/logger.dart';
import 'package:matrix/matrix.dart' hide Level;
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
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

  String? _activeRoomId;

  CallSession? _directSession;
  GroupCallSession? _groupSession;

  GroupCallSession? get groupSession => _groupSession;
  CallSession? get callSession => _directSession;

  bool voiceMuted = true;
  //
  bool muteAll = false;

  CallHandler(this.client, this._store) {
    voIP = VoIP(client, this);
    init();
  }

  void init() {
    voiceMuted = _store.getBool('audio_call') ?? voiceMuted;
    muteAll = _store.getBool('headphone_call') ?? muteAll;
  }

  Future<Either<CallFailure, GroupCallSession>> joinGroupCall(
    String roomId,
  ) async {
    await leaveCall();
    init();
    final room = client.getRoomById(roomId);

    if (room == null) {
      return left(const CallFailure(message: 'Room not found'));
    }

    final session = await voIP.fetchOrCreateGroupCall(
      roomId,
      room,
      CallBackend.fromJson({'type': 'mesh'}),
      'm.call',
      'm.room',
    );
    // final session = await voIP.fetchOrCreateGroupCall(
    //   roomId,
    //   room,
    //   CallBackend.fromJson({
    //     'type': 'livekit',
    //     'livekit_service_url': 'wss://mescat-u1q7e4nx.livekit.cloud',
    //     'livekit_alias': 'mescat',
    //   }),
    //   'm.call',
    //   'm.room',
    // );

    session.backend.localUserMediaStream?.setAudioMuted(voiceMuted);
    session.backend.localUserMediaStream?.setVideoMuted(true);

    try {
      if (session.state == GroupCallState.entered) {
        await session.leave();
      }
      await session.enter();
      await audioAssetPlayer.play(
        AssetSource('${Assets.audioAsset}/discord-join.mp3'),
      );
    } catch (e, stackTrace) {
      logger.log(Level.error, 'Failed to join call: $e');
      logger.log(Level.trace, 'Stack trace: $stackTrace');
    }
    _groupSession = session;

    return right(session);
  }

  Future<void> inviteCall() async {}

  Future<void> shareScreen() async {
    logger.log(Level.info, 'Sharing screen in room $_activeRoomId');
  }

  Future<void> leaveCall() async {
    _groupSession?.leave();
    _directSession?.hangup(reason: CallErrorCode.userHangup);
    if (groupSession != null) {
      await audioAssetPlayer.play(
        AssetSource('${Assets.audioAsset}/discord-leave.mp3'),
      );
    }
  }

  void setVideoMuted(bool muted) {
    _groupSession?.backend.localUserMediaStream?.setVideoMuted(muted);
  }

  void setAudioMuted(bool muted) {
    _groupSession?.backend.localUserMediaStream?.setAudioMuted(muted);
  }

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
  }

  @override
  Future<void> handleGroupCallEnded(GroupCallSession session) async {
    _activeRoomId = null;
    _groupSession = null;
  }

  @override
  Future<void> handleMissedCall(CallSession session) async {
    logger.log(Level.warning, 'Missed call in room ${session.room.id}');
  }

  @override
  Future<void> handleNewCall(CallSession session) async {
    _activeRoomId = session.room.id;
  }

  @override
  Future<void> handleNewGroupCall(GroupCallSession session) async {
    _activeRoomId = session.room.id;
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
