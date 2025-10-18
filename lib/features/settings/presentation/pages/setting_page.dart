import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/authentication/presentation/blocs/auth_bloc.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int _viewIndex = 0;

  final List<Widget> _views = [
    const Text('Account Settings'),
    const Text('Notification Settings'),
    const Text('Privacy Settings'),
    const Text('About Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(
              width: 200,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          title: const Text('Account'),
                          selected: _viewIndex == 0,
                          onTap: () {
                            setState(() {
                              _viewIndex = 0;
                            });
                          },
                        ),
                        ListTile(
                          title: const Text('Notifications'),
                          selected: _viewIndex == 1,
                          onTap: () {
                            setState(() {
                              _viewIndex = 1;
                            });
                          },
                        ),
                        ListTile(
                          title: const Text('Privacy'),
                          selected: _viewIndex == 2,
                          onTap: () {
                            setState(() {
                              _viewIndex = 2;
                            });
                          },
                        ),
                        ListTile(
                          title: const Text('About'),
                          selected: _viewIndex == 3,
                          onTap: () {
                            setState(() {
                              _viewIndex = 3;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final enabled = state is Authenticated;
                      return ListTile(
                        enabled: enabled,
                        iconColor: Colors.red,
                        onTap: () {
                          context.read<AuthBloc>().add(LogoutRequested());
                        },
                        title: const Text('Log Out'),
                        trailing: const Icon(Icons.logout),
                      );
                    },
                  ),
                ],
              ),
            ),
            _views[_viewIndex],
          ],
        ),
      ),
    );
  }
}
