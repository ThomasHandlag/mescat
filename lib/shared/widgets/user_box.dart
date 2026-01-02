import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:mescat/core/routes/routes.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/features/marketplace/pages/library_page.dart';
import 'package:mescat/features/settings/cubits/nft_usage_cubit.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';
import 'package:mescat/shared/widgets/mc_button.dart';
import 'package:mescat/shared/widgets/user_banner.dart';

class UserBox extends StatelessWidget {
  const UserBox({
    super.key,
    this.mutedAll = true,
    required this.stream,
    required this.voiceMuted,
    required this.videoMuted,
  });

  Client get client => getIt<Client>();

  String get currentUserId => client.userID!;
  String get currentDeviceId => client.deviceID!;

  final bool voiceMuted;
  final bool videoMuted;

  final bool mutedAll;
  final WrappedMediaStream? stream;

  Uint8List _getBytesFromString(String stringBytes) {
    final intList = jsonDecode(stringBytes).map<int>((e) => e as int).toList();
    final Uint8List bytes = Uint8List.fromList(intList);
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: UIConstraints.mSmallPadding,
        left: UIConstraints.mSmallPadding,
        right: UIConstraints.mSmallPadding,
      ),
      child: Container(
        height: stream != null ? 150 : UIConstraints.mMessageInputHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withAlpha(235),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            BlocBuilder<NftUsageCubit, Map<ApplyType, NftUsageItem>>(
              builder: (context, state) {
                final setting = state[ApplyType.userbox];

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
                    child: Lottie.file(File(setting.path), fit: BoxFit.cover),
                  ),
                };
              },
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (stream != null)
                  Expanded(
                    child: Row(
                      spacing: 4,
                      children: [
                        const Text('Voice Connected'),
                        McButton(
                          onPressed: () {
                            context.read<CallBloc>().add(const LeaveCall());
                            final spaceId =
                                GoRouterState.of(
                                  context,
                                ).pathParameters['spaceId'] ??
                                MescatRoutes.home;
                            context.go(MescatRoutes.spaceRoute(spaceId));
                          },
                          child: Icon(Icons.call_end, color: Colors.red[400]),
                        ),
                        McButton(
                          onPressed: () {
                            context.read<CallBloc>().add(
                              ToggleCamera(muted: !videoMuted),
                            );
                          },
                          child: Icon(
                            videoMuted ? Icons.videocam_off : Icons.videocam,
                          ),
                        ),
                      ],
                    ),
                  ),
                FutureBuilder(
                  future: client.getUserProfile(currentUserId),
                  builder: (_, snapshot) {
                    return UserBanner(
                      username: snapshot.data?.displayname,
                      avatarUrl: snapshot.data?.avatarUrl,
                      actions: [
                        McButton(
                          onPressed: () {
                            context.read<CallBloc>().add(
                              ToggleVoice(muted: !voiceMuted),
                            );
                          },
                          child: Icon(voiceMuted ? Icons.mic_off : Icons.mic),
                        ),
                        McButton(
                          onPressed: () {
                            context.read<CallBloc>().add(
                              ToggleMute(isMuted: !mutedAll),
                            );
                          },
                          child: Icon(
                            mutedAll ? Icons.headset_off : Icons.headset,
                          ),
                        ),
                        McButton(
                          onPressed: () {
                            if (Platform.isAndroid || Platform.isIOS) {
                              context.push(MescatRoutes.settings);
                            } else {
                              context.push(MescatRoutes.settingGeneral);
                            }
                          },
                          child: const Icon(Icons.settings),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
