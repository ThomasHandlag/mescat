part of 'call_bloc.dart';

abstract class CallEvent extends Equatable {
  const CallEvent();

  @override
  List<Object?> get props => [];
}

class JoinCall extends CallEvent {
  final Room room;

  const JoinCall({required this.room});

  @override
  List<Object?> get props => [room];
}

class LeaveCall extends CallEvent {
  const LeaveCall();

  @override
  List<Object?> get props => [];
}

class ToggleMute extends CallEvent {
  final bool isMuted;

  const ToggleMute({required this.isMuted});

  @override
  List<Object?> get props => [isMuted];
}

class ToggleVoice extends CallEvent {
  final bool muted;

  const ToggleVoice({required this.muted});

  @override
  List<Object?> get props => [muted];
}

class ToggleCamera extends CallEvent {
  const ToggleCamera({required this.muted});

  final bool muted;

  @override
  List<Object?> get props => [muted];
}

class SwitchCamera extends CallEvent {
  const SwitchCamera();

  @override
  List<Object?> get props => [];
}

class CallMembershipChanged extends CallEvent {
  final List<CallMembership> memberships;

  const CallMembershipChanged({required this.memberships});

  @override
  List<Object?> get props => [memberships];
}
