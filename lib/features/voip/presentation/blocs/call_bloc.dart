import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mescat/core/notifications/event_pusher.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/features/chat/data/datasources/call_handler.dart';

part 'call_event.dart';
part 'call_state.dart';

class CallBloc extends Bloc<CallEvent, MCCallState> {
  final EventPusher eventPusher;

  final CallHandler callHandler;

  CallBloc({required this.eventPusher, required this.callHandler})
    : super(const CallInitial()) {
    on<JoinCall>(_onJoinCall);
    on<LeaveCall>(_onLeaveCall);
    on<ToggleMute>(_onToggleMute);
    on<ToggleCamera>(_onToggleCamera);
    on<SwitchCamera>(_onSwitchCamera);
    on<ToggleVoice>(_onToggleVoice);
  }

  Future<void> _onJoinCall(JoinCall event, Emitter<MCCallState> emit) async {
    await callHandler.leaveCall();
    final inCall = await callHandler.joinCall(event.roomId);

    final renders = <String, RTCVideoRenderer>{};

    for (var stream in callHandler.callStreams.values) {
      final renderer = RTCVideoRenderer();
      await renderer.initialize();
      renderer.srcObject = stream;
      renders[stream.id] = renderer;
    }

    emit(
      CallInProgress(
        callId: event.roomId,
        voiceOn: inCall,
        roomId: event.roomId,
        renders: renders,
      ),
    );
  }

  Future<void> _onLeaveCall(LeaveCall event, Emitter<MCCallState> emit) async {
    await callHandler.leaveCall();
    emit(const CallInitial());
  }

  Future<void> _onToggleMute(
    ToggleMute event,
    Emitter<MCCallState> emit,
  ) async {
    if (state is CallInProgress) {
      final currentState = state as CallInProgress;
      emit(currentState.copyWith(muted: event.isMuted));
    } else {
      emit(state.copyWith(muted: event.isMuted));
    }
  }

  Future<void> _onToggleVoice(
    ToggleVoice event,
    Emitter<MCCallState> emit,
  ) async {
    if (state is CallInProgress) {
      final currentState = state as CallInProgress;
      emit(currentState.copyWith(voiceOn: event.isVoiceOn));
    } else {
      emit(state.copyWith(voiceOn: event.isVoiceOn));
    }
  }

  Future<void> _onToggleCamera(
    ToggleCamera event,
    Emitter<MCCallState> emit,
  ) async {
    if (state is CallInProgress) {
      final currentState = state as CallInProgress;
      emit(currentState.copyWith(cameraOn: event.isCameraOn));
    }
  }

  Future<void> _onSwitchCamera(
    SwitchCamera event,
    Emitter<MCCallState> emit,
  ) async {}
}
