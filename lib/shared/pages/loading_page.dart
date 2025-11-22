import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:mescat/features/authentication/blocs/auth_bloc.dart';
import 'package:rive/rive.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MescatBloc>().add(InitialEvent());
    });
  }

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
