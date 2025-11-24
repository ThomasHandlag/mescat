import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/features/rooms/blocs/room_bloc.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';
import 'package:mescat/features/voip/widgets/screen_select_dialog.dart';

class CallController extends StatefulWidget {
  const CallController({
    super.key,
    required this.voiceMuted,
    required this.videoMuted,
    required this.screenStream,
    required this.onClose,
  });
  final VoidCallback onClose;
  final WrappedMediaStream? screenStream;
  final bool voiceMuted;
  final bool videoMuted;

  @override
  State<CallController> createState() => _CallControllerState();
}

class _CallControllerState extends State<CallController> {
  void _onShareScreen(BuildContext context) async {
    if (WebRTC.platformIsDesktop) {
      final source = await showDialog<DesktopCapturerSource>(
        context: context,
        builder: (context) {
          return const ScreenSelectDialog();
        },
      );

      if (source != null && mounted) {
        // ignore: use_build_context_synchronously
        context.read<CallBloc>().add(
          ShareScreen.fromSourceId(enable: true, sourceId: source.id),
        );
      }
    } else {
      if (mounted) {
        context.read<CallBloc>().add(const ShareScreen(enable: true));
      }
    }
  }

  Future<void> _onScreenClose() async {
    if (mounted) {
      context.read<CallBloc>().add(const ShareScreen(enable: false));
    }
  }

  bool _focusView = Platform.isAndroid || Platform.isIOS ? true : false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        child: Column(
          children: [
            if (_focusView)
              const SizedBox(height: 40)
            else
              BlocBuilder<CallBloc, MCCallState>(
                builder: (context, state) {
                  if (state is! CallInProgress) {
                    return const SizedBox(height: 60);
                  }
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
                },
              ),
            const Spacer(),
            if (_focusView)
               Container(height: 40, color: Theme.of(context).scaffoldBackgroundColor,)
            else
              Container(
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
                      icon: Icon(widget.voiceMuted ? Icons.mic_off : Icons.mic),
                      onPressed: () {
                        context.read<CallBloc>().add(
                          ToggleVoice(muted: !widget.voiceMuted),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        widget.videoMuted ? Icons.videocam_off : Icons.videocam,
                      ),
                      onPressed: () {
                        context.read<CallBloc>().add(
                          ToggleCamera(muted: !widget.videoMuted),
                        );
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
                      icon: Icon(
                        widget.screenStream != null
                            ? Icons.stop_screen_share
                            : Icons.screen_share,
                      ),
                      color: widget.screenStream != null ? Colors.red : null,
                      onPressed: () {
                        if (widget.screenStream != null) {
                          _onScreenClose();
                        } else {
                          _onShareScreen(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
