import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/authentication/presentation/blocs/auth_bloc.dart';
import 'package:mescat/features/chat/presentation/pages/chat_page.dart';
import 'package:mescat/features/rooms/presentation/blocs/room_bloc.dart';
import 'package:mescat/features/rooms/presentation/widgets/room_list.dart';
import 'package:mescat/features/spaces/presentation/blocs/space_bloc.dart';
import 'package:mescat/features/spaces/presentation/widgets/space_sidebar.dart';
import 'package:mescat/features/voip/presentation/blocs/call_bloc.dart';
import 'package:mescat/shared/widgets/user_box.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<SpaceBloc>().add(LoadSpaces());
    context.read<RoomBloc>().add(const LoadRooms());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            color: const Color.fromARGB(255, 35, 35, 42),
            width: 310,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      SpaceSidebar(),
                      SizedBox(width: 250, child: RoomList()),
                    ],
                  ),
                ),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is! Authenticated) {
                      return const SizedBox.shrink();
                    }
                    return BlocBuilder<CallBloc, MCCallState>(builder: (context, roomState) {
                      return UserBox(
                        username: state.user.displayName,
                        avatarUrl: state.user.avatarUrl,
                        joinedVoice: roomState is CallInProgress,
                        voiceEnabled: roomState is CallInProgress && roomState.voiceOn,
                        headphonesEnabled: roomState is CallInProgress && roomState.muted,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          const Expanded(child: ChatPage()),
        ],
      ),
    );
  }
}
