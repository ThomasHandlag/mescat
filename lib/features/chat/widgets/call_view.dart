import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/chat/widgets/call_controller.dart';
import 'package:mescat/features/chat/widgets/member_grid.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';

class CallView extends StatelessWidget {
  const CallView({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight, bottom: 80),
            child: _buildVideoCallView(),
          ),

          BlocBuilder<CallBloc, MCCallState>(
            builder: (context, state) {
              if (state is CallInProgress) {
                final localStream =
                    state.groupSession.backend.localUserMediaStream;
                if (localStream != null) {
                  return StreamBuilder(
                    stream: state.groupSession.matrixRTCEventStream.stream,
                    builder: (_, _) => CallController(
                      videoMuted: state.videoMuted,
                      voiceMuted: state.voiceMuted,
                      screenStream: state.groupSession.backend.localScreenshareStream,
                      onClose: onClose,
                    ),
                  );
                }
              }
              return const SizedBox(height: 40);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCallView() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: BlocBuilder<CallBloc, MCCallState>(
        builder: (context, state) {
          if (state is CallInProgress) {
            return StreamBuilder(
              stream: state.groupSession.matrixRTCEventStream.stream,
              builder: (context, snapshot) {
                return MemberGridView(
                  participants: state.groupSession.participants,
                );
              },
            );
          } else if (state is CallLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text('No active call'));
          }
        },
      ),
    );
  }
}
