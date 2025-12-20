import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/members/widgets/space_members.dart';
import 'package:mescat/features/rooms/widgets/room_list.dart';
import 'package:mescat/features/spaces/widgets/space_sidebar.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';
import 'package:mescat/shared/widgets/user_box.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (Platform.isAndroid || Platform.isIOS)
          ? _buildMobile(child: child, context: context)
          : _buildDesktop(child: child, context: context),
    );
  }

  Widget _buildMobile({required Widget child, required BuildContext context}) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Row(
              children: [
                SpaceSidebar(),
                Expanded(child: RoomList()),
              ],
            ),
          ),
          BlocBuilder<CallBloc, MCCallState>(
            builder: (context, state) {
              return UserBox(
                voiceMuted: state.voiceMuted,
                videoMuted: state is CallInProgress ? state.videoMuted : true,
                mutedAll: state.muted,
                stream: (state is CallInProgress)
                    ? state.groupSession.backend.localUserMediaStream
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop({required Widget child, required BuildContext context}) {
    return Row(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surfaceContainer,
          width: 310,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    SpaceSidebar(),
                    SizedBox(width: 250, child: RoomList()),
                  ],
                ),
              ),
              BlocBuilder<CallBloc, MCCallState>(
                builder: (context, state) {
                  return UserBox(
                    voiceMuted: state.voiceMuted,
                    videoMuted: state is CallInProgress
                        ? state.videoMuted
                        : true,
                    mutedAll: state.muted,
                    stream: (state is CallInProgress)
                        ? state.groupSession.backend.localUserMediaStream
                        : null,
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(child: child),
        if (!Platform.isAndroid && !Platform.isIOS) const SpaceMembersList(),
      ],
    );
  }
}
