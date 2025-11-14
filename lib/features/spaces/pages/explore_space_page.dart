import 'package:flutter/material.dart';

class ExploreSpacePage extends StatelessWidget {
  const ExploreSpacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore Spaces')),
      body: const Center(child: Text('Explore Space Page Content')),
    );
  }
}
