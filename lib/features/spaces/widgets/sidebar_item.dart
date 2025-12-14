import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mescat/core/routes/routes.dart';
import 'package:mescat/shared/util/extensions.dart';
import 'package:mescat/shared/widgets/mc_image.dart';

class SidebarItem extends StatelessWidget {
  final Uri? avatarUrl;
  final IconData? icon;
  final String name;
  final String id;
  final VoidCallback? onTap;

  const SidebarItem({
    super.key,
    this.avatarUrl,
    this.icon,
    required this.name,
    required this.id,
    this.onTap,
  });

  bool get _useGenerateColor => avatarUrl == null && icon == null;
  bool get _isHome => id.isEmpty;

  void _handleTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
    } else {
      if (_isHome) {
        context.go(MescatRoutes.home);
      } else {
        context.go(MescatRoutes.spaceRoute(id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = _isHome && onTap == null
        ? GoRouterState.of(context).uri.path == MescatRoutes.home
        : GoRouterState.of(context).pathParameters['spaceId'] == id;
    return Tooltip(
      message: name,
      child: GestureDetector(
        onTap: () => _handleTap(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _useGenerateColor
                ? avatarUrl != null
                      ? null
                      : name.generateFromString()
                : Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: avatarUrl != null
              ? CircleAvatar(
                  radius: 10,
                  child: McImage(
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    uri: avatarUrl!,
                    borderRadius: BorderRadius.circular(10),
                  ),
                )
              : icon != null
              ? _buildIcon(isSelected)
              : _buildText(),
        ),
      ),
    );
  }

  Widget _buildText() {
    return Center(
      child: Text(
        icon == null
            ? _getInitials(name)
            : String.fromCharCode(icon!.codePoint),
        style: const TextStyle(fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildIcon(bool isSelected) {
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
