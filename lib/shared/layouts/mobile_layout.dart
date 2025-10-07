import 'package:flutter/material.dart';

class MobileLayout extends StatelessWidget {
  final Widget child;
  const MobileLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mescat'),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: child,
      ),
    );
  }
}