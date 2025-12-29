import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:mescat/features/authentication/widgets/login_form.dart';
import 'package:mescat/features/authentication/widgets/register_form.dart';

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
    final content = Container(
      padding: const EdgeInsets.all(16.0),
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withAlpha(50),
            ),
            dividerHeight: 0,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.onSurface,
            tabs: const [
              Tab(text: 'Login'),
              Tab(text: 'Register'),
            ],
            onTap: (index) {
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                LoginForm(
                  onSwitchToRegister: () => _tabController.animateTo(1),
                ),
                RegisterForm(
                  onSwitchToLogin: () => _tabController.animateTo(0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: Platform.isAndroid || Platform.isIOS
          ? AppBar(
              title: Text(
                _tabController.index == 0 ? 'Login' : 'Register',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      body: SizedBox(
        child: Platform.isAndroid || Platform.isIOS
            ? _buildMobile(content)
            : _buildDesktop(content),
      ),
    );
  }

  Widget _buildMobile(Widget child) {
    return child;
  }

  Widget _buildDesktop(Widget child) {
    return Row(
      children: [
        Expanded(
          child: Expanded(
            child: Lottie.asset('${Assets.riveAsset}/loader_cat.json'),
          ),
        ),
        child,
      ],
    );
  }
}
