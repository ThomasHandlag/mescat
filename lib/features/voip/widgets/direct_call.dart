import 'package:flutter/material.dart';

class DirectCallView extends StatelessWidget {
  const DirectCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Call'),
      ),
      body: const Center(
        child: Text('Direct Call Interface'),
      ),
    );
  }
}