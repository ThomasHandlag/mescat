import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/routes/routes.dart';
import 'package:mescat/core/utils/permission_util.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/features/authentication/blocs/auth_bloc.dart';
import 'package:mescat/features/rooms/blocs/room_bloc.dart';
import 'package:mescat/features/rooms/widgets/room_list.dart';
import 'package:mescat/features/spaces/blocs/space_bloc.dart';
import 'package:mescat/features/spaces/widgets/space_sidebar.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';

import 'package:mescat/shared/widgets/user_box.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.child});

  final Widget child;

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
    _syncClient();
  }

  void _syncClient() async {
    final client = getIt<Client>();

    await client.roomsLoading;
    await client.accountDataLoading;
    await client.userDeviceKeysLoading;

    if (client.encryption?.keyManager.enabled == true) {
      if (await client.encryption?.keyManager.isCached() == false ||
          await client.encryption?.crossSigning.isCached() == false ||
          client.isUnknownSession && !mounted) {
        context.push(MescatRoutes.verifyDevice);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Platform.isAndroid || Platform.isIOS
          ? _buildMobile(child: widget.child)
          : _buildDesktop(child: widget.child),
    );
  }

  Widget _buildMobile({required Widget child}) {
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
                builder: (context, callState) {
                  return UserBox(
                    voiceMuted: callState.voiceMuted,
                    videoMuted: callState is CallInProgress
                        ? callState.videoMuted
                        : true,
                    username: state.user.displayName,
                    avatarUrl: state.user.avatarUrl,
                    mutedAll: callState.muted,
                    stream: (callState is CallInProgress)
                        ? callState.groupSession.backend.localUserMediaStream
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

  Widget _buildDesktop({required Widget child}) {
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
                    builder: (context, callState) {
                      return UserBox(
                        voiceMuted: callState.voiceMuted,
                        videoMuted: callState is CallInProgress
                            ? callState.videoMuted
                            : false,
                        username: state.user.displayName,
                        avatarUrl: state.user.avatarUrl,
                        mutedAll: callState.muted,
                        stream: (callState is CallInProgress)
                            ? callState
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
        Expanded(child: child),
      ],
    );
  }
}
