import 'package:flutter/material.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:mescat/features/settings/presentation/pages/setting_page.dart';
import 'package:mescat/shared/util/mc_dialog.dart';
import 'package:mescat/shared/widgets/mc_button.dart';
import 'package:mescat/shared/widgets/user_banner.dart';

class UserBox extends StatefulWidget {
  const UserBox({super.key, required this.username, required this.avatarUrl});

  final String? username;
  final String? avatarUrl;

  @override
  State<UserBox> createState() => _UserBoxState();
}

class _UserBoxState extends State<UserBox> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _voiceEnabled = false;
  bool _headphonesEnabled = false;
  bool _joinedVoice = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: UIConstraints.smallPadding,
        left: UIConstraints.smallPadding,
        right: UIConstraints.smallPadding,
      ),
      child: Container(
        height: _joinedVoice ? 150 : UIConstraints.mMessageInputHeight,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 70, 70, 70),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_joinedVoice)
              const Expanded(
                child: Row(
                  spacing: 4,
                  children: [
                    Text(
                      'Voice Connected',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            UserBanner(
              username: widget.username,
              avatarUrl: widget.avatarUrl,
              actions: [
                McButton(
                  onPressed: () {
                    setState(() {
                      _voiceEnabled = !_voiceEnabled;
                    });
                  },
                  child: Icon(_voiceEnabled ? Icons.mic : Icons.mic_off),
                ),
                McButton(
                  onPressed: () {
                    setState(() {
                      _headphonesEnabled = !_headphonesEnabled;
                    });
                  },
                  child: Icon(
                    _headphonesEnabled ? Icons.headset : Icons.headset_off,
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
