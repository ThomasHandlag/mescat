import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:mescat/features/settings/pages/setting_page.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';
import 'package:mescat/shared/util/mc_dialog.dart';
import 'package:mescat/shared/widgets/mc_button.dart';
import 'package:mescat/shared/widgets/user_banner.dart';

class UserBox extends StatelessWidget {
  const UserBox({
    super.key,
    required this.username,
    required this.avatarUrl,
    this.joinedVoice = false,
    this.voiceEnabled = true,
    this.headphonesEnabled = true,
  });

  final String? username;
  final String? avatarUrl;
  final bool joinedVoice;
  final bool voiceEnabled;
  final bool headphonesEnabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: UIConstraints.smallPadding,
        left: UIConstraints.smallPadding,
        right: UIConstraints.smallPadding,
      ),
      child: Container(
        height: joinedVoice ? 150 : UIConstraints.mMessageInputHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (joinedVoice)
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
                        context.read<CallBloc>().add(const ToggleCamera());
                      },
                      child: BlocBuilder<CallBloc, MCCallState>(
                        builder: (context, state) {
                          final cameraOn = state is CallInProgress
                              ? state.cameraOn
                              : true;
                          return Icon(
                            cameraOn ? Icons.videocam : Icons.videocam_off,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            UserBanner(
              username: username,
              avatarUrl: avatarUrl,
              actions: [
                McButton(
                  onPressed: () {
                    context.read<CallBloc>().add(
                      ToggleVoice(isVoiceOn: !voiceEnabled),
                    );
                  },
                  child: Icon(voiceEnabled ? Icons.mic : Icons.mic_off),
                ),
                McButton(
                  onPressed: () {
                    context.read<CallBloc>().add(
                      ToggleMute(isMuted: !headphonesEnabled),
                    );
                  },
                  child: Icon(
                    headphonesEnabled ? Icons.headset : Icons.headset_off,
                  ),
                ),
                McButton(
                  onPressed: () {
                    showFullscreenDialog(context, const SettingPage());
                  },
                  child: const Icon(Icons.settings),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
