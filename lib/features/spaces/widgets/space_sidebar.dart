import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/routes/routes.dart';
import 'package:mescat/features/spaces/cubits/space_cubit.dart';
import 'package:mescat/features/spaces/widgets/sidebar_item.dart';
import 'package:mescat/shared/util/mc_dialog.dart';
import 'package:mescat/shared/widgets/input_field.dart';

class SpaceSidebar extends StatelessWidget {
  const SpaceSidebar({super.key, required this.spaces});

  final List<Room> spaces;

  @override
  Widget build(BuildContext context) {
    final tempSpaces = spaces;
    return Container(
      width: 60,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: tempSpaces.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const SidebarItem(
                    icon: Icons.home,
                    name: 'Home',
                    id: '',
                  );
                }

                final space = tempSpaces[index - 1];
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

    showMCAdaptiveDialog(
      context: context,
      title: const Text('Create Space'),
      builder: (dialogContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InputField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Space Name',
              hintText: 'My Awesome Space',
            ),
          ),
          const SizedBox(height: 16),
          InputField(
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () async {
            if (nameController.text.trim().isNotEmpty) {
              context.read<SpaceCubit>().createSpace(
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
    );
  }
}
