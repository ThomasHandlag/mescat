import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix/matrix.dart';

class RoomCubit extends Cubit<List<Room>> {
  RoomCubit(super.initialState, this.client);

  final Client client;

  void load(List<Room> rooms) {
    emit(rooms);
  }

  Future<void> refresh() async {
    final roomIds = await client.getJoinedRooms();

    final rooms = <Room>[];

    for (final roomId in roomIds) {
      final room = client.getRoomById(roomId);
      if (room != null && !room.isSpace) {
        rooms.add(room);
      }
    }

    emit(rooms);
  }
}
