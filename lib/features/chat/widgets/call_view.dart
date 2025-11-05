import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/chat/widgets/call_controller.dart';
import 'package:mescat/features/chat/widgets/member_grid.dart';
import 'package:mescat/features/rooms/blocs/room_bloc.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';

class CallView extends StatefulWidget {
  const CallView({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<CallView> createState() => _CallViewState();
}

class _CallViewState extends State<CallView> {
  bool _focusView = Platform.isAndroid || Platform.isIOS ? true : false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          setState(() => _focusView = !_focusView);
        },
        child: MouseRegion(
          onEnter: (event) {
            setState(() => _focusView = false);
          },
          onExit: (event) {
            setState(() => _focusView = true);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                if (_focusView)
                  const SizedBox(height: 40)
                else
                  BlocBuilder<CallBloc, MCCallState>(
                    builder: (context, state) {
                      if (state is! CallInProgress) {
                        return const SizedBox(height: 40);
                      }
                      return SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (Platform.isAndroid || Platform.isIOS)
                                  IconButton(
                                    onPressed: () {
                                      widget.onClose();
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
                                          state.selectedRoom?.name ??
                                          'Call Chat';
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
                    },
                  ),
                Expanded(child: _buildVideoCallView()),
                if (_focusView)
                  const SizedBox(height: 40)
                else
                  BlocBuilder<CallBloc, MCCallState>(
                    builder: (context, state) {
                      if (state is CallInProgress) {
                        final localStream =
                            state.groupSession.backend.localUserMediaStream!;
                        return CallController(stream: localStream);
                      }
                      return const SizedBox(height: 40);
                    },
                  ),
              ],
            ),
          ),
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
            return MemberGridView(participants: state.participants);
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
