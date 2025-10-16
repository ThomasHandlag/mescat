import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/authentication/presentation/blocs/auth_bloc.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

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
                      children:  [
                        ListTile(title: Text('Account'), onTap: () {
                          Navigator.of(context).pushReplacementNamed('/auth');
                        },),
                        ListTile(title: Text('Notifications')),
                        ListTile(title: Text('Privacy')),
                        ListTile(title: Text('About')),
                      ],
                    ),
                  ),
                  const Spacer(),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final enabled = state is AuthAuthenticated;
                      return ListTile(
                        enabled: enabled,
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
            const Expanded(child: Text('Select a setting from the sidebar')),
          ],
        ),
      ),
    );
  }
}
