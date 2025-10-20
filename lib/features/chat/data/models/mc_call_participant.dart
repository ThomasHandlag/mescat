import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class MCCallParticipant extends Equatable {
  final String userId;
  final String displayName;
  final RTCVideoRenderer? renderer;
  final bool isMuted;
  final bool isCameraOn;
  final bool isScreenSharing;
  
  const MCCallParticipant({
    required this.userId,
    required this.displayName,
    this.renderer,
    this.isMuted = false,
    this.isCameraOn = true,
    this.isScreenSharing = false,
  });
  
  @override
  List<Object?> get props => [
    userId, 
    displayName, 
    renderer, 
    isMuted, 
    isCameraOn,
    isScreenSharing
  ];
  
  MCCallParticipant copyWith({
    String? userId,
    String? displayName,
    RTCVideoRenderer? renderer,
    bool? isMuted,
    bool? isCameraOn,
    bool? isScreenSharing,
  }) {
    return MCCallParticipant(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      renderer: renderer ?? this.renderer,
      isMuted: isMuted ?? this.isMuted,
      isCameraOn: isCameraOn ?? this.isCameraOn,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
    );
  }
}