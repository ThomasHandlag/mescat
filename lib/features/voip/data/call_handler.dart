import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc_impl;
import 'package:logger/logger.dart';
import 'package:matrix/matrix.dart' hide Level;
// import 'package:mescat/core/encryption/mc_encryption_provider.dart';
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
  final String audioStoreKey = 'audio_call';
  final String muteStoreKey = 'headphone_call';
  // final McEncryptionProvider encryptionProvider = McEncryptionProvider(); //livekit backend does not implement yet

  late VoIP voIP;

  String? _activeRoomId;

  CallSession? _directSession;
  GroupCallSession? _groupSession;

  GroupCallSession? get groupSession => _groupSession;
  CallSession? get callSession => _directSession;

  bool get muteAll => _store.getBool(muteStoreKey) ?? false;

  bool get voiceMuted => _store.getBool(audioStoreKey) ?? true;

  CallHandler(this.client, this._store) {
    voIP = VoIP(client, this);
  }

  Future<Either<CallFailure, GroupCallSession>> joinGroupCall(
    String roomId,
  ) async {
    await leaveCall();
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
    //     "livekit_alias": "!qoQQTYnzXOHSdEgqQp:im.staging.famedly.de",
    //     "livekit_service_url": "https://famedly-livekit-server.teedee.dev/jwt",
    //     "type": "livekit",
    //   }),
    //   'm.call',
    //   'm.room',
    // );
    _groupSession = session;
    try {
      if (_groupSession!.state == GroupCallState.entered) {
        await _groupSession!.leave();
      }
      await _groupSession!.enter();
      await audioAssetPlayer.play(
        AssetSource('${Assets.audioAsset}/discord-join.mp3'),
      );
      await setAudioMuted(voiceMuted);
      await setVideoMuted(true);
    } catch (e, stackTrace) {
      logger.log(Level.error, 'Failed to join call: $e');
      logger.log(Level.trace, 'Stack trace: $stackTrace');
    }

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

  Future<void> setVideoMuted(bool muted) async {
    await _groupSession?.backend.setDeviceMuted(
      _groupSession!,
      muted,
      MediaInputKind.videoinput,
    );
  }

  Future<void> setAudioMuted(bool muted) async {
    await _store.setBool(audioStoreKey, muted);
    await _groupSession?.backend.setDeviceMuted(
      _groupSession!,
      muted,
      MediaInputKind.audioinput,
    );
  }

  Future<void> enableShareScreen(bool enable, String sourceId) async {
    if (_groupSession != null) {
      try {
        if (enable) {
          await _groupSession!.backend.setScreensharingEnabled(
            _groupSession!,
            enable,
            sourceId,
          );
        } else {
          await _groupSession!.backend.setScreensharingEnabled(
            _groupSession!,
            enable,
            sourceId,
          );
        }
      } catch (e, stackTrace) {
        logger.log(Level.error, 'Failed to toggle screen sharing: $e');
        logger.log(Level.trace, 'Stack trace: $stackTrace');
      }
    }
  }

  Future<void> setMuteAll(bool muted) async {
    await _store.setBool(muteStoreKey, muted);
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
  // EncryptionKeyProvider? get keyProvider => encryptionProvider; livekit backend does not implement yet

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
