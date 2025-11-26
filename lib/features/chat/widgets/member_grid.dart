import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gridexts/extensions/pin_grid/pin_grid_view.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/features/chat/widgets/call_video.dart';
import 'package:mescat/shared/util/string_util.dart';
import 'package:mescat/shared/widgets/mc_image.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

class _MemberGrid extends StatelessWidget {
  const _MemberGrid({
    super.key,
    this.mainGrid = false,
    required this.stream,
    required this.groupCallSession,
    required this.isActiveSpeaker,
    required this.onTogglePin,
  });

  final bool mainGrid;
  final WrappedMediaStream stream;
  final GroupCallSession groupCallSession;
  final bool isActiveSpeaker;
  final VoidCallback? onTogglePin;

  Uri? get avatarUri => stream.avatarUrl;

  String? get displayName => stream.displayName;

  bool get isLocal => stream.isLocal();

  bool get mirrored =>
      stream.isLocal() && stream.purpose == SDPStreamMetadataPurpose.Usermedia;

  bool get audioMuted => stream.audioMuted;

  bool get videoMuted => stream.videoMuted;

  bool get isScreenSharing =>
      stream.purpose == SDPStreamMetadataPurpose.Screenshare;

  bool get isCurrentUser => stream.isLocal();

  @override
  Widget build(BuildContext context) {
    log('$avatarUri');
    return GestureDetector(
      onDoubleTap: onTogglePin,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border.all(
            color: isActiveSpeaker ? Colors.blue : Colors.grey,
            width: isActiveSpeaker ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              StreamBuilder(
                stream: stream.onMuteStateChanged.stream,
                builder: (context, _) {
                  if (videoMuted) {
                    return CircleAvatar(
                      radius: 40,
                      child: avatarUri == null
                          ? Text(
                              displayName != null
                                  ? getInitials(displayName!)
                                  : '',
                            )
                          : McImage(
                              uri: avatarUri,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(40),
                            ),
                    );
                  } else {
                    return CallVideo(
                      stream: stream,
                      isMirror: mirrored,
                      fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                    );
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    children: [
                      if (isCurrentUser)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('You'),
                        ),
                      const Spacer(),
                      StreamBuilder(
                        stream: stream.onMuteStateChanged.stream,
                        builder: (context, snapshot) {
                          return CircleAvatar(
                            radius: 10,
                            backgroundColor: audioMuted
                                ? Colors.red
                                : Colors.green,
                            child: Icon(
                              audioMuted ? Icons.mic_off : Icons.mic,
                              size: 12,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.black45,
                  ),
                  height: 20,
                  child: Text(
                    displayName ?? 'Unknown User',
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MemberGridView extends StatelessWidget {
  const MemberGridView({super.key, required this.participants});

  final List<CallParticipant> participants;

  Map<WrappedMediaStream, GroupCallSession> get participantStreams {
    final Map<WrappedMediaStream, GroupCallSession> streams = {};
    for (final participant in participants) {
      final groupCall =
          participant.voip.groupCalls[participant.voip.currentGroupCID];
      if (groupCall != null) {
        for (final stream in groupCall.backend.userMediaStreams) {
          streams[stream] = groupCall;
        }
        for (final stream in groupCall.backend.screenShareStreams) {
          streams[stream] = groupCall;
        }
      }
    }
    return streams;
  }

  @override
  Widget build(BuildContext context) {
    return PinGridView<String>(
      maxPinnedItems: 2,
      dimension: 150,
      items: participantStreams.keys.map((e) => e.id).toList(),
      itemBuilder: (context, key, index, isPinned, togglePin) {
        final stream = participantStreams.keys.firstWhere((s) => s.id == key);
        return _MemberGrid(
          key: Key(key),
          groupCallSession: participantStreams[stream]!,
          stream: stream,
          mainGrid: index == 0,
          onTogglePin: togglePin,
          isActiveSpeaker:
              participantStreams[stream]!.backend.activeSpeaker?.userId ==
              stream.participant.userId,
        );
      },
    );
  }
}
