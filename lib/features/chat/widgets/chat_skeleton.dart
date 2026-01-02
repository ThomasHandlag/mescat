import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatSkeleton extends StatelessWidget {
  const ChatSkeleton({super.key});


  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      enableSwitchAnimation: true,
      child: ListView.builder(
        itemCount: 6,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return Container(
            color: Theme.of(context).colorScheme.surface,
            child: ListTile(
              title: Text('Item number $index as title'),
              subtitle: const Text('Subtitle here'),
              leading: const Icon(Icons.ac_unit, size: 32),
            ),
          );
        },
      ),
    );
  }
}
