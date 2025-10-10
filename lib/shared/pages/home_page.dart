import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/chat/presentation/pages/chat_page.dart';
import 'package:mescat/features/rooms/presentation/blocs/room_bloc.dart';
import 'package:mescat/features/rooms/presentation/widgets/room_list.dart';
import 'package:mescat/features/spaces/presentation/blocs/space_bloc.dart';
import 'package:mescat/features/spaces/presentation/widgets/space_sidebar.dart';

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
    return const Scaffold(
      body: Row(
        children: [
          SpaceSidebar(),
          SizedBox(width: 250, child: RoomList()),
          Expanded(child: ChatPage()),
        ],
      ),
    );
  }
}
