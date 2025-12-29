import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/core/routes/routes.dart';
import 'package:mescat/features/rooms/widgets/invite_room.dart';
import 'package:mescat/shared/util/mc_dialog.dart';

class RoomItem extends StatelessWidget {
  final Room room;
  final String? selectedRoomId;
  final RoomType roomType;

  const RoomItem({
    super.key,
    required this.room,
    required this.roomType,
    this.selectedRoomId,
  });

  void _onSelectRoom(BuildContext context) {
    final spaceId = GoRouterState.of(context).pathParameters['spaceId'];

    if (Platform.isAndroid || Platform.isIOS) {
      context.push(MescatRoutes.roomRoute(spaceId ?? '0', room.id));
    } else {
      context.go(MescatRoutes.roomRoute(spaceId ?? '0', room.id));
    }
  }

  IconData _getRoomIcon(RoomType type) {
    switch (type) {
      case RoomType.textChannel:
        return Icons.tag;
      case RoomType.voiceChannel:
        return Icons.volume_up;
      case RoomType.directMessage:
        return Icons.person;
      case RoomType.space:
        return Icons.folder;
      case RoomType.category:
        return Icons.folder_open;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomId = GoRouterState.of(context).pathParameters['roomId'];
    final isSelected = room.id == roomId;

    return GestureDetector(
      onTap: () {
        _onSelectRoom(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              _getRoomIcon(roomType),
              size: 18,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurface.withAlpha(0xCC),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Tooltip(
                message: roomType == RoomType.directMessage
                    ? room.getLocalizedDisplayname()
                    : room.name,
                child: Text(
                  roomType == RoomType.directMessage
                      ? room.getLocalizedDisplayname()
                      : room.name,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 4),
            if (!room.isDirectChat)
              IconButton(
                onPressed: () {
                  if (Platform.isAndroid || Platform.isIOS) {
                    showFullscreenDialog(context, InviteRoom(room: room));
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InviteRoom(room: room),
                          ),
                        );
                      },
                    );
                  }
                },
                icon: Icon(
                  Icons.group_add,
                  size: 16,
                  color: isSelected
                      ? Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withAlpha(0x99)
                      : Theme.of(context).colorScheme.onSurface.withAlpha(0x66),
                ),
                tooltip: 'Invite Members',
              ),
            IconButton(
              onPressed: () {
                context.push(MescatRoutes.roomSetting(room.id));
              },
              icon: Icon(
                Icons.settings,
                size: 16,
                color: isSelected
                    ? Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withAlpha(0x99)
                    : Theme.of(context).colorScheme.onSurface.withAlpha(0x66),
              ),
              tooltip: 'Channel Settings',
            ),
          ],
        ),
      ),
    );
  }
}
