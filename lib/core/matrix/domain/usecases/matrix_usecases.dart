import 'package:dartz/dartz.dart';
import 'package:mescat/core/errors/matrix_failures.dart';
import '../repositories/matrix_repository.dart';
import '../entities/matrix_entities.dart';

/// Use case for user authentication
class LoginUseCase {
  final MatrixRepository repository;

  LoginUseCase(this.repository);

  Future<Either<MatrixFailure, bool>> call({
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
  final MatrixRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<MatrixFailure, bool>> call({
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
  final MatrixRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<MatrixFailure, bool>> call() async {
    return await repository.logout();
  }
}

/// Use case for getting current user
class GetCurrentUserUseCase {
  final MatrixRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<MatrixFailure, MatrixUser>> call() async {
    return await repository.getCurrentUser();
  }
}

/// Use case for sending messages
class SendMessageUseCase {
  final MatrixRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<MatrixFailure, MatrixMessage>> call({
    required String roomId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToEventId,
  }) async {
    return await repository.sendMessage(
      roomId: roomId,
      content: content,
      type: type,
      replyToEventId: replyToEventId,
    );
  }
}

/// Use case for getting room messages
class GetMessagesUseCase {
  final MatrixRepository repository;

  GetMessagesUseCase(this.repository);

  Future<Either<MatrixFailure, List<MatrixMessage>>> call({
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
  final MatrixRepository repository;

  CreateRoomUseCase(this.repository);

  Future<Either<MatrixFailure, MatrixRoom>> call({
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
  final MatrixRepository repository;

  JoinRoomUseCase(this.repository);

  Future<Either<MatrixFailure, bool>> call(String roomId) async {
    return await repository.joinRoom(roomId);
  }
}

/// Use case for creating spaces (Discord servers)
class CreateSpaceUseCase {
  final MatrixRepository repository;

  CreateSpaceUseCase(this.repository);

  Future<Either<MatrixFailure, MatrixSpace>> call({
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
  final MatrixRepository repository;

  GetSpacesUseCase(this.repository);

  Future<Either<MatrixFailure, List<MatrixSpace>>> call() async {
    return await repository.getSpaces();
  }
}

/// Use case for getting user's rooms
class GetRoomsUseCase {
  final MatrixRepository repository;

  GetRoomsUseCase(this.repository);

  Future<Either<MatrixFailure, List<MatrixRoom>>> call(String? spaceId) async {
    if (spaceId != null && spaceId.isNotEmpty) {
      return await repository.getSpaceRooms(spaceId);
    } else {
      return await repository.getRooms();
    }
  }
}

/// Use case for searching messages
class SearchMessagesUseCase {
  final MatrixRepository repository;

  SearchMessagesUseCase(this.repository);

  Future<Either<MatrixFailure, List<MatrixMessage>>> call({
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
  final MatrixRepository repository;

  UploadFileUseCase(this.repository);

  Future<Either<MatrixFailure, String>> call({
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
  final MatrixRepository repository;

  AddReactionUseCase(this.repository);

  Future<Either<MatrixFailure, bool>> call({
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
  final MatrixRepository repository;

  SetPresenceUseCase(this.repository);

  Future<Either<MatrixFailure, bool>> call(UserPresence presence) async {
    return await repository.setPresence(presence);
  }
}

/// Use case for sending typing indicators
class SendTypingIndicatorUseCase {
  final MatrixRepository repository;

  SendTypingIndicatorUseCase(this.repository);

  Future<Either<MatrixFailure, bool>> call({
    required String roomId,
    required bool isTyping,
  }) async {
    return await repository.sendTypingIndicator(roomId, isTyping);
  }
}