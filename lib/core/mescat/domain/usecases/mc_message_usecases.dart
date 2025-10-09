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
