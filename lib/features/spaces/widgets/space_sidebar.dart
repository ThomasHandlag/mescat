import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/spaces/widgets/space_icon.dart';
import 'package:mescat/features/spaces/blocs/space_bloc.dart';

class SpaceSidebar extends StatelessWidget {
  const SpaceSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(60),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: BlocBuilder<SpaceBloc, SpaceState>(
              builder: (context, state) {
                if (state is SpaceLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is SpaceLoaded) {
                  return ListView.separated(
                    itemCount: state.spaces.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return SpaceIcon(
                          icon: Icons.home,
                          label: 'Home',
                          isSelected:
                              state.selectedSpaceId == null ||
                              state.selectedSpaceId == '',
                          onTap: () {
                            context.read<SpaceBloc>().add(
                              const SelectSpace(''),
                            );
                          },
                        );
                      }

                      final space = state.spaces[index - 1];
                      final isSelected = space.spaceId == state.selectedSpaceId;

                      return SpaceIcon(
                        avatarUrl: space.avatarUrl,
                        label: space.name,
                        isSelected: isSelected,
                        onTap: () {
                          context.read<SpaceBloc>().add(
                            SelectSpace(space.spaceId),
                          );
                        },
                      );
                    },
                  );
                }

                if (state is SpaceError) {
                  return Center(
                    child: Icon(
                      Icons.error_outline,
                      size: 24,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          SpaceIcon(
            icon: Icons.explore,
            label: 'Explore Spaces',
            isSelected: false,
            onTap: () {},
          ),
          const SizedBox(height: 8),
          SpaceIcon(
            icon: Icons.add,
            label: 'Create Space',
            isSelected: false,
            onTap: () {
              _showCreateSpaceDialog(context);
            },
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
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                context.read<SpaceBloc>().add(
                  CreateSpace(
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                  ),
                );
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
