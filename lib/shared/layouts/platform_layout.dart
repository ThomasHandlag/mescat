import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mescat/core/routes/routes.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';
import 'package:mescat/shared/util/widget_overlay_service.dart';
import 'package:mescat/window_scaffold.dart';

class PlatformLayout extends StatelessWidget {
  final Widget child;

  const PlatformLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      return SafeArea(
        child: WidgetOverlayService(
          appContext: context,
          child: WidgetListener(child: child),
        ),
      );
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
        child: SafeArea(
          child: WidgetOverlayService(
            appContext: context,
            child: WidgetListener(child: child),
          ),
        ),
      );
    }
  }
}

class WidgetListener extends StatelessWidget {
  final Widget child;

  const WidgetListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallBloc, MCCallState>(
      listener: (context, state) {
        if (state is! CallInProgress) {
          WidgetOverlayService.hide();
        }
      },
      child: child,
    );
  }
}