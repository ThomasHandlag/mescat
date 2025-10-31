import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/chat/widgets/call_view.dart';
import 'package:mescat/features/chat/widgets/chat_view.dart';
import 'package:mescat/features/members/widgets/space_members.dart';
import 'package:mescat/features/rooms/blocs/room_bloc.dart';
import 'package:mescat/shared/util/mc_dialog.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _showMembers = true;

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
    return BlocBuilder<RoomBloc, RoomState>(
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
        SizedBox(
          width: 250,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.onSurface.withAlpha(20),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              isDense: true,
            ),
            onSubmitted: (value) {},
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget? _buildAppBar(RoomState state) {
    if (state is RoomLoaded && state.selectedRoom != null) {
      if (state.selectedRoom!.canHaveCall) {
        return null;
      } else {
        return AppBar(
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
    } else if (state is RoomLoading) {
      return AppBar(title: const Text('Loading...'));
    } else {
      return null;
    }
  }

  Widget _buildView(RoomState state) {
    if (state is RoomLoaded) {
      final selectedRoom = state.selectedRoom;
      if (selectedRoom != null && selectedRoom.canHaveCall) {
        return const CallView();
      } else {
        return Platform.isAndroid || Platform.isIOS
            ? _buildMobile()
            : _buildDesktop();
      }
    } else {
      return const Text('Select a channel to start chatting');
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
