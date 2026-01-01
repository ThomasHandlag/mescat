import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/core/routes/routes.dart';
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
    final room = client.getRoomById(
      GoRouterState.of(context).pathParameters['spaceId'] ?? '',
    );
    return Container(
      padding: const EdgeInsets.all(4.0),
      color: Theme.of(context).colorScheme.surfaceContainer,
      width: 250,
      child: FutureBuilder(
        future: _getRoomMembers(context),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LinearProgressIndicator());
          }
          return ListView.separated(
            itemCount: (snapshot.data?.length ?? 0) + 1,
            separatorBuilder: (context, _) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  padding: const EdgeInsets.only(right: 10),
                  height: kToolbarHeight - 20,
                  child: Center(
                    child: SearchAnchor(
                      viewConstraints:const BoxConstraints(
                        maxWidth: 250,
                      ),
                      builder: (context, controller) {
                        return SearchBar(
                          controller: controller,
                          onChanged: (value) => controller.openView(),
                          hintText: 'Search',
                        );
                      },
                      suggestionsBuilder: (context, controller) async {
                        final rs = await client.search(Categories(
                          roomEvents: RoomEventsCriteria(searchTerm: controller.text)
                        ));

                        final List<Widget> widgets = [];

                        for (final eventList
                            in rs.searchCategories.roomEvents?.results ??
                                <Result>[]) {
                          final event = Event.fromMatrixEvent(
                            eventList.result!,
                            room!,
                          );

                          widgets.add(
                            ListTile(
                              title: Text(event.body),
                              subtitle: Text(event.senderId),
                              onTap: () {
                                controller.closeView(null);
                                final spaceId =
                                    GoRouterState.of(
                                      context,
                                    ).pathParameters['spaceId'] ??
                                    '0';
                                context.go(
                                  MescatRoutes.roomRoute(spaceId, room.id),
                                );
                              },
                            ),
                          );
                        }

                        return widgets;
                      },
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
