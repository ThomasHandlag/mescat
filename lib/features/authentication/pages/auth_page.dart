import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/authentication/widgets/login_form.dart';
import 'package:mescat/features/authentication/widgets/register_form.dart';
import 'dart:io';

import 'package:mescat/features/home_server/cubits/server_cubit.dart';
import 'package:mescat/features/home_server/pages/home_server.dart';
import 'package:mescat/shared/util/mc_dialog.dart';
import 'package:mescat/shared/widgets/mc_button.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showHomeServerDialog() {
    showFullscreenDialog(context, const HomeServer());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Login to Mescat",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: Platform.isAndroid || Platform.isIOS
              ? null
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 58, 123, 213),
                    Color.fromARGB(255, 0, 210, 255),
                  ],
                ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(6.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(0x1A),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                BlocBuilder<ServerCubit, ServerState>(
                  builder: (context, state) {
                    if (state is ServerListLoaded) {
                      return Row(
                        children: [
                          Text(
                            'Connected to ${state.selectedServer?.domain ?? state.servers.first.domain}',
                          ),
                          const Spacer(),
                          McButton(
                            onPressed: _showHomeServerDialog,
                            child: const Text(
                              'Change',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [LoginForm(), RegisterForm()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
