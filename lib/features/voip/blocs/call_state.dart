part of 'call_bloc.dart';

abstract class MCCallState extends Equatable {
  final bool voiceMuted;
  final bool muted;

  const MCCallState({this.voiceMuted = true, this.muted = true});

  @override
  List<Object?> get props => [voiceMuted, muted];

  MCCallState copyWith({bool? voiceMuted, bool? muted});
}

class CallIdle extends MCCallState {
  const CallIdle({super.voiceMuted = true, super.muted = false});

  @override
  List<Object?> get props => [super.voiceMuted, super.muted];

  @override
  CallIdle copyWith({bool? voiceMuted, bool? muted}) {
    return CallIdle(
      voiceMuted: voiceMuted ?? this.voiceMuted,
      muted: muted ?? this.muted,
    );
  }
}

class CallInProgress extends MCCallState {
  final String callId;
  final String roomId;
  final List<CallParticipant> participants;
  final GroupCallSession groupSession;
  final bool videoMuted;
  final Room room;

  const CallInProgress({
    required this.callId,
    super.voiceMuted = false,
    required this.roomId,
    super.muted = false,
    this.participants = const [],
    required this.groupSession,
    this.videoMuted = false,
    required this.room,
  });

  @override
  List<Object?> get props => [
    callId,
    super.voiceMuted,
    roomId,
    super.muted,
    participants,
    groupSession,
    videoMuted,
    room,
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
    Room? room,
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
      room: room ?? this.room,
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
  List<Object?> get props => [callId, super.voiceMuted, super.muted];

  @override
  CallLoading copyWith({bool? voiceMuted, bool? muted}) {
    return CallLoading(
      callId: callId,
      voiceMuted: voiceMuted ?? this.voiceMuted,
      muted: muted ?? this.muted,
    );
  }
}

class CallFailed extends MCCallState {
  final String error;

  const CallFailed({
    required this.error,
    super.voiceMuted = true,
    super.muted = true,
  });

  @override
  List<Object?> get props => [error, super.voiceMuted, super.muted];

  @override
  CallFailed copyWith({bool? voiceMuted, bool? muted}) {
    return CallFailed(
      error: error,
      voiceMuted: voiceMuted ?? this.voiceMuted,
      muted: muted ?? this.muted,
    );
  }
}
