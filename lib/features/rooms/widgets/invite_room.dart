import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class InviteRoom extends StatelessWidget {
  const InviteRoom({super.key, required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite to Room'),
        leading: const CloseButton(),
      ),
      body: SearchAnchor(
        builder: (context, controller) {
          return SearchBar(
            controller: controller,
            hintText: 'Search users to invite',
            onChanged: (value) => controller.openView(),
          );
        },
        suggestionsBuilder: (context, controller) async {
          try {
            final result = await room.client.searchUserDirectory(
              controller.text,
            );

            return result.results
                .map(
                  (user) => ListTile(
                    title: Text(user.displayName ?? user.userId),
                    subtitle: Text(user.userId),
                    trailing: ElevatedButton(
                      onPressed: () {
                        room.invite(user.userId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Invited ${user.userId}')),
                        );
                      },
                      child: const Text('Invite'),
                    ),
                  ),
                )
                .toList();
          } catch (e) {
            return [];
          }
        },
      ),
    );
  }
}
