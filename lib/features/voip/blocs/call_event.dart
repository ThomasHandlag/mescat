part of 'call_bloc.dart';

sealed class CallEvent extends Equatable {
  const CallEvent();

  @override
  List<Object?> get props => [];
}

class JoinCall extends CallEvent {
  final MatrixRoom mRoom;

  const JoinCall({required this.mRoom});

  @override
  List<Object?> get props => [mRoom];
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
final class SwitchCall extends CallEvent {
  const SwitchCall({required this.mRoom});

  final MatrixRoom mRoom;

  @override
  List<Object?> get props => [mRoom];
}
