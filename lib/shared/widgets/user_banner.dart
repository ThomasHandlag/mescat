import 'package:flutter/material.dart';
import 'package:mescat/shared/util/extensions.dart';
import 'package:mescat/shared/util/string_util.dart';
import 'package:mescat/shared/widgets/mc_image.dart';

class UserBanner extends StatelessWidget {
  final String? username;
  final Uri? avatarUrl;
  final List<Widget>? actions;

  const UserBanner({
    super.key,
    required this.username,
    required this.avatarUrl,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = username?.generateFromString();
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(0x42),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: badgeColor,
            child: avatarUrl == null
                ? Text(
                    getInitials(username ?? 'Unknown User'),
                    style: TextStyle(
                      fontSize: 14,
                      color: badgeColor != null
                          ? badgeColor.getContrastingTextColor()
                          : Colors.white,
                    ),
                  )
                : McImage(
                    uri: avatarUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(20),
                  ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 150,
                  child: Text(
                    username ?? 'Unknown User',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Text('Idle', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const Spacer(),
          ...?actions,
        ],
      ),
    );
  }
}
