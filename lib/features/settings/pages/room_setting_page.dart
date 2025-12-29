import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/shared/widgets/mc_button.dart';
import 'package:mescat/features/settings/widgets/manage_member.dart';
import 'package:mescat/features/settings/widgets/manage_notification.dart';
import 'package:mescat/features/settings/widgets/manage_permission.dart';
import 'package:mescat/features/settings/widgets/manage_general.dart';

class RoomSettingPage extends StatefulWidget {
  const RoomSettingPage({super.key});

  @override
  State<RoomSettingPage> createState() => _RoomSettingPageState();
}

enum RoomSettingCategory { general, members, notifications, permissions }

class _RoomSettingPageState extends State<RoomSettingPage> {
  RoomSettingCategory _viewCategory = RoomSettingCategory.general;

  @override
  void initState() {
    super.initState();
  }

  final List<RoomSettingCategory> _categories = [
    RoomSettingCategory.general,
    RoomSettingCategory.members,
    RoomSettingCategory.notifications,
    RoomSettingCategory.permissions,
  ];

  Client get client => getIt<Client>();

  @override
  Widget build(BuildContext context) {
    final roomId = GoRouterState.of(context).pathParameters['roomId']!;

    final room = client.getRoomById(roomId);

    if (room == null) {
      return const Scaffold(body: Center(child: Text('Room not found')));
    }

    return Scaffold(
      appBar: AppBar(title: Text('${room.name} Settings')),
      body: SafeArea(
        child: Platform.isAndroid || Platform.isIOS
            ? _buildMobile(room)
            : _buildDesktop(room),
      ),
    );
  }

  Widget _buildView(Room room) {
    return switch (_viewCategory) {
      RoomSettingCategory.general => ManageGeneral(room: room),
      RoomSettingCategory.members => ManageMember(room: room),
      RoomSettingCategory.notifications => ManageNotification(room: room),
      RoomSettingCategory.permissions => ManagePermission(room: room),
    };
  }

  Widget _buildMobile(Room room) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(
            height: UIConstraints.mCustomBtnHeight,
            child: Center(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: 8.0),
                itemBuilder: (context, index) {
                  return McButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    onPressed: () {
                      setState(() {
                        _viewCategory = _categories[index];
                      });
                    },
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    selected: _categories[index] == _viewCategory,
                    child: Text(_categories[index].name.toUpperCase()),
                  );
                },
              ),
            ),
          ),
          Expanded(child: _buildView(room)),
        ],
      ),
    );
  }

  Widget _buildDesktop(Room room) {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.grey)),
                  ),
                  child: ListView(
                    children: [
                      ListTile(
                        title: const Text('General'),
                        selected: _viewCategory == RoomSettingCategory.general,
                        onTap: () {
                          setState(() {
                            _viewCategory = RoomSettingCategory.general;
                          });
                        },
                      ),
                      ListTile(
                        title: const Text('Members'),
                        selected: _viewCategory == RoomSettingCategory.members,
                        onTap: () {
                          setState(() {
                            _viewCategory = RoomSettingCategory.members;
                          });
                        },
                      ),
                      ListTile(
                        title: const Text('Notifications'),
                        selected:
                            _viewCategory == RoomSettingCategory.notifications,
                        onTap: () {
                          setState(() {
                            _viewCategory = RoomSettingCategory.notifications;
                          });
                        },
                      ),
                      ListTile(
                        title: const Text('Permissions'),
                        selected:
                            _viewCategory == RoomSettingCategory.permissions,
                        onTap: () {
                          setState(() {
                            _viewCategory = RoomSettingCategory.permissions;
                          });
                        },
                      ),
                      ListTile(
                        title: Text(
                          room.canKick ? 'Remove room' : 'Leave room',
                          style: const TextStyle(color: Colors.red),
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              _buildView(room),
              // Align(
              //   alignment: Alignment.bottomRight,
              //   child: Container(
              //     padding: const EdgeInsets.all(16.0),
              //     decoration: const BoxDecoration(color: Color(0xff707070)),
              //     child: Row(
              //       children: [
              //         const Text('You have unsaved changes. '),
              //         const Spacer(),
              //         ElevatedButton(
              //           onPressed: () {},
              //           child: const Text('Save Changes'),
              //         ),
              //         const SizedBox(width: 8),
              //         TextButton(
              //           onPressed: () {},
              //           child: const Text('Discard Changes'),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}
