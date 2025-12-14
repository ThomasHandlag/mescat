import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mescat/core/routes/routes.dart';
import 'package:mescat/window_scaffold.dart';

class PlatformLayout extends StatelessWidget {
  final Widget child;

  const PlatformLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      return SafeArea(child: child);
    } else {
      return WindowScaffold(
        actions: [
          IconButton(
            onPressed: () {
              context.push(MescatRoutes.notifications);
            },
            icon: const Icon(Icons.inbox),
          ),
        ],
        child: SafeArea(child: child),
      );
    }
  }
}
