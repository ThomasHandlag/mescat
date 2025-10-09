import 'package:flutter/material.dart';

class SpaceIcon extends StatelessWidget {
  final String? avatarUrl;
  final IconData? icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SpaceIcon({
    super.key,
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
          width: 40,
          height: 35,
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
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
                  borderRadius: BorderRadius.circular(16),
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
      size: 18,
    );
  }
}
