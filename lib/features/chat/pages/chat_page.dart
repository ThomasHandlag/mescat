import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/features/chat/cubits/call_controller_cubit.dart';
import 'package:mescat/features/chat/widgets/call_view.dart';
import 'package:mescat/features/chat/widgets/chat_view.dart';
import 'package:mescat/features/members/widgets/space_members.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';
import 'package:mescat/shared/util/extensions.dart';
import 'package:mescat/shared/util/mc_dialog.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.context});

  final BuildContext context;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _showMembers = true;

  Client get client => getIt<Client>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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

    return Scaffold(appBar: _buildAppBar(room), body: _buildView(room));
  }

  Widget _buildChatHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.push_pin)),
        IconButton(
          onPressed: () {
            if (Platform.isAndroid || Platform.isIOS) {
              showFullscreenDialog(context, const SpaceMembersList());
            } else {
              setState(() {
                _showMembers = !_showMembers;
              });
            }
          },
          icon: const Icon(Icons.group),
          tooltip: 'Room Options',
        ),
        
      ],
    );
  }

  PreferredSizeWidget? _buildAppBar(Room room) {
    final roomType = room.getRoomType();
    if (roomType == RoomType.voiceChannel) {
      return null;
    } else {
      return AppBar(
        backgroundColor: const Color.fromARGB(255, 35, 35, 42),
        primary: true,
        title: Row(
          children: [
            const Icon(Icons.tag, size: 16),
            Text(room.name, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        actions: [_buildChatHeader(context)],
      );
    }
  }

  Widget _buildView(Room room) {
    final roomType = room.getRoomType();
    if (roomType == RoomType.voiceChannel) {
      context.read<CallBloc>().add(JoinCall(room: room));
      return MultiBlocProvider(
        providers: [BlocProvider(create: (_) => CallControllerCubit())],
        child: CallView(onClose: () {}),
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
}
