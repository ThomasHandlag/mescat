import 'package:flutter/material.dart';

/// Widget to display a tag/category chip for spaces
class SpaceTagChip extends StatelessWidget {
  final String tag;
  final bool isSmall;
  final VoidCallback? onTap;

  const SpaceTagChip({
    super.key,
    required this.tag,
    this.isSmall = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 8 : 12,
          vertical: isSmall ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          tag,
          style: (isSmall ? textTheme.bodySmall : textTheme.bodyMedium)?.copyWith(
            color: colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
