import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/features/chat/blocs/chat_bloc.dart';
import 'package:mescat/features/chat/cubits/call_controller_cubit.dart';
import 'package:mescat/features/chat/widgets/call_view.dart';
import 'package:mescat/features/chat/widgets/chat_view.dart';
import 'package:mescat/features/chat/widgets/collapse_call_view.dart';
import 'package:mescat/features/members/widgets/space_members.dart';
import 'package:mescat/features/rooms/blocs/room_bloc.dart';
import 'package:mescat/shared/util/mc_dialog.dart';
import 'package:mescat/shared/util/widget_overlay_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.context});

  final BuildContext context;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _showMembers = true;

  final client = getIt<Client>();

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
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return Scaffold(appBar: _buildAppBar(state), body: _buildView(state));
      },
    );
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
        Container(
          padding: const EdgeInsets.only(right: 10),
          width: 250,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              suffixIcon: const Icon(Icons.search),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.onSurface.withAlpha(20),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 10,
              ),
              isDense: true,
            ),
            onSubmitted: (value) {},
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget? _buildAppBar(ChatState state) {
    if (state.selectedRoom != null) {
      if (state.selectedRoom?.canHaveCall == true) {
        return null;
      } else {
        return AppBar(
          backgroundColor: const Color.fromARGB(255, 35, 35, 42),
          primary: true,
          title: Row(
            children: [
              const Icon(Icons.tag, size: 16),
              Text(
                state.selectedRoom?.name ?? 'Unnamed Room',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          actions: [_buildChatHeader(context)],
        );
      }
    }
    return null;
  }

  Widget _buildView(ChatState state) {
    final selectedRoom = state.selectedRoom;
    if (selectedRoom != null && selectedRoom.canHaveCall) {
      return MultiBlocProvider(
        providers: [BlocProvider(create: (_) => CallControllerCubit())],
        child: CallView(
          onClose: () {
            WidgetOverlayService.show(
              widget.context,
              onExpand: () {
                WidgetOverlayService.hide();
                widget.context.read<RoomBloc>().add(SelectedRoom(selectedRoom));
              },
              child: const CollapseCallView(),
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
    return Row(
      children: [
        const Expanded(child: ChatView()),
        if (_showMembers)
          Container(
            width: 250,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).dividerColor.withAlpha(50),
                ),
              ),
            ),
            child: const SpaceMembersList(),
          ),
      ],
    );
  }
}
