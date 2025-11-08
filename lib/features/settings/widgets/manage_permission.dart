import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class ManagePermission extends StatefulWidget {
  const ManagePermission({super.key, required this.room});

  final Room room;

  @override
  State<ManagePermission> createState() => _ManagePermissionState();
}

class _ManagePermissionState extends State<ManagePermission> {
  @override
  Widget build(BuildContext context) {
    final room = widget.room;

    final powerLevelsContent = Map<String, Object?>.from(
      room.getState(EventTypes.RoomPowerLevels)?.content ?? {},
    );
    final powerLevels = Map<String, dynamic>.from(powerLevelsContent)
      ..removeWhere((k, v) => v is! int);
    final eventsPowerLevels = Map<String, int?>.from(
      powerLevelsContent.tryGetMap<String, int?>('events') ?? {},
    )..removeWhere((k, v) => v is! int);
    return Column(
      children: [
        const ListTile(
          leading: Icon(Icons.info_outlined),
          title: Text('High power come with high responsibility - Uncle Ben'),
        ),
        const ListTile(
          title: Text(
            'Room permissions',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in powerLevels.entries)
              PermissionsListTile(
                permissionKey: entry.key,
                permission: entry.value,
                onChanged: (level) {},
                canEdit: room.canChangePowerLevel,
              ),
            const ListTile(
              title: Text(
                'Notifications',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Builder(
              builder: (context) {
                const key = 'rooms';
                final value = powerLevelsContent.containsKey('notifications')
                    ? powerLevelsContent
                              .tryGetMap<String, Object?>('notifications')
                              ?.tryGet<int>('rooms') ??
                          0
                    : 0;
                return PermissionsListTile(
                  permissionKey: key,
                  permission: value,
                  category: 'notifications',
                  canEdit: room.canChangePowerLevel,
                  onChanged: (level) {},
                );
              },
            ),
            const ListTile(
              title: Text(
                'Configure chat',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            for (final entry in eventsPowerLevels.entries)
              PermissionsListTile(
                permissionKey: entry.key,
                category: 'events',
                permission: entry.value ?? 0,
                canEdit: room.canChangePowerLevel,
                onChanged: (level) {},
              ),
          ],
        ),
      ],
    );
  }
}

class PermissionsListTile extends StatelessWidget {
  final String permissionKey;
  final int permission;
  final String? category;
  final void Function(int? level)? onChanged;
  final bool canEdit;

  const PermissionsListTile({
    super.key,
    required this.permissionKey,
    required this.permission,
    this.category,
    required this.onChanged,
    required this.canEdit,
  });

  String getLocalizedPowerLevelString(BuildContext context) {
    if (category == null) {
      switch (permissionKey) {
        case 'users_default':
          return 'Default permission level';
        case 'events_default':
          return 'Send messages';
        case 'state_default':
          return 'Change general chat settings';
        case 'ban':
          return 'Ban from chat';
        case 'kick':
          return 'Kick from chat';
        case 'redact':
          return 'Delete message';
        case 'invite':
          return 'Invite other users';
      }
    } else if (category == 'notifications') {
      switch (permissionKey) {
        case 'rooms':
          return 'Send room notifications';
      }
    } else if (category == 'events') {
      switch (permissionKey) {
        case EventTypes.RoomName:
          return 'Change the name of the group';
        case EventTypes.RoomTopic:
          return 'Change the description of the group';
        case EventTypes.RoomPowerLevels:
          return 'Change the chat permissions';
        case EventTypes.HistoryVisibility:
          return 'Change the visibility of chat history';
        case EventTypes.RoomCanonicalAlias:
          return 'Change the canonical room alias';
        case EventTypes.RoomAvatar:
          return 'Edit room avatar';
        case EventTypes.RoomTombstone:
          return 'Replace room with newer version';
        case EventTypes.Encryption:
          return 'Enable encryption';
        case 'm.room.server_acl':
          return 'Edit blocked servers';
      }
    }
    return permissionKey;
  }

  String _moderatorLabel() {
    if (permission >= 100) {
      return 'Admin ($permission)';
    } else if (permission >= 50) {
      return 'Moderator ($permission)';
    } else {
      return 'User ($permission)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = permission >= 100
        ? Colors.orangeAccent
        : permission >= 50
        ? Colors.blueAccent
        : Colors.greenAccent;
    return ListTile(
      title: Text(
        getLocalizedPowerLevelString(context),
        style: theme.textTheme.titleSmall,
      ),
      trailing: Material(
        color: color.withAlpha(32),
        borderRadius: BorderRadius.circular(10),
        child: DropdownButton<int>(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          borderRadius: BorderRadius.circular(10),
          underline: const SizedBox.shrink(),
          onChanged: canEdit ? onChanged : null,
          value: permission,
          items: [
            DropdownMenuItem(
              value: permission < 50 ? permission : 0,
              child: Text(_moderatorLabel()),
            ),
            DropdownMenuItem(
              value: permission < 100 && permission >= 50 ? permission : 50,
              child: Text(_moderatorLabel()),
            ),
            DropdownMenuItem(
              value: permission >= 100 ? permission : 100,
              child: Text(_moderatorLabel()),
            ),
            const DropdownMenuItem(value: null, child: Text('Custom')),
          ],
        ),
      ),
    );
  }
}
