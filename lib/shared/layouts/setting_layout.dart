import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mescat/core/routes/routes.dart';

class SettingLayout extends StatelessWidget {
  const SettingLayout({super.key, required this.child});
  const SettingLayout.empty({super.key}) : child = const SizedBox.shrink();

  final Map<String, String> items = const {
    'general': MescatRoutes.settingGeneral,
    'account': MescatRoutes.settingAccount,
    'notifications': MescatRoutes.settingNotifications,
    'about': MescatRoutes.settingAbout,
  };

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _buildDesktop(),
    );
  }

  Widget _buildDesktop() {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: ListView.builder(
            itemBuilder: (context, index) {
              final key = items.keys.elementAt(index);
              final value = items.values.elementAt(index);
              final selected =
                  GoRouterState.of(context).matchedLocation == value;
              return ListTile(
                selected: selected,
                title: Text(key[0].toUpperCase() + key.substring(1)),
                onTap: () {
                  context.pushReplacement(value);
                },
              );
            },
            itemCount: items.length,
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
