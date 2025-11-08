import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/shared/widgets/mc_button.dart';
import 'package:mescat/features/settings/widgets/manage_member.dart';
import 'package:mescat/features/settings/widgets/manage_notification.dart';
import 'package:mescat/features/settings/widgets/manage_permission.dart';
import 'package:mescat/features/settings/widgets/manage_general.dart';

class RoomSettingPage extends StatefulWidget {
  final MatrixRoom room;

  const RoomSettingPage({super.key, required this.room});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.room.name} Settings')),
      body: SafeArea(
        child: Platform.isAndroid || Platform.isIOS
            ? _buildMobile()
            : _buildDesktop(),
      ),
    );
  }

  Widget _buildView(MatrixRoom room) {
    return switch (_viewCategory) {
      RoomSettingCategory.general => ManageGeneral(room: widget.room),
      RoomSettingCategory.members => ManageMember(room: widget.room.room),
      RoomSettingCategory.notifications => ManageNotification(
        room: widget.room.room,
      ),
      RoomSettingCategory.permissions => ManagePermission(
        room: widget.room.room,
      ),
    };
  }

  Widget _buildMobile() {
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
                    border: Border.all(color: Colors.grey),
                    selected: _categories[index] == _viewCategory,
                    child: Text(_categories[index].name.toUpperCase()),
                  );
                },
              ),
            ),
          ),
          Expanded(child: _buildView(widget.room)),
        ],
      ),
    );
  }

  Widget _buildDesktop() {
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
              _buildView(widget.room),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(color: Color(0xff707070)),
                  child: Row(
                    children: [
                      const Text('You have unsaved changes. '),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Save Changes'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Discard Changes'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

