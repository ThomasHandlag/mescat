import 'package:flutter/material.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:rive/rive.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  final fileLoader = FileLoader.fromAsset(
    '${Assets.riveAsset}/cat.riv',
    riveFactory: Factory.rive,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RiveWidgetBuilder(
        fileLoader: fileLoader,
        builder: (context, state) => switch (state) {
          RiveLoading() => const Center(child: CircularProgressIndicator()),
          RiveFailed() => ErrorWidget.withDetails(
            message: state.error.toString(),
            error: FlutterError(state.error.toString()),
          ),
          RiveLoaded() => RiveWidget(
            controller: state.controller,
            fit: Fit.none,
          ),
        },
      ),
    );
  }
}
