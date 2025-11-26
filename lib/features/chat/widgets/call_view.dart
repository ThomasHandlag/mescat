import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/chat/cubits/call_controller_cubit.dart';
import 'package:mescat/features/chat/widgets/call_controller.dart';
import 'package:mescat/features/chat/widgets/member_grid.dart';
import 'package:mescat/features/rooms/blocs/room_bloc.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';

class CallView extends StatelessWidget {
  const CallView({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          context.read<CallControllerCubit>().toggleVisibility();
        },
        child: MouseRegion(
          onEnter: (event) {
            context.read<CallControllerCubit>().show();
          },
          onExit: (event) {
            context.read<CallControllerCubit>().hide();
          },
          child: Column(
            children: [
              _buildCallHeader(context),
              Expanded(child: _buildVideoCallView()),
              _buildCallController(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallController(BuildContext context) {
    return BlocBuilder<CallBloc, MCCallState>(
      builder: (context, state) {
        if (state is CallInProgress) {
          final localStream = state.groupSession.backend.localUserMediaStream;
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
          return const SizedBox.shrink();
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCallHeader(BuildContext context) {
    return BlocBuilder<CallBloc, MCCallState>(
      builder: (context, state) {
        if (state is CallInProgress) {
          return BlocBuilder<CallControllerCubit, bool>(
            builder: (_, state) {
              if (!state) {
                return const SizedBox(height: 60);
              } else {
                return SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (Platform.isAndroid || Platform.isIOS)
                            IconButton(
                              onPressed: () {
                                onClose();
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.expand_more),
                            ),
                          const Icon(Icons.volume_up),
                          const SizedBox(width: 8),
                          BlocBuilder<RoomBloc, RoomState>(
                            builder: (context, state) {
                              if (state is RoomLoaded) {
                                final roomName =
                                    state.selectedRoom?.name ?? 'Call Chat';
                                return Text(
                                  roomName,
                                  style: const TextStyle(fontSize: 20),
                                );
                              }
                              return const Text(
                                'Call chat',
                                style: TextStyle(fontSize: 20),
                              );
                            },
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble),
                        onPressed: () {},
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.group_add),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        }

        return const SizedBox.shrink();
      },
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