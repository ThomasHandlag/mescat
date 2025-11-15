import 'package:flutter/material.dart';

class ExpanseChannel extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  const ExpanseChannel({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
  });

  @override
  State<ExpanseChannel> createState() => _ExpanseChannelState();
}

class _ExpanseChannelState extends State<ExpanseChannel> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        expansionAnimationStyle: AnimationStyle.noAnimation,
        initiallyExpanded: _isExpanded,
        tilePadding: const EdgeInsets.all(4),
        childrenPadding: const EdgeInsets.all(0),
        visualDensity: const VisualDensity(vertical: -4),
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(0x99),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              _isExpanded ? Icons.expand_more : Icons.chevron_right,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(0x99),
            ),
          ],
        ),
        trailing: widget.trailing,
        children: widget.children,
      ),
    );
  }
}
