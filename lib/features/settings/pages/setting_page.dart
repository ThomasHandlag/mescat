import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/routes/routes.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/features/settings/cubits/setting_cubit.dart';
import 'package:mescat/features/wallet/cubits/wallet_cubit.dart';
import 'package:mescat/features/wallet/data/wallet_store.dart';
import 'package:mescat/l10n/mescat_localizations.dart';
import 'package:mescat/shared/widgets/mc_image.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  final Map<String, String> items = const {
    'general': MescatRoutes.settingGeneral,
    'account': MescatRoutes.settingAccount,
    'notifications': MescatRoutes.settingNotifications,
    'about': MescatRoutes.settingAbout,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView.builder(
          itemBuilder: (context, index) {
            final key = items.keys.elementAt(index);
            final value = items.values.elementAt(index);
            final selected = GoRouterState.of(context).matchedLocation == value;
            return ListTile(
              selected: selected,
              title: Text(key[0].toUpperCase() + key.substring(1)),
              onTap: () {
                context.push(value);
              },
            );
          },
          itemCount: items.length,
        ),
      ),
    );
  }
}

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  String _generateLanguageLabel(String code) {
    return switch (code) {
      'en' => 'English',
      'es' => 'Spanish',
      'fr' => 'French',
      'vi' => 'Vietnamese',
      'de' => 'German',
      'zh' => 'Chinese',
      _ => 'Unknown',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Platform.isAndroid
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.pop();
                },
              )
            : null,
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Language'),
            subtitle: BlocBuilder<SettingCubit, SettingState>(
              builder: (context, state) {
                final languageCode = state.languageCode;
                return Text(_generateLanguageLabel(languageCode));
              },
            ),
            trailing: DropdownMenu(
              initialSelection: context.read<SettingCubit>().state.languageCode,
              dropdownMenuEntries: [
                ...AppLocalizations.supportedLocales.map(
                  (locale) => DropdownMenuEntry<String>(
                    value: locale.languageCode,
                    label: _generateLanguageLabel(locale.languageCode),
                  ),
                ),
              ],
              onSelected: (String? value) {
                if (value != null) {
                  context.read<SettingCubit>().setLanguageCode(value);
                }
              },
            ),
          ),

          ListTile(
            title: const Text('Theme Mode'),
            subtitle: BlocBuilder<SettingCubit, SettingState>(
              builder: (context, state) {
                final themeMode = state.themeMode;
                return Text(
                  themeMode.name[0].toUpperCase() + themeMode.name.substring(1),
                );
              },
            ),
            trailing: DropdownMenu(
              initialSelection: context.read<SettingCubit>().state.themeMode,
              dropdownMenuEntries: MescatThemeMode.values
                  .map(
                    (mode) => DropdownMenuEntry<MescatThemeMode>(
                      value: mode,
                      label:
                          mode.name[0].toUpperCase() + mode.name.substring(1),
                    ),
                  )
                  .toList(),
              onSelected: (MescatThemeMode? value) {
                if (value != null) {
                  context.read<SettingCubit>().setThemeMode(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  Client get client => getIt<Client>();
  WalletStore get walletStore => getIt<WalletStore>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Platform.isAndroid
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.pop();
                },
              )
            : null,
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              shape: BoxShape.circle,
            ),
            child: GestureDetector(
              onTap: () {},
              child: FutureBuilder(
                future: client.getUserProfile(client.userID!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                      radius: 80,
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return const CircleAvatar(
                      radius: 80,
                      child: Icon(Icons.error, size: 40),
                    );
                  } else {
                    final profile = snapshot.data!;
                    return CircleAvatar(
                      radius: Platform.isAndroid ? 40 : 80,
                      child: profile.avatarUrl == null
                          ? const Icon(Icons.camera_alt_outlined, size: 40)
                          : McImage(
                              uri: profile.avatarUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(40),
                            ),
                    );
                  }
                },
              ),
            ),
          ),
          ListTile(title: const Text('Change Password'), onTap: () {}),
          ListTile(title: const Text('Privacy Notices'), onTap: () {}),
          ListTile(
            title: const Text('Logout'),
            onTap: () async {
              if (Platform.isAndroid || Platform.isIOS) {
                await Web3AuthFlutter.logout();
              } else {
                await walletStore.wipe();
              }
              client.logout();
            },
          ),
        ],
      ),
    );
  }
}

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Platform.isAndroid
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.pop();
                },
              )
            : null,
        title: const Text('Settings'),
      ),
      body: const Center(child: Text('Notification Settings')),
    );
  }
}

class AboutSettingsPage extends StatelessWidget {
  const AboutSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Platform.isAndroid
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.pop();
                },
              )
            : null,
        title: const Text('Settings'),
      ),
      body: const Center(child: Text('About Settings')),
    );
  }
}
