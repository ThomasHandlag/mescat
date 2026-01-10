import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix/matrix.dart';

class SpaceCubit extends Cubit<List<Room>> {
  SpaceCubit(super.initialState, {required this.client});

  final Client client;

  void load() {
    if (!client.isLogged()) return;
    emit(client.rooms.where((room) => room.isSpace).toList());
  }

  Future<void> refresh() async {
    if (!client.isLogged()) return;

    final rooms = await client.getJoinedRooms();

    final spaces = <Room>[];
    for (final id in rooms) {
      final room = client.getRoomById(id);
      if (room != null && room.isSpace) {
        spaces.add(room);
      }
    }

    emit(spaces);
  }

  Future createSpace({required String name, String? topic}) async {
    await client.createSpace(name: name, topic: topic);
    await refresh();
  }
}
