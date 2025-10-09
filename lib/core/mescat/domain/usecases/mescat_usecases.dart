import 'package:dartz/dartz.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/core/mescat/domain/repositories/matrix_repository.dart';

/// Use case for user authentication
class LoginUseCase {
  final MCRepository repository;

  LoginUseCase(this.repository);

  Future<Either<MCFailure, bool>> call({
    required String username,
    required String password,
  }) async {
    return await repository.login(
      username: username,
      password: password,
    );
  }
}

class RegisterUseCase {
  final MCRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<MCFailure, bool>> call({
    required String username,
    required String password,
    String? email,
  }) async {
    return await repository.register(
      username: username,
      password: password,
      email: email,
    );
  }
}

class LogoutUseCase {
  final MCRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<MCFailure, bool>> call() async {
    return await repository.logout();
  }
}

/// Use case for getting current user
class GetCurrentUserUseCase {
  final MCRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<MCFailure, MCUser>> call() async {
    return await repository.getCurrentUser();
  }
}

/// Use case for sending messages
class SendMessageUseCase {
  final MCRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<MCFailure, MCMessageEvent>> call({
    required String roomId,
    required String content,
    String type = MessageTypes.Text,
    String? replyToEventId,
  }) async {
    return await repository.sendMessage(
      roomId: roomId,
      content: content,
      msgtype: type,
      replyToEventId: replyToEventId,
    );
  }
}

/// Use case for getting room messages
class GetMessagesUseCase {
  final MCRepository repository;

  GetMessagesUseCase(this.repository);

  Future<Either<MCFailure, List<MCMessageEvent>>> call({
    required String roomId,
    int limit = 50,
    String? fromToken,
  }) async {
    return await repository.getMessages(
      roomId,
      limit: limit,
      fromToken: fromToken,
    );
  }
}

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

/// Use case for creating spaces (Discord servers)
class CreateSpaceUseCase {
  final MCRepository repository;

  CreateSpaceUseCase(this.repository);

  Future<Either<MCFailure, MatrixSpace>> call({
    required String name,
    String? description,
    bool isPublic = false,
  }) async {
    return await repository.createSpace(
      name: name,
      description: description,
      isPublic: isPublic,
    );
  }
}

/// Use case for getting user's spaces
class GetSpacesUseCase {
  final MCRepository repository;

  GetSpacesUseCase(this.repository);

  Future<Either<MCFailure, List<MatrixSpace>>> call() async {
    return await repository.getSpaces();
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

/// Use case for searching messages
class SearchMessagesUseCase {
  final MCRepository repository;

  SearchMessagesUseCase(this.repository);

  Future<Either<MCFailure, List<MCMessageEvent>>> call({
    required String query,
    String? roomId,
    int limit = 20,
  }) async {
    return await repository.searchMessages(
      query: query,
      roomId: roomId,
      limit: limit,
    );
  }
}

/// Use case for uploading files
class UploadFileUseCase {
  final MCRepository repository;

  UploadFileUseCase(this.repository);

  Future<Either<MCFailure, String>> call({
    required String filePath,
    required String fileName,
    String? mimeType,
  }) async {
    return await repository.uploadFile(
      filePath: filePath,
      fileName: fileName,
      mimeType: mimeType,
    );
  }
}

/// Use case for adding reactions to messages
class AddReactionUseCase {
  final MCRepository repository;

  AddReactionUseCase(this.repository);

  Future<Either<MCFailure, bool>> call({
    required String roomId,
    required String eventId,
    required String emoji,
  }) async {
    return await repository.addReaction(
      roomId: roomId,
      eventId: eventId,
      emoji: emoji,
    );
  }
}

/// Use case for setting user presence
class SetPresenceUseCase {
  final MCRepository repository;

  SetPresenceUseCase(this.repository);

  Future<Either<MCFailure, bool>> call(UserPresence presence) async {
    return await repository.setPresence(presence);
  }
}

/// Use case for sending typing indicators
class SendTypingIndicatorUseCase {
  final MCRepository repository;

  SendTypingIndicatorUseCase(this.repository);

  Future<Either<MCFailure, bool>> call({
    required String roomId,
    required bool isTyping,
  }) async {
    return await repository.sendTypingIndicator(roomId, isTyping);
  }
}

class GetRoomMembersUseCase {
  final MCRepository repository;

  GetRoomMembersUseCase(this.repository);

  Future<Either<MCFailure, List<MCUser>>> call(
    String roomId,
  ) async {
    return await repository.getRoomMembers(roomId);
  }
}