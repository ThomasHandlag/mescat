import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:mescat/features/marketplace/pages/library_page.dart';
import 'package:mescat/features/members/widgets/space_members.dart';
import 'package:mescat/features/rooms/widgets/room_list.dart';
import 'package:mescat/features/settings/cubits/nft_usage_cubit.dart';
import 'package:mescat/features/spaces/cubits/space_cubit.dart';
import 'package:mescat/features/spaces/widgets/space_sidebar.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';
import 'package:mescat/shared/widgets/user_box.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  Uint8List _getBytesFromString(String stringBytes) {
    final intList = jsonDecode(stringBytes).map<int>((e) => e as int).toList();
    final Uint8List bytes = Uint8List.fromList(intList);
    return bytes;
  }

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
          Expanded(
            child: Row(
              children: [
                BlocBuilder<SpaceCubit, List<Room>>(
                  builder: (_, state) => SpaceSidebar(spaces: state),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(UIConstraints.mDefaultPadding),
                      ),
                    ),
                    child: Stack(
                      children: [
                        BlocBuilder<
                          NftUsageCubit,
                          Map<ApplyType, NftUsageItem>
                        >(
                          builder: (context, state) {
                            final setting = state[ApplyType.roomlist];

                            if (setting == null) {
                              return const SizedBox.shrink();
                            }

                            return switch (setting.itemType) {
                              ItemType.meta => Positioned.fill(
                                child: Image.memory(
                                  _getBytesFromString(
                                    File(setting.path).readAsStringSync(),
                                  ),
                                  opacity: const AlwaysStoppedAnimation(0.6),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              ItemType.lottie => Positioned.fill(
                                child: Lottie.file(
                                  File(setting.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            };
                          },
                        ),
                        const RoomList(),
                      ],
                    ),
                  ),
                ),
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
              Expanded(
                child: Row(
                  children: [
                    BlocBuilder<SpaceCubit, List<Room>>(
                      builder: (_, state) => SpaceSidebar(spaces: state),
                    ),
                    Container(
                      width: 250,
                      clipBehavior: Clip.hardEdge,
                      padding: const EdgeInsets.only(
                        right: UIConstraints.mSmallPadding,
                      ),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                            UIConstraints.mDefaultPadding,
                          ),
                        ),
                      ),
                      child: Stack(
                        children: [
                          BlocBuilder<
                            NftUsageCubit,
                            Map<ApplyType, NftUsageItem>
                          >(
                            builder: (context, state) {
                              final setting = state[ApplyType.roomlist];

                              if (setting == null) {
                                return const SizedBox.shrink();
                              }

                              return switch (setting.itemType) {
                                ItemType.meta => Positioned.fill(
                                  child: Image.memory(
                                    _getBytesFromString(
                                      File(setting.path).readAsStringSync(),
                                    ),
                                    opacity: const AlwaysStoppedAnimation(0.6),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                ItemType.lottie => Positioned.fill(
                                  child: Lottie.file(
                                    File(setting.path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              };
                            },
                          ),
                          const RoomList(),
                        ],
                      ),
                    ),
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
