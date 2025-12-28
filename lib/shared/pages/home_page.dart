import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/routes/routes.dart';
import 'package:mescat/dependency_injection.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _syncClient();
  }

  void _syncClient() async {
    final client = getIt<Client>();

    if (client.encryption?.keyManager.enabled == true) {
      if (await client.encryption?.keyManager.isCached() == false ||
          await client.encryption?.crossSigning.isCached() == false ||
          client.isUnknownSession && mounted) {
        _pushVerifyDevice();
      }
    }
  }

  void _pushVerifyDevice() {
    context.push(MescatRoutes.verifyDevice);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Start a chat")));
  }
}
