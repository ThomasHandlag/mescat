import 'package:flutter/material.dart';

class McButton extends StatelessWidget {
  const McButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.selected = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.border = const Border(),
    this.padding = const EdgeInsets.all(4),
  });

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool selected;
  final BorderRadius borderRadius;
  final Border border;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: border, borderRadius: borderRadius),
      child: Material(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onPressed,
          hoverColor: Colors.white.withAlpha(15),
          child: Padding(
            padding: padding,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
