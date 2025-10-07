import 'package:dartz/dartz.dart';
import 'package:mescat/core/errors/matrix_failures.dart';
import '../entities/matrix_entities.dart';

/// Repository interface for Matrix client operations
abstract class MatrixRepository {
  // Authentication
  Future<Either<MatrixFailure, bool>> login({
    required String username,
    required String password,
  });

  Future<Either<MatrixFailure, bool>> register({
    required String username,
    required String password,
    String? email,
  });

  Future<Either<MatrixFailure, bool>> logout();

  // User management
  Future<Either<MatrixFailure, MatrixUser>> getCurrentUser();
  Future<Either<MatrixFailure, MatrixUser>> getUser(String userId);
  Future<Either<MatrixFailure, bool>> updateUserProfile({
    String? displayName,
    String? avatarUrl,
  });

  // Room management
  Future<Either<MatrixFailure, List<MatrixRoom>>> getRooms();
  Future<Either<MatrixFailure, MatrixRoom>> getRoom(String roomId);
  Future<Either<MatrixFailure, MatrixRoom>> createRoom({
    required String name,
    String? topic,
    RoomType type = RoomType.textChannel,
    bool isPublic = false,
    String? parentSpaceId,
  });
  Future<Either<MatrixFailure, bool>> joinRoom(String roomId);
  Future<Either<MatrixFailure, bool>> leaveRoom(String roomId);
  Future<Either<MatrixFailure, bool>> inviteToRoom(
    String roomId,
    String userId,
  );

  // Space management
  Future<Either<MatrixFailure, List<MatrixSpace>>> getSpaces();
  Future<Either<MatrixFailure, MatrixSpace>> getSpace(String spaceId);
  Future<Either<MatrixFailure, MatrixSpace>> createSpace({
    required String name,
    String? description,
    bool isPublic = false,
  });

  Future<Either<MatrixFailure, List<MatrixRoom>>> getSpaceRooms(String spaceId);
  Future<Either<MatrixFailure, bool>> joinSpace(String spaceId);
  Future<Either<MatrixFailure, bool>> leaveSpace(String spaceId);
  Future<Either<MatrixFailure, bool>> addRoomToSpace(
    String spaceId,
    String roomId,
  );
  Future<Either<MatrixFailure, bool>> removeRoomFromSpace(
    String spaceId,
    String roomId,
  );

  // Message management
  Future<Either<MatrixFailure, List<MatrixMessage>>> getMessages(
    String roomId, {
    int limit = 50,
    String? fromToken,
  });

  Future<Either<MatrixFailure, MatrixMessage>> sendMessage({
    required String roomId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToEventId,
  });

  // Stream<Either<MatrixFailure, MatrixMessage>> streamMessages(String roomId);

  Future<Either<MatrixFailure, bool>> editMessage({
    required String roomId,
    required String eventId,
    required String newContent,
  });

  Future<Either<MatrixFailure, bool>> deleteMessage({
    required String roomId,
    required String eventId,
  });

  Future<Either<MatrixFailure, bool>> addReaction({
    required String roomId,
    required String eventId,
    required String emoji,
  });

  Future<Either<MatrixFailure, bool>> removeReaction({
    required String roomId,
    required String eventId,
    required String emoji,
  });

  // File operations
  Future<Either<MatrixFailure, String>> uploadFile({
    required String filePath,
    required String fileName,
    String? mimeType,
  });

  Future<Either<MatrixFailure, bool>> sendFileMessage({
    required String roomId,
    required String fileUrl,
    required String fileName,
    MessageType type = MessageType.file,
  });

  // Sync operations
  Stream<Either<MatrixFailure, Map<String, dynamic>>> getSyncStream();
  Future<Either<MatrixFailure, bool>> startSync();
  Future<Either<MatrixFailure, bool>> stopSync();

  // Presence and typing indicators
  Future<Either<MatrixFailure, bool>> setPresence(UserPresence presence);
  Future<Either<MatrixFailure, bool>> sendTypingIndicator(
    String roomId,
    bool isTyping,
  );

  // Encryption
  Future<Either<MatrixFailure, bool>> enableEncryption(String roomId);
  Future<Either<MatrixFailure, bool>> verifyDevice(
    String userId,
    String deviceId,
  );

  // Search
  Future<Either<MatrixFailure, List<MatrixMessage>>> searchMessages({
    required String query,
    String? roomId,
    int limit = 20,
  });

  Future<Either<MatrixFailure, List<MatrixRoom>>> searchRooms({
    required String query,
    int limit = 20,
  });

  Future<Either<MatrixFailure, List<MatrixUser>>> searchUsers({
    required String query,
    int limit = 20,
  });
}
