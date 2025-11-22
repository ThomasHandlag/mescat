part of 'mescat_usecases.dart';

/// Use case for creating rooms
class CreateRoomUseCase {
  final MCRepository repository;

  CreateRoomUseCase(this.repository);

  Future<Either<MCFailure, MatrixRoom>> call({
    required String name,
    String? topic,
    RoomType type = RoomType.textChannel,
    bool isPublic = false,
    String? parentSpaceId,
  }) async {
    return await repository.createRoom(
      name: name,
      topic: topic,
      type: type,
      isPublic: isPublic,
      parentSpaceId: parentSpaceId,
    );
  }
}

/// Use case for joining rooms
class JoinRoomUseCase {
  final MCRepository repository;

  JoinRoomUseCase(this.repository);

  Future<Either<MCFailure, bool>> call(String roomId) async {
    return await repository.joinRoom(roomId);
  }
}

/// Use case for getting user's rooms
class GetRoomsUseCase {
  final MCRepository repository;

  GetRoomsUseCase(this.repository);

  Future<Either<MCFailure, List<MatrixRoom>>> call(String? spaceId) async {
    if (spaceId != null && spaceId.isNotEmpty) {
      return await repository.getSpaceRooms(spaceId);
    } else {
      return await repository.getRooms();
    }
  }
}

class GetRoomUsecase {
  final MCRepository repository;

  GetRoomUsecase(this.repository);

  Future<Either<MCFailure, MatrixRoom>> call(String roomId) async {
    return await repository.getRoom(roomId);
  }
}

class GetRoomMembersUseCase {
  final MCRepository repository;

  GetRoomMembersUseCase(this.repository);

  Future<Either<MCFailure, List<MCUser>>> call(String roomId) async {
    return await repository.getRoomMembers(roomId);
  }
}
