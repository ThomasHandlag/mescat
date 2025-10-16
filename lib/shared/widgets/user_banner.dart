import 'package:flutter/material.dart';

class UserBanner extends StatelessWidget {
  final String? username;
  final String? avatarUrl;
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: avatarUrl == null ? Colors.grey : null,
            ),
            child: avatarUrl == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
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
                const Text('Idle', style: TextStyle(color: Colors.white70)),
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
