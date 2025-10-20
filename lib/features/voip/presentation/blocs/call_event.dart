part of 'call_bloc.dart';

abstract class CallEvent extends Equatable {
  const CallEvent();

  @override
  List<Object?> get props => [];
}

class JoinCall extends CallEvent {
  final String roomId;

  const JoinCall({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class LeaveCall extends CallEvent {
  final String roomId;

  const LeaveCall({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class ToggleMute extends CallEvent {
  final bool isMuted;

  const ToggleMute({required this.isMuted});

  @override
  List<Object?> get props => [isMuted];
}

class ToggleVoice extends CallEvent {
  final bool isVoiceOn;

  const ToggleVoice({required this.isVoiceOn});

  @override
  List<Object?> get props => [isVoiceOn];
}

class ToggleCamera extends CallEvent {
  final bool isCameraOn;

  const ToggleCamera({required this.isCameraOn});

  @override
  List<Object?> get props => [isCameraOn];
}

class SwitchCamera extends CallEvent {
  const SwitchCamera();

  @override
  List<Object?> get props => [];
}
