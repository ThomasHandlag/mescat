import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class PinnedMessages extends StatelessWidget {
  final List<String> pinnedIds;
  final Room room;

  const PinnedMessages({
    super.key,
    required this.pinnedIds,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pinned Messages')),
      body: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(height: 4),
        itemCount: pinnedIds.length,
        itemBuilder: (context, index) {
          final id = pinnedIds[index];
          return FutureBuilder(
            future: room.getEventById(id),
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(title: Text('Loading...'));
              }

              if (snapshot.data == null) {
                return const ListTile(title: Text('Loading...'));
              }

              final event = snapshot.data!;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Text(
                    event.senderId.isNotEmpty
                        ? event.senderId[1].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                title: Text(event.body),
                subtitle: Text('At ${event.originServerTs}'),
              );
            },
          );
        },
      ),
    );
  }
}
