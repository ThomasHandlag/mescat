import 'package:flutter/material.dart';

final class FailurePage extends StatelessWidget {
  const FailurePage({
    super.key,
    required this.message,
    this.type = FailureType.network,
  });

  final String message;
  final FailureType type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Info')),
      body: const Center(child: Text('This is the Info Page')),
    );
  }
}

enum FailureType { network }
