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
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : const Color(0xFF808080),
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
              : icon != null
              ? _buildIcon()
              : _buildText(),
        ),
      ),
    );
  }

  Widget _buildText() {
    return Center(
      child: Text(
        icon == null
            ? _getInitials(label)
            : String.fromCharCode(icon!.codePoint),
        style: const TextStyle(fontSize: 14),
        textAlign: TextAlign.center,
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

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return '?';
  }
}
