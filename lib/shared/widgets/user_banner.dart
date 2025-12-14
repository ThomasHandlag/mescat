import 'package:flutter/material.dart';
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
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 70, 70, 70),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            child: avatarUrl == null
                ? Text(
                    getInitials(username ?? 'Unknown User'),
                    style: const TextStyle(fontSize: 14),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                ),
                const Text('Idle', style: TextStyle(color: Colors.white70, fontSize: 12)),
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
