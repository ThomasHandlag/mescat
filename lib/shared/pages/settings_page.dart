import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mescat/core/routes/routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Platform.isAndroid ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ) : null,
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            onTap: () {
              context.push(MescatRoutes.settingGeneral);
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Account'),
            onTap: () {
              context.push(MescatRoutes.settingAccount);
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
             context.push(MescatRoutes.settingNotifications);
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy & Security'),
            onTap: () {
              context.push(MescatRoutes.settingPrivacy);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              context.push(MescatRoutes.settingAbout);
            },
          ),
        ],
      ),
    );
  }
}
