import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/features/settings/pages/setting_page.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';
import 'package:mescat/shared/util/mc_dialog.dart';
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
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (stream != null)
              Expanded(
                child: Row(
                  spacing: 4,
                  children: [
                    const Text(
                      'Voice Connected',
                      style: TextStyle(color: Colors.white70),
                    ),
                    McButton(
                      onPressed: () {
                        context.read<CallBloc>().add(const LeaveCall());
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
                      child: Icon(mutedAll ? Icons.headset_off : Icons.headset),
                    ),
                    McButton(
                      onPressed: () {
                        showFullscreenDialog(context, const SettingPage());
                      },
                      child: const Icon(Icons.settings),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
