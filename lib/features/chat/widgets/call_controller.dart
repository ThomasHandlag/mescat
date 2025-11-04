import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';

class CallController extends StatelessWidget {
  const CallController({super.key, required this.stream});

  final WrappedMediaStream stream;

  bool get voiceMuted => stream.audioMuted;
  bool get videoMuted => stream.videoMuted;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(voiceMuted ? Icons.mic_off : Icons.mic),
            onPressed: () {
              context.read<CallBloc>().add(ToggleMute(isMuted: !voiceMuted));
            },
          ),
          IconButton(
            icon: Icon(videoMuted ? Icons.videocam_off : Icons.videocam),
            onPressed: () {
              context.read<CallBloc>().add(ToggleCamera(muted: !videoMuted));
            },
          ),
          IconButton(
            icon: const Icon(Icons.call_end),
            onPressed: () {
              context.read<CallBloc>().add(const LeaveCall());
              if (Platform.isAndroid || Platform.isIOS) {
                Navigator.of(context).pop();
              }
            },
          ),
          IconButton(icon: const Icon(Icons.screen_share), onPressed: () {}),
        ],
      ),
    );
  }
}
