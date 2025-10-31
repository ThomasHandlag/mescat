import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/features/rooms/blocs/room_bloc.dart';
import 'package:mescat/features/rooms/cubits/room_cubit.dart';

class RoomSettingPage extends StatefulWidget {
  final MatrixRoom room;

  const RoomSettingPage({super.key, required this.room});

  @override
  State<RoomSettingPage> createState() => _RoomSettingPageState();
}

class _RoomSettingPageState extends State<RoomSettingPage> {
  int _viewIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Room Settings')),
      body: BlocProvider(
        create: (_) => RoomCubit(widget.room),
        child: BlocBuilder<RoomCubit, MatrixRoom>(
          builder: (context, state) {
            return SafeArea(
              child: Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Colors.grey),
                              ),
                            ),
                            child: ListView(
                              children: [
                                ListTile(
                                  title: const Text('General'),
                                  selected: _viewIndex == 0,
                                  onTap: () {
                                    setState(() {
                                      _viewIndex = 0;
                                    });
                                  },
                                ),
                                ListTile(
                                  title: const Text('Members'),
                                  selected: _viewIndex == 1,
                                  onTap: () {
                                    setState(() {
                                      _viewIndex = 1;
                                    });
                                  },
                                ),
                                ListTile(
                                  title: const Text('Notifications'),
                                  selected: _viewIndex == 2,
                                  onTap: () {
                                    setState(() {
                                      _viewIndex = 2;
                                    });
                                  },
                                ),
                                ListTile(
                                  title: const Text('Permissions'),
                                  selected: _viewIndex == 3,
                                  onTap: () {
                                    setState(() {
                                      _viewIndex = 3;
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
                    child: ListView(
                      children: [
                        _buildView(state),
                        if (state != widget.room)
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: const BoxDecoration(
                              color: Color(0xff707070),
                            ),
                            child: Row(
                              children: [
                                const Text('You have unsaved changes. '),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<RoomBloc>().add(
                                      UpdateRoom(state),
                                    );
                                  },
                                  child: const Text('Save Changes'),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    context
                                        .read<RoomCubit>()
                                        .updateRoomProperties(
                                          canHaveCall: widget.room.canHaveCall,
                                          isMuted: widget.room.isMuted,
                                          permission: widget.room.permission,
                                          bannedIds: widget.room.bannedIds,
                                          topic: widget.room.topic,
                                          name: widget.room.name,
                                          avatarUrl: widget.room.avatarUrl,
                                          isEncrypted: widget.room.isEncrypted,
                                          isPublic: widget.room.isPublic,
                                        );
                                  },
                                  child: const Text('Discard Changes'),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildView(MatrixRoom room) {
    switch (_viewIndex) {
      case 0:
        return GeneralRoomSettings(room: room);
      case 1:
        return const Center(child: Text('Members Settings'));
      case 2:
        return const Center(child: Text('Notifications Settings'));
      case 3:
        return const Center(child: Text('Permissions Settings'));
      default:
        return const SizedBox.shrink();
    }
  }
}

class GeneralRoomSettings extends StatefulWidget {
  final MatrixRoom room;

  const GeneralRoomSettings({super.key, required this.room});

  @override
  State<GeneralRoomSettings> createState() => _GeneralRoomSettingsState();
}

class _GeneralRoomSettingsState extends State<GeneralRoomSettings> {
  late TextEditingController _nameController;
  late TextEditingController _topicController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.room.name);
    _topicController = TextEditingController(text: widget.room.topic);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            spacing: 20,
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      maxLines: 1,
                      onChanged: (value) {
                        context.read<RoomCubit>().updateRoomProperties(
                          name: value,
                        );
                      },
                      maxLength: 50,
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Room Name',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        labelStyle: TextStyle(color: Color(0xFF707E75)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: TextField(
                        controller: _topicController,
                        expands: true,
                        minLines: null,
                        onChanged: (value) {
                          context.read<RoomCubit>().updateRoomProperties(
                            topic: value,
                          );
                        },
                        maxLines: null,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: 'Topic',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          labelStyle: TextStyle(color: Color(0xFF707E75)),
                        ),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('E2E Encryption'),
                      subtitle: const Text('Enable end-to-end encryption'),
                      trailing: Switch(
                        value: widget.room.isEncrypted,
                        onChanged: (value) {
                          context.read<RoomCubit>().updateRoomProperties(
                            isEncrypted: value,
                          );
                        },
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Can Have Call'),
                      subtitle: const Text('Enable or disable call features'),
                      trailing: Switch(
                        value: widget.room.canHaveCall,
                        onChanged: (value) {
                          context.read<RoomCubit>().updateRoomProperties(
                            canHaveCall: value,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  shape: BoxShape.circle,
                ),
                child: GestureDetector(
                  onTap: () {},
                  child: CircleAvatar(
                    radius: Platform.isAndroid ? 40 : 80,
                    backgroundImage: widget.room.avatarUrl != null
                        ? NetworkImage(widget.room.avatarUrl!)
                        : null,
                    child: widget.room.avatarUrl == null
                        ? const Icon(Icons.camera_alt_outlined, size: 40)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
