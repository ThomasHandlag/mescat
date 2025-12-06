import 'package:dartz/dartz.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:matrix/matrix.dart';

/// Repository interface for Matrix client operations
abstract class MCRepository {
  // Authentication
  Future<Either<MCFailure, MCUser>> login({
    required String username,
    required String password,
    String? serverUrl,
  });

  Future<Either<MCFailure, bool>> register({
    required String username,
    required String password,
    String? email,
  });

  Future<Either<MCFailure, MCUser>> oauthLogin({required String token});

  Future<Either<MCFailure, bool>> logout();

  // User management
  Future<Either<MCFailure, MCUser>> getCurrentUser();
  Future<Either<MCFailure, MCUser>> getUser(String userId);
  Future<Either<MCFailure, bool>> updateUserProfile({
    String? displayName,
    String? avatarUrl,
  });

  // Room management
  Future<Either<MCFailure, List<MatrixRoom>>> getRooms();
  Future<Either<MCFailure, MatrixRoom>> getRoom(String roomId);
  Future<Either<MCFailure, MatrixRoom>> createRoom({
    required String name,
    String? topic,
    RoomType type = RoomType.textChannel,
    bool isPublic = false,
    String? parentSpaceId,
  });
  Future<Either<MCFailure, bool>> joinRoom(String roomId);
  Future<Either<MCFailure, bool>> leaveRoom(String roomId);
  Future<Either<MCFailure, bool>> inviteToRoom(String roomId, String userId);

  // Space management
  Future<Either<MCFailure, List<MatrixSpace>>> getSpaces();
  Future<Either<MCFailure, MatrixSpace>> getSpace(String spaceId);
  Future<Either<MCFailure, MatrixSpace>> createSpace({
    required String name,
    String? description,
    bool isPublic = false,
  });

  Future<Either<MCFailure, List<MatrixRoom>>> getSpaceRooms(String spaceId);
  Future<Either<MCFailure, bool>> joinSpace(String spaceId);
  Future<Either<MCFailure, bool>> leaveSpace(String spaceId);
  Future<Either<MCFailure, bool>> addRoomToSpace(String spaceId, String roomId);
  Future<Either<MCFailure, bool>> removeRoomFromSpace(
    String spaceId,
    String roomId,
  );

  Future<Either<MCFailure, List<MCUser>>> getRoomMembers(String roomId);

  // Message management
  Future<Either<MCFailure, Map<String, dynamic>>> getMessages(
    String roomId, {
    int limit = 100,
    String? fromToken,
    String? filter,
    String? toToken,
  });

  Future<Either<MCFailure, MCMessageEvent>> sendMessage({
    required String roomId,
    required String content,
    String msgtype = MessageTypes.Text,
    bool viaToken = false
  });

  // Stream<Either<MatrixFailure, MatrixMessage>> streamMessages(String roomId);

  Future<Either<MCFailure, MCMessageEvent>> editMessage({
    required String roomId,
    required String eventId,
    required String newContent,
  });

  Future<Either<MCFailure, bool>> deleteMessage({
    required String roomId,
    required String eventId,
  });

  Future<Either<MCFailure, bool>> addReaction({
    required String roomId,
    required String eventId,
    required String emoji,
  });

  Future<Either<MCFailure, bool>> removeReaction({
    required String roomId,
    required String eventId,
    required String emoji,
  });

  // File operations
  Future<Either<MCFailure, String>> uploadFile({
    required String filePath,
    required String fileName,
    String? mimeType,
  });

  Future<Either<MCFailure, bool>> sendFileMessage({
    required String roomId,
    required String fileUrl,
    required String fileName,
    String type = MessageTypes.File,
  });

  // Sync operations
  Stream<Either<MCFailure, Map<String, dynamic>>> getSyncStream();
  Future<Either<MCFailure, bool>> startSync();
  Future<Either<MCFailure, bool>> stopSync();

  // Presence and typing indicators
  Future<Either<MCFailure, bool>> setPresence(UserPresence presence);
  Future<Either<MCFailure, bool>> sendTypingIndicator(
    String roomId,
    bool isTyping,
  );

  // Encryption
  Future<Either<MCFailure, bool>> enableEncryption(String roomId);
  Future<Either<MCFailure, bool>> verifyDevice(String userId, String deviceId);

  // Search
  Future<Either<MCFailure, List<MCMessageEvent>>> searchMessages({
    required String query,
    String? roomId,
    int limit = 20,
  });

  Future<Either<MCFailure, List<MatrixRoom>>> searchRooms({
    required String query,
    int limit = 20,
  });

  Future<Either<MCFailure, List<MCUser>>> searchUsers({
    required String query,
    int limit = 20,
  });

  // reply a message
  Future<Either<MCFailure, MCMessageEvent>> replyMessage({
    required String roomId,
    required String content,
    required String replyToEventId,
    String msgtype = MessageTypes.Text,
    bool viaToken = false,
  });

  // edit message
  Future<Either<MCFailure, MCMessageEvent>> editMessageContent({
    required String roomId,
    required String eventId,
    required String newContent,
  });

  Future<Either<MCFailure, bool>> setServer(String serverUrl);

  Future<Either<MCFailure, MatrixRoom>> updateRoom(MatrixRoom room);

  Future<Either<MCFailure, bool>> startCall({
    required String roomId,
    required bool isVideo,
  });
  Future<Either<MCFailure, bool>> endCall({required String roomId});
  Future<Either<MCFailure, bool>> toggleAudio({required bool isMuted});
  Future<Either<MCFailure, bool>> toggleVideo({required bool isCameraOn});
  Future<Either<MCFailure, bool>> switchCamera();
  Future<Either<MCFailure, List<CallParticipant>>> getCallParticipants({
    required String roomId,
  });

  // Push notifications
  Future<Either<MCFailure, bool>> registerPusher({
    required String pushkey,
    required String appId,
    String? pushGatewayUrl,
    String? deviceDisplayName,
    String? lang,
  });

  Future<Either<MCFailure, bool>> unregisterPusher({
    required String pushkey,
    required String appId,
  });

  // Notification management
  Future<Either<MCFailure, Map<String ,dynamic>>> getNotifications();
}
