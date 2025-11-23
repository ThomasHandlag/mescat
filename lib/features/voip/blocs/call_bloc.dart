import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/core/notifications/event_pusher.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/utils/permission_util.dart';
import 'package:mescat/features/voip/data/call_handler.dart';

part 'call_event.dart';
part 'call_state.dart';

class CallBloc extends Bloc<CallEvent, MCCallState> {
  final EventPusher eventPusher;
  final CallHandler callHandler;
  final Logger logger = Logger();

  CallBloc({required this.eventPusher, required this.callHandler})
    : super(
        CallIdle(
          voiceMuted: callHandler.voiceMuted,
          muted: callHandler.muteAll,
        ),
      ) {
    on<JoinCall>(_onJoinCall);
    on<LeaveCall>(_onLeaveCall);
    on<ToggleMute>(_onToggleMute);
    on<ToggleCamera>(_onToggleCamera);
    on<SwitchCamera>(_onSwitchCamera);
    on<ToggleVoice>(_onToggleVoice);
    on<ShareScreen>(_onShareScreen);
  }

  Future<void> _onJoinCall(JoinCall event, Emitter<MCCallState> emit) async {
    emit(
      CallLoading(
        callId: event.mRoom.room.id,
        voiceMuted: state.voiceMuted,
        muted: state.muted,
      ),
    );
    final result = await callHandler.joinGroupCall(event.mRoom.room.id);

    result.fold(
      (failed) {
        emit(
          CallFailed(
            error: failed.message,
            muted: callHandler.muteAll,
            voiceMuted: callHandler.voiceMuted,
          ),
        );
      },
      (session) {
        emit(
          CallInProgress(
            callId: event.mRoom.room.id,
            roomId: event.mRoom.room.id,
            groupSession: session,
            participants: session.participants,
            voiceMuted: callHandler.voiceMuted,
            muted: callHandler.muteAll,
            mRoom: event.mRoom,
          ),
        );
      },
    );
  }

  Future<void> _onLeaveCall(LeaveCall event, Emitter<MCCallState> emit) async {
    await callHandler.leaveCall();
    if (Platform.isAndroid) {
      await stopForegroundService();
    }
    emit(
      CallIdle(muted: callHandler.muteAll, voiceMuted: callHandler.voiceMuted),
    );
  }

  Future<void> _onToggleMute(
    ToggleMute event,
    Emitter<MCCallState> emit,
  ) async {
    await callHandler.setMuteAll(event.isMuted);
    emit(state.copyWith(muted: callHandler.muteAll));
  }

  Future<void> _onToggleVoice(
    ToggleVoice event,
    Emitter<MCCallState> emit,
  ) async {
    await callHandler.setAudioMuted(event.muted);
    emit(state.copyWith(voiceMuted: event.muted));
  }

  Future<void> _onToggleCamera(
    ToggleCamera event,
    Emitter<MCCallState> emit,
  ) async {
    if (state is CallInProgress) {
      final currentState = state as CallInProgress;
      await callHandler.setVideoMuted(event.muted);
      emit(
        currentState.copyWith(
          groupSession: currentState.groupSession,
          videoMuted: event.muted,
          muted: callHandler.muteAll,
          voiceMuted: callHandler.voiceMuted,
        ),
      );
    }
  }

  Future<void> _onSwitchCamera(
    SwitchCamera event,
    Emitter<MCCallState> emit,
  ) async {}

  // @override
  // Future<void> close() {
  //   return super.close();
  // }

  Future<void> _onShareScreen(
    ShareScreen event,
    Emitter<MCCallState> emit,
  ) async {
    if (state is CallInProgress) {
      if (Platform.isAndroid) {
        await startForegroundService();
      }
      await callHandler.enableShareScreen(event.enable, event.sourceId);
    }
  }
}
