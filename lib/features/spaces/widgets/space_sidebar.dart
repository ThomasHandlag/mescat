import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/routes/routes.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/features/spaces/widgets/sidebar_item.dart';

class SpaceSidebar extends StatelessWidget {
  const SpaceSidebar({super.key});

  Client get client => getIt<Client>();
  List<Room> get spaces => client.rooms.where((room) => room.isSpace).toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: spaces.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const SidebarItem(
                    icon: Icons.home,
                    name: 'Home',
                    id: '',
                  );
                }

                final space = spaces[index - 1];
                return SidebarItem(
                  avatarUrl: space.avatar,
                  name: space.name,
                  id: space.id,
                );
              },
            ),
          ),
          if (Platform.isAndroid || Platform.isIOS) ...[
            SidebarItem(
              icon: Icons.notifications,
              name: 'Notifications',
              id: '',
              onTap: () => context.push(MescatRoutes.notifications),
            ),
            const SizedBox(height: 8),
            SidebarItem(
              icon: Icons.wallet,
              name: 'Wallet',
              id: '',
              onTap: () => context.push(MescatRoutes.wallet),
            ),
            const SizedBox(height: 8),
          ],
          SidebarItem(
            icon: Icons.explore,
            name: 'Explore Spaces',
            id: '',
            onTap: () => context.push(MescatRoutes.exploreSpaces),
          ),
          const SizedBox(height: 8),
          SidebarItem(
            icon: Icons.add,
            name: 'Create Space',
            id: '',
            onTap: () => _showCreateSpaceDialog(context),
          ),
        ],
      ),
    );
  }

  void _showCreateSpaceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Space'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Space Name',
                hintText: 'My Awesome Space',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'What\'s this space about?',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                await client.createSpace(
                  name: nameController.text.trim(),
                  topic: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
