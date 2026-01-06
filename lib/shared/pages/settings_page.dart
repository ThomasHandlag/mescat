import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/routes/routes.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'dart:io';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Client get _client => getIt<Client>();

  final Map<String, (String, IconData)> items = const {
    'general': (MescatRoutes.settingGeneral, Icons.settings),
    'account': (MescatRoutes.settingAccount, Icons.account_circle),
    'notifications': (MescatRoutes.settingNotifications, Icons.notifications),
    'about': (MescatRoutes.settingAbout, Icons.info),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ...items.entries.map(
            (entry) => ListTile(
              title: Text(entry.key[0].toUpperCase() + entry.key.substring(1)),
              leading: Icon(entry.value.$2),
              onTap: () {
                Navigator.pushNamed(context, entry.value.$1);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              if (Platform.isAndroid || Platform.isIOS) {
                await Web3AuthFlutter.logout();
              }
              _client.logout();
            },
          ),
        ],
      ),
    );
  }
}
