import 'package:flutter/material.dart';

class PCLayout extends StatelessWidget {
  final Widget child;
  const PCLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Container(),
          ),
          // Main content area
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.background,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
