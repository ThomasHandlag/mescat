import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/routes/routes.dart';
import 'package:mescat/shared/util/permission_util.dart';
import 'package:mescat/dependency_injection.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  final _duration = const Duration(seconds: 2);

  Client get client => getIt<Client>();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);
    _controller.repeat();

    requirePermissions();
    _syncClient();
  }

  void _syncClient() async {
    await Future.delayed(const Duration(seconds: 2));
    await client.roomsLoading;
    await client.accountDataLoading;
    await client.userDeviceKeysLoading;
    _goHome();
  }

  void _goHome() {
    _controller.stop();
    context.push(MescatRoutes.home);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LottieBuilder.asset(
          '${Assets.riveAsset}/loader_cat.json',
          controller: _animation,
        ),
      ),
    );
  }
}
