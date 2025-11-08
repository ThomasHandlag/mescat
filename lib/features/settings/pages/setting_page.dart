import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/authentication/blocs/auth_bloc.dart';

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
                  BlocBuilder<MescatBloc, MescatStatus>(
                    builder: (context, state) {
                      final enabled = state is Authenticated;
                      return ListTile(
                        enabled: enabled,
                        iconColor: Colors.red,
                        onTap: () {
                          context.read<MescatBloc>().add(LogoutRequested());
                          if (Navigator.canPop(context)) {
                            Navigator.of(context).pop();
                          }
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

/* 
 Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  shape: BoxShape.circle,
                ),
                child: GestureDetector(
                  onTap: () {},
                  child: CircleAvatar(
                    radius: Platform.isAndroid ? 40 : 80,
                    backgroundImage: widget.room.avatarUrl != null
                        ? NetworkImage(widget.room.avatarUrl!)
                        : null,
                    child: widget.room.avatarUrl == null
                        ? const Icon(Icons.camera_alt_outlined, size: 40)
                        : null,
                  ),
                ),
              ),

*/
