import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/routes/routes.dart';
import 'package:mescat/shared/util/permission_util.dart';
import 'package:mescat/dependency_injection.dart';
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
    requirePermissions();
    _syncClient();
  }

  void _syncClient() async {
    final client = getIt<Client>();
    await Future.delayed(const Duration(seconds: 2));
    await client.roomsLoading;
    await client.accountDataLoading;
    await client.userDeviceKeysLoading;

    _goHome();
  }

  void _goHome() {
    context.push(MescatRoutes.home);
  }

  final fileLoader = FileLoader.fromAsset(
    '${Assets.riveAsset}/cat.riv',
    riveFactory: Factory.rive,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LottieBuilder.asset('${Assets.riveAsset}/loader_cat.json'),
      ),
    );
  }
}
