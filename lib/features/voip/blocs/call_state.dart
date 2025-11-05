part of 'call_bloc.dart';

abstract class MCCallState extends Equatable {
  final bool voiceOn;
  final bool muted;

  const MCCallState({this.voiceOn = false, this.muted = false});

  @override
  List<Object?> get props => [voiceOn, muted];

  MCCallState copyWith({bool? voiceOn, bool? muted});
}

class CallIdle extends MCCallState {
  const CallIdle({super.voiceOn = false, super.muted = false});

  @override
  MCCallState copyWith({bool? voiceOn, bool? muted}) {
    return const CallIdle(voiceOn: false, muted: false);
  }
}

class CallInProgress extends MCCallState {
  final String callId;
  final String roomId;
  final List<CallParticipant> participants;
  final GroupCallSession groupSession;
  final bool videoOn;
  final MatrixRoom mRoom;

  const CallInProgress({
    required this.callId,
    super.voiceOn = false,
    required this.roomId,
    super.muted = false,
    this.participants = const [],
    required this.groupSession,
    this.videoOn = false,
    required this.mRoom,
  });

  @override
  List<Object?> get props => [
    callId,
    voiceOn,
    roomId,
    muted,
    participants,
    groupSession,
    videoOn,
    mRoom,
  ];

  @override
  CallInProgress copyWith({
    String? callId,
    bool? voiceOn,
    String? roomId,
    bool? isVideoCall,
    bool? muted,
    bool? cameraOn,
    List<CallParticipant>? participants,
    MatrixRoom? mRoom,
    GroupCallSession? groupSession,
    bool? videoOn,
  }) {
    return CallInProgress(
      callId: callId ?? this.callId,
      voiceOn: voiceOn ?? this.voiceOn,
      roomId: roomId ?? this.roomId,
      muted: muted ?? this.muted,
      participants: participants ?? this.participants,
      groupSession: groupSession ?? this.groupSession,
      videoOn: videoOn ?? this.videoOn,
      mRoom: mRoom ?? this.mRoom,
    );
  }
}

class CallLoading extends MCCallState {
  final String callId;

  const CallLoading({
    required this.callId,
    super.voiceOn = false,
    super.muted = false,
  });

  @override
  List<Object?> get props => [callId];

  @override
  MCCallState copyWith({bool? voiceOn, bool? muted}) {
    return CallLoading(callId: callId);
  }
}

class CallFailed extends MCCallState {
  final String error;

  const CallFailed({
    required this.error,
    super.voiceOn = false,
    super.muted = false,
  });

  @override
  List<Object?> get props => [error];

  @override
  MCCallState copyWith({bool? voiceOn, bool? muted}) {
    return CallFailed(
      error: error,
      voiceOn: voiceOn ?? this.voiceOn,
      muted: muted ?? this.muted,
    );
  }
}
