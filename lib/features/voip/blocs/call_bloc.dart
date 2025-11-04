import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/core/notifications/event_pusher.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/features/voip/data/call_handler.dart';

part 'call_event.dart';
part 'call_state.dart';

class CallBloc extends Bloc<CallEvent, MCCallState> {
  final EventPusher eventPusher;
  final CallHandler callHandler;
  final Logger logger = Logger();

  CallBloc({required this.eventPusher, required this.callHandler})
    : super(const CallInitial(voiceOn: false, muted: false)) {
    on<JoinCall>(_onJoinCall);
    on<LeaveCall>(_onLeaveCall);
    on<ToggleMute>(_onToggleMute);
    on<ToggleCamera>(_onToggleCamera);
    on<SwitchCamera>(_onSwitchCamera);
    on<ToggleVoice>(_onToggleVoice);
    on<CallMembershipChanged>(_onCallMembershipChanged);
    eventPusher.eventStream.listen((event) {
      if (event is GroupCallMemberCandidatesEvent) {
        add(CallMembershipChanged(memberships: event.memberships));
      }
    });
  }

  Future<void> _onJoinCall(JoinCall event, Emitter<MCCallState> emit) async {
    await callHandler.leaveCall();

    final joined = await callHandler.joinGroupCall(event.room.id);

    if (joined == null) {
      emit(const CallInitial());
      return;
    }

    final renders = <String, RTCVideoRenderer>{};

    if (callHandler.groupSession?.backend.localUserMediaStream?.stream !=
        null) {
      final renderer = RTCVideoRenderer();
      await renderer.initialize();
      final stream = callHandler.groupSession?.backend.localUserMediaStream;
      renderer.srcObject = stream?.stream;
      renders[stream!.id] = renderer;
    }

    emit(
      CallInProgress(
        callId: event.room.id,
        roomId: event.room.id,
        groupSession: joined,
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
    // callHandler.setAudioMuted(event.isMuted);
  }

  Future<void> _onToggleVoice(
    ToggleVoice event,
    Emitter<MCCallState> emit,
  ) async {
    callHandler.setAudioMuted(event.muted);
  }

  Future<void> _onToggleCamera(
    ToggleCamera event,
    Emitter<MCCallState> emit,
  ) async {
    callHandler.setVideoMuted(event.muted);
  }

  Future<void> _onSwitchCamera(
    SwitchCamera event,
    Emitter<MCCallState> emit,
  ) async {}

  // @override
  // Future<void> close() {
  //   return super.close();
  // }

  Future<void> _onCallMembershipChanged(
    CallMembershipChanged event,
    Emitter<MCCallState> emit,
  ) async {
    if (state is CallInProgress) {
      final currentState = state as CallInProgress;
      emit(
        currentState.copyWith(
          participants: callHandler.groupSession?.participants,
          groupSession: callHandler.groupSession,
        ),
      );
    }
  }
}
