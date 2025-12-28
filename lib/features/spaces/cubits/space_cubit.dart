import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix/matrix.dart';

class SpaceCubit extends Cubit<List<Room>> {
  SpaceCubit(super.initialState, {required this.client});

  final Client client;

  void load() {
    if (!client.isLogged()) return;
    emit(client.rooms.where((room) => room.isSpace).toList());
  }

  Future createSpace({required String name, String? topic}) async {
    client.createSpace(name: name, topic: topic);
  }
}
