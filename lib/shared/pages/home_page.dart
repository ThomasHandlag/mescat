import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/core/utils/permission_util.dart';
import 'package:mescat/features/authentication/blocs/auth_bloc.dart';
import 'package:mescat/features/chat/pages/chat_page.dart';
import 'package:mescat/features/rooms/blocs/room_bloc.dart';
import 'package:mescat/features/rooms/widgets/room_list.dart';
import 'package:mescat/features/spaces/blocs/space_bloc.dart';
import 'package:mescat/features/spaces/widgets/space_sidebar.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';
import 'package:mescat/shared/widgets/user_box.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<SpaceBloc>().add(LoadSpaces());
    context.read<RoomBloc>().add(const LoadRooms());
    requirePermissions();
  }

  @override
  void dispose() {
    super.dispose();
    context.read<CallBloc>().add(const LeaveCall());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Platform.isAndroid || Platform.isIOS
          ? _buildMobile()
          : _buildDesktop(),
    );
  }

  Widget _buildMobile() {
    return Container(
      color: const Color.fromARGB(255, 35, 35, 42),
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
          BlocBuilder<MescatBloc, MescatStatus>(
            builder: (context, state) {
              if (state is! Authenticated) {
                return const SizedBox.shrink();
              }
              return BlocBuilder<CallBloc, MCCallState>(
                builder: (context, roomState) {
                  return UserBox(
                    voiceMuted: roomState.voiceMuted,
                    videoMuted: roomState is CallInProgress
                        ? roomState.videoMuted
                        : false,
                    username: state.user.displayName,
                    avatarUrl: state.user.avatarUrl,
                    mutedAll: (roomState.muted),
                    stream: (roomState is CallInProgress)
                        ? roomState.groupSession.backend.localUserMediaStream
                        : null,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop() {
    return Row(
      children: [
        Container(
          color: const Color.fromARGB(255, 35, 35, 42),
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
              BlocBuilder<MescatBloc, MescatStatus>(
                builder: (context, state) {
                  if (state is! Authenticated) {
                    return const SizedBox.shrink();
                  }
                  return BlocBuilder<CallBloc, MCCallState>(
                    builder: (context, roomState) {
                      return UserBox(
                        voiceMuted: roomState.voiceMuted,
                        videoMuted: roomState is CallInProgress
                            ? roomState.videoMuted
                            : false,
                        username: state.user.displayName,
                        avatarUrl: state.user.avatarUrl,
                        mutedAll: roomState.muted,
                        stream: (roomState is CallInProgress)
                            ? roomState
                                  .groupSession
                                  .backend
                                  .localUserMediaStream
                            : null,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(child: ChatPage(parentContext: context)),
      ],
    );
  }
}
