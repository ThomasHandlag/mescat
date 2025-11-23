import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';
import 'package:mescat/features/voip/widgets/screen_select_dialog.dart';

class CallController extends StatelessWidget {
  const CallController({
    super.key,
    required this.voiceMuted,
    required this.videoMuted,
  });

  final bool voiceMuted;
  final bool videoMuted;

  void _onShareScreen(BuildContext context) async {
    if (WebRTC.platformIsDesktop) {
      final source = await showDialog<DesktopCapturerSource>(
        context: context,
        builder: (context) {
          return const ScreenSelectDialog();
        },
      );

      if (source != null) {
        // ignore: use_build_context_synchronously
        context.read<CallBloc>().add(
          ShareScreen.fromSourceId(enable: true, sourceId: source.id),
        );
      }
    } else {
      // ignore: use_build_context_synchronously
      context.read<CallBloc>().add(const ShareScreen(enable: true));
    }
  }

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
              context.read<CallBloc>().add(ToggleVoice(muted: !voiceMuted));
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
          IconButton(
            icon: const Icon(Icons.screen_share),
            onPressed: () {
              _onShareScreen(context);
            },
          ),
        ],
      ),
    );
  }
}
