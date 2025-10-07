import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/spaces/presentation/blocs/space_bloc.dart';
import '../../features/rooms/presentation/blocs/room_bloc.dart';
import '../../features/spaces/presentation/widgets/space_sidebar.dart';
import '../../features/rooms/presentation/widgets/room_list.dart';
import '../../features/chat/presentation/widgets/chat_view.dart';

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
    context.read<RoomBloc>().add(LoadRooms());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Space sidebar (Discord servers equivalent)
          const SpaceSidebar(),
          
          // Room list (Discord channels equivalent)
          const SizedBox(
            width: 250,
            child: RoomList(),
          ),
          
          // Chat view
          const Expanded(
            child: ChatView(),
          ),
        ],
      ),
    );
  }
}