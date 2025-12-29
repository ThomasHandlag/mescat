import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/core/routes/routes.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/features/chat/cubits/call_controller_cubit.dart';
import 'package:mescat/features/chat/widgets/collapse_call_view.dart';
import 'package:mescat/features/chat/widgets/pinned_messages.dart';
import 'package:mescat/features/voip/widgets/call_view.dart';
import 'package:mescat/features/chat/widgets/chat_view.dart';
import 'package:mescat/features/members/widgets/space_members.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';
import 'package:mescat/shared/util/extensions.dart';
import 'package:mescat/shared/util/mc_dialog.dart';
import 'package:mescat/shared/util/widget_overlay_service.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key, required this.spaceId});

  final String spaceId;

  Client get client => getIt<Client>();

  @override
  Widget build(BuildContext context) {
    final roomId = GoRouterState.of(context).pathParameters['roomId'];
    final room = roomId != null ? client.getRoomById(roomId) : null;

    if (room == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Room not found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        body: const Center(
          child: Text('The room you are trying to access does not exist.'),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(room, context),
      body: _buildView(room, context),
    );
  }

  Widget _buildChatHeader(BuildContext context, Room room) {
    return Row(
      children: [
        if (room.isDirectChat)
          IconButton(onPressed: () {}, icon: const Icon(Icons.videocam))
        else
          IconButton(
            onPressed: () {
              if (Platform.isAndroid || Platform.isIOS) {
                showFullscreenDialog(context, const SpaceMembersList());
              }
            },
            icon: const Icon(Icons.group),
            tooltip: 'Room Options',
          ),
        IconButton(
          onPressed: () {
            _showPinnedMessages(context, room);
          },
          icon: const Icon(Icons.push_pin),
        ),
      ],
    );
  }

  PreferredSizeWidget? _buildAppBar(Room room, BuildContext context) {
    final roomType = room.getRoomType();
    if (roomType == RoomType.voiceChannel) {
      return null;
    } else {
      return AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        primary: true,
        title: Row(
          children: [
            const Icon(Icons.tag, size: 16),
            Text(
              room.isDirectChat ? room.getLocalizedDisplayname() : room.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        actions: [_buildChatHeader(context, room)],
      );
    }
  }

  Widget _buildView(Room room, BuildContext context) {
    final roomType = room.getRoomType();
    if (roomType == RoomType.voiceChannel) {
      final callBloc = context.read<CallBloc>();
      if (callBloc.state is! CallInProgress) {
        callBloc.add(JoinCall(room: room));
      }
      return MultiBlocProvider(
        providers: [BlocProvider(create: (_) => CallControllerCubit())],
        child: CallView(
          onClose: () {
            WidgetOverlayService.of(context).show(
              child: const Hero(tag: "currentUser", child: CollapseCallView()),
              onExpand: (BuildContext appContext) {
                if (Platform.isAndroid || Platform.isIOS) {
                  appContext.push(MescatRoutes.roomRoute(spaceId, room.id));
                } else {
                  appContext.go(MescatRoutes.roomRoute(spaceId, room.id));
                }
                WidgetOverlayService.hide();
              },
            );
          },
        ),
      );
    } else {
      return Platform.isAndroid || Platform.isIOS
          ? _buildMobile()
          : _buildDesktop();
    }
  }

  Widget _buildMobile() {
    return const Scaffold(body: ChatView());
  }

  Widget _buildDesktop() {
    return const ChatView();
  }

  void _showPinnedMessages(BuildContext context, Room room) {
    final pinnedIds = room.pinnedEventIds;

    showMCAdaptiveDialog(
      context: context,
      builder: (context) {
        return PinnedMessages(pinnedIds: pinnedIds, room: room);
      },
    );
  }
}
