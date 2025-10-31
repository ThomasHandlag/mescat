import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';

final class RoomCubit extends Cubit<MatrixRoom> {
  final MatrixRoom room;
  RoomCubit(this.room) : super(room);

  void updateRoomProperties({
    bool? canHaveCall,
    bool? isMuted,
    Map<String, dynamic>? permission,
    Map<String, String>? bannedIds,
    String? topic,
    String? name,
    String? avatarUrl,
    bool? isEncrypted,
    bool? isPublic,
  }) {
    emit(
      state.copyWith(
        canHaveCall: canHaveCall,
        isMuted: isMuted,
        permission: permission,
        bannedIds: bannedIds,
        topic: topic,
        name: name,
        avatarUrl: avatarUrl,
        isEncrypted: isEncrypted,
        isPublic: isPublic,
      ),
    );
  }
}
