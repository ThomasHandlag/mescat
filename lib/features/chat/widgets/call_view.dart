import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mescat/features/authentication/blocs/auth_bloc.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';
import 'package:mescat/shared/util/string_util.dart';

class CallView extends StatefulWidget {
  const CallView({super.key});

  @override
  State<CallView> createState() => _CallViewState();
}

class _CallViewState extends State<CallView> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() => _isHovered = true);
      },
      onExit: (event) {
        setState(() => _isHovered = false);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildVideoCallView(),
            ),
            if (_isHovered &&
                (Platform.isWindows || Platform.isLinux || Platform.isMacOS))
              BlocBuilder<CallBloc, MCCallState>(
                builder: (context, state) {
                  if (state is CallInProgress) {
                    return _buildCallControls();
                  }
                  return const SizedBox.shrink();
                },
              )
            else
              BlocBuilder<CallBloc, MCCallState>(
                builder: (context, state) {
                  if (state is CallInProgress) {
                    return _buildCallControls();
                  }
                  return const SizedBox.shrink();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCallView() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: BlocBuilder<CallBloc, MCCallState>(
        builder: (context, state) {
          if (state is CallInProgress) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
                mainAxisExtent: 300,
              ),
              itemCount: state.renders.length, // Example: 4 participants
              itemBuilder: (context, index) {
                final isVideo = state.cameraOn;

                if (isVideo) {
                  return Container(
                    color: Colors.black,
                    child: RTCVideoView(
                      state.renders.values.elementAt(index),
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                    ),
                  );
                }

                return BlocBuilder<MescatBloc, MescatStatus>(
                  builder: (context, state) {
                    String? avatarUrl;
                    String? username;

                    if (state is Authenticated) {
                      avatarUrl = state.user.avatarUrl;
                      username = state.user.displayName;
                    }

                    return Container(
                      color: Colors.grey[900],
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: avatarUrl != null
                                  ? NetworkImage(avatarUrl)
                                  : null,
                              child: avatarUrl == null
                                  ? Text(
                                      username != null
                                          ? getInitials(username)
                                          : '',
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              username ?? 'Unknown User',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const Center(child: Text('No active call'));
        },
      ),
    );
  }

  Widget _buildCallControls() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 0.1,
            offset: Offset(0, 0.1),
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.volume_up),
                    Text('Call chat', style: TextStyle(fontSize: 20)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.chat_bubble),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.mic), onPressed: () {}),
                BlocBuilder<CallBloc, MCCallState>(
                  builder: (context, state) {
                    final cameraOn = state is CallInProgress
                        ? state.cameraOn
                        : true;
                    return IconButton(
                      icon: Icon(
                        cameraOn ? Icons.videocam : Icons.videocam_off,
                      ),
                      onPressed: () {
                        context.read<CallBloc>().add(const ToggleCamera());
                      },
                    );
                  },
                ),
                IconButton(icon: const Icon(Icons.call_end), onPressed: () {
                  context.read<CallBloc>().add(const LeaveCall());
                }),
                IconButton(
                  icon: const Icon(Icons.screen_share),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
