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
                  return ListView.builder(
                    itemCount: state.spaces.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: SpaceIcon(
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
                          ),
                        );
                      }

                      final space = state.spaces[index - 1];
                      final isSelected = space.spaceId == state.selectedSpaceId;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: SpaceIcon(
                          avatarUrl: space.avatarUrl,
                          label: space.name,
                          isSelected: isSelected,
                          onTap: () {
                            context.read<SpaceBloc>().add(
                              SelectSpace(space.spaceId),
                            );
                          },
                        ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: SpaceIcon(
              icon: Icons.explore,
              label: 'Explore Spaces',
              isSelected: false,
              onTap: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
            child: SpaceIcon(
              icon: Icons.add,
              label: 'Create Space',
              isSelected: false,
              onTap: () {
                _showCreateSpaceDialog(context);
              },
            ),
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
