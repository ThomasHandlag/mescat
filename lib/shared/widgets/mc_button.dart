import 'package:flutter/material.dart';

class McButton extends StatelessWidget {
  const McButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: onPressed,
        hoverColor: Colors.white.withAlpha(15),
        child: Padding(padding: const EdgeInsets.all(4.0), child: child),
      ),
    );
  }
}
