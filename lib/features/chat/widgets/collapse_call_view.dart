import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/voip/widgets/call_video.dart';
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
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
                          : McImage(
                              uri: avatarUri,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(40),
                            ),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withAlpha(250 ~/ 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        displayName ?? 'Me',
                        style: Theme.of(context).textTheme.bodyMedium,
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
