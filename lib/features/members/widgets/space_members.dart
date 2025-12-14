import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/shared/widgets/user_banner.dart';

class SpaceMembersList extends StatelessWidget {
  const SpaceMembersList({super.key});

  Client get client => getIt<Client>();

  Future<List<MCUser>> _getRoomMembers(BuildContext context) async {
    final spaceId = GoRouterState.of(context).pathParameters['spaceId'];

    if (spaceId == null) {
      log('No spaceId found in route parameters');
      return [];
    }

    final room = client.getRoomById(spaceId);

    if (room == null) {
      log('No room found with id $spaceId');
      return [];
    }

    final members = await room.requestParticipants();

    return Future.wait(
      members.map((member) async {
        final user = await client.getUserProfile(member.senderId);

        final presence = await client.getPresence(member.senderId);
        final isOnline = presence.presence == PresenceType.online;
        return MCUser(
          displayName: user.displayname,
          userId: member.senderId,
          avatarUrl: user.avatarUrl,
          isOnline: isOnline,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      color: const Color.fromARGB(255, 45, 45, 52),
      width: 250,
      child: FutureBuilder(
        future: _getRoomMembers(context),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: (snapshot.data?.length ?? 0) + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  padding: const EdgeInsets.only(right: 10),
                  height: kToolbarHeight,
                  width: 250,
                  child: Center(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        suffixIcon: const Icon(Icons.search),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(20),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 10,
                        ),
                        isDense: true,
                      ),
                      onSubmitted: (value) {},
                    ),
                  ),
                );
              }

              final member = snapshot.data![index - 1];
              return UserBanner(
                username: member.displayName ?? member.userId,
                avatarUrl: member.avatarUrl,
              );
            },
          );
        },
      ),
    );
  }
}
