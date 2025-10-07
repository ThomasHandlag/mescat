import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/space_bloc.dart';

class SpaceSidebar extends StatelessWidget {
  const SpaceSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 5,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Home button

          // Spaces list
          Expanded(
            child: BlocBuilder<SpaceBloc, SpaceState>(
              builder: (context, state) {
                if (state is SpaceLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SpaceLoaded) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.spaces.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: _SpaceIcon(
                            icon: Icons.home,
                            label: 'Home',
                            isSelected: state.selectedSpaceId == null || state.selectedSpaceId == '',
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
                        child: _SpaceIcon(
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error loading spaces',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // Add space button
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _SpaceIcon(
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

class _SpaceIcon extends StatelessWidget {
  final String? avatarUrl;
  final IconData? icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SpaceIcon({
    this.avatarUrl,
    this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(isSelected ? 16 : 28),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(76),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: avatarUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(isSelected ? 16 : 28),
                  child: Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildIcon(),
                  ),
                )
              : _buildIcon(),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Icon(
      icon ?? Icons.people,
      color: isSelected ? Colors.white : null,
      size: 28,
    );
  }
}
