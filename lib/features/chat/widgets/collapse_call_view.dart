import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/chat/widgets/call_video.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';
import 'package:mescat/shared/util/string_util.dart';
import 'package:mescat/shared/widgets/mc_image.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

class CollapseCallView extends StatelessWidget {
  const CollapseCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: Center(
        child: BlocBuilder<CallBloc, MCCallState>(
          builder: (context, state) {
            if (state is CallInProgress) {
              final stream = state.groupSession.backend.localUserMediaStream;
              final avatarUri = stream?.avatarUrl;
              final displayName = stream?.displayName;

              return Stack(
                alignment: Alignment.center,
                children: [
                  if (stream?.videoMuted == true)
                    CircleAvatar(
                      radius: 40,

                      child: avatarUri == null
                          ? Text(
                              displayName != null
                                  ? getInitials(displayName)
                                  : '',
                            )
                          : McImage(uri: avatarUri),
                    )
                  else
                    CallVideo(
                      stream: state.groupSession.backend.localUserMediaStream,
                      fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        displayName ?? 'Me',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
