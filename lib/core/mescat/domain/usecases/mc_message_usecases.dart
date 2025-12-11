part of 'mescat_usecases.dart';

/// Use case for sending messages
class SendMessageUseCase {
  final MCRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<MCFailure, MCMessageEvent>> call({
    required String roomId,
    required String content,
    String type = MessageTypes.Text,
    String? replyToEventId,
    bool viaToken = false,
    String? privKey,
  }) async {
    return await repository.sendMessage(
      roomId: roomId,
      content: content,
      msgtype: type,
      viaToken: viaToken,
      privKey: privKey,
    );
  }
}

/// Use case for getting room messages
class GetMessagesUseCase {
  final MCRepository repository;

  GetMessagesUseCase(this.repository);

  Future<Either<MCFailure, Map<String, dynamic>>> call({
    required String roomId,
    int limit = 50,
    String? fromToken,
    String? filter,
    String? toToken,
  }) async {
    return await repository.getMessages(
      roomId,
      limit: limit,
      fromToken: fromToken,
      filter: filter,
      toToken: toToken,
    );
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

class RemoveReactionUseCase {
  final MCRepository repository;

  RemoveReactionUseCase(this.repository);

  Future<Either<MCFailure, bool>> call({
    required String roomId,
    required String eventId,
    required String emoji,
  }) async {
    return await repository.removeReaction(
      roomId: roomId,
      eventId: eventId,
      emoji: emoji,
    );
  }
}

class ReplyMessageUseCase {
  final MCRepository repository;

  ReplyMessageUseCase(this.repository);

  Future<Either<MCFailure, MCMessageEvent>> call({
    required String roomId,
    required String content,
    required String replyToEventId,
    String msgtype = MessageTypes.Text,
    bool viaToken = false,
    String? privKey,
  }) async {
    return await repository.replyMessage(
      roomId: roomId,
      content: content,
      replyToEventId: replyToEventId,
      msgtype: msgtype,
      viaToken: viaToken,
      privKey: privKey,
    );
  }
}

class EditMessageUseCase {
  final MCRepository repository;

  EditMessageUseCase(this.repository);

  Future<Either<MCFailure, MCMessageEvent>> call({
    required String roomId,
    required String eventId,
    required String newContent,
  }) async {
    return await repository.editMessage(
      roomId: roomId,
      eventId: eventId,
      newContent: newContent,
    );
  }
}

class DeleteMessageUseCase {
  final MCRepository repository;

  DeleteMessageUseCase(this.repository);

  Future<Either<MCFailure, bool>> call({
    required String roomId,
    required String eventId,
  }) async {
    return await repository.deleteMessage(roomId: roomId, eventId: eventId);
  }
}

final class UpdateRoomUseCase {
  final MCRepository repository;

  UpdateRoomUseCase(this.repository);

  Future<Either<MCFailure, MatrixRoom>> call({required MatrixRoom room}) async {
    return await repository.updateRoom(room);
  }
}
