part of 'call_bloc.dart';

abstract class MCCallState extends Equatable {
  final bool voiceMuted;
  final bool muted;

  const MCCallState({this.voiceMuted = false, this.muted = false});

  @override
  List<Object?> get props => [voiceMuted, muted];

  MCCallState copyWith({bool? voiceMuted, bool? muted});
}

class CallIdle extends MCCallState {
  const CallIdle({super.voiceMuted = false, super.muted = false});

  @override
  MCCallState copyWith({bool? voiceMuted, bool? muted}) {
    return const CallIdle(voiceMuted: false, muted: false);
  }
}

class CallInProgress extends MCCallState {
  final String callId;
  final String roomId;
  final List<CallParticipant> participants;
  final GroupCallSession groupSession;
  final bool videoMuted;
  final MatrixRoom mRoom;

  const CallInProgress({
    required this.callId,
    super.voiceMuted = false,
    required this.roomId,
    super.muted = false,
    this.participants = const [],
    required this.groupSession,
    this.videoMuted = false,
    required this.mRoom,
  });

  @override
  List<Object?> get props => [
    callId,
    voiceMuted,
    roomId,
    muted,
    participants,
    groupSession,
    videoMuted,
    mRoom,
  ];

  @override
  CallInProgress copyWith({
    String? callId,
    bool? voiceMuted,
    String? roomId,
    bool? isVideoCall,
    bool? muted,
    bool? videoMuted,
    List<CallParticipant>? participants,
    MatrixRoom? mRoom,
    GroupCallSession? groupSession,
  }) {
    return CallInProgress(
      callId: callId ?? this.callId,
      voiceMuted: voiceMuted ?? this.voiceMuted,
      roomId: roomId ?? this.roomId,
      muted: muted ?? this.muted,
      participants: participants ?? this.participants,
      groupSession: groupSession ?? this.groupSession,
      videoMuted: videoMuted ?? this.videoMuted,
      mRoom: mRoom ?? this.mRoom,
    );
  }
}

class CallLoading extends MCCallState {
  final String callId;

  const CallLoading({
    required this.callId,
    super.voiceMuted = false,
    super.muted = false,
  });

  @override
  List<Object?> get props => [callId];

  @override
  MCCallState copyWith({bool? voiceMuted, bool? muted}) {
    return CallLoading(callId: callId);
  }
}

class CallFailed extends MCCallState {
  final String error;

  const CallFailed({
    required this.error,
    super.voiceMuted = false,
    super.muted = false,
  });

  @override
  List<Object?> get props => [error];

  @override
  MCCallState copyWith({bool? voiceMuted, bool? muted}) {
    return CallFailed(
      error: error,
      voiceMuted: voiceMuted ?? this.voiceMuted,
      muted: muted ?? this.muted,
    );
  }
}
