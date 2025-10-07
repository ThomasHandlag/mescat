import 'dart:async';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/errors/matrix_failures.dart';
import 'package:mescat/core/matrix/matrix_client.dart';
import 'package:mescat/core/matrix/domain/entities/matrix_entities.dart';
import 'package:mescat/core/matrix/domain/repositories/matrix_repository.dart';
import 'package:uuid/rng.dart';

final class MatrixRepositoryImpl implements MatrixRepository {
  final MatrixClientManager _matrixClientManager;

  const MatrixRepositoryImpl(this._matrixClientManager);

  @override
  Future<Either<MatrixFailure, bool>> addReaction({
    required String roomId,
    required String eventId,
    required String emoji,
  }) {
    return Future.value(Left(UnknownFailure(message: 'Not implemented')));
  }

  @override
  Future<Either<MatrixFailure, bool>> addRoomToSpace(
    String spaceId,
    String roomId,
  ) async {
    final space = _matrixClientManager.client.getRoomById(spaceId);
    final room = _matrixClientManager.client.getRoomById(roomId);
    if (space == null || room == null) {
      return Left(RoomFailure(message: 'Space or Room not found'));
    }

    try {
      // Add the room as a child in the space using proper Matrix client API
      final string = await space.client.setRoomStateWithKey(
        spaceId,
        EventTypes.SpaceChild,
        roomId,
        {
          'via': [space.client.homeserver?.host ?? 'matrix.org'],
          'order': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );

      log('Add room to space response: $string');

      // Set the space as a parent in the room using proper Matrix client API
      await room.client.setRoomStateWithKey(
        roomId,
        EventTypes.SpaceParent,
        spaceId,
        {
          'via': [space.client.homeserver?.host ?? 'matrix.org'],
          'canonical': true,
        },
      );

      return Right(true);
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to add room to space: $e'));
    }
  }

  @override
  Future<Either<MatrixFailure, MatrixRoom>> createRoom({
    required String name,
    String? topic,
    RoomType type = RoomType.textChannel,
    bool isPublic = false,
    String? parentSpaceId,
  }) async {
    final isDirect = parentSpaceId == null || parentSpaceId.isEmpty;
    String roomId = await _matrixClientManager.client.createRoom(
      name: name,
      topic: topic,
      isDirect: isDirect,
      visibility: isPublic ? Visibility.public : Visibility.private,
    );

    if (parentSpaceId != null && parentSpaceId.isNotEmpty) {
      await addRoomToSpace(parentSpaceId, roomId);
    }
    return Right(
      MatrixRoom(
        roomId: roomId,
        name: name,
        topic: topic,
        type: type,
        isPublic: isPublic,
        parentSpaceId: parentSpaceId,
      ),
    );
  }

  @override
  Future<Either<MatrixFailure, MatrixSpace>> createSpace({
    required String name,
    String? description,
    bool isPublic = false,
  }) async {
    String spaceId = await _matrixClientManager.client.createSpace(
      name: name,
      topic: description,
      visibility: isPublic ? Visibility.public : Visibility.private,
    );

    return Right(
      MatrixSpace(
        spaceId: spaceId,
        name: name,
        description: description,
        isPublic: isPublic,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Either<MatrixFailure, bool>> deleteMessage({
    required String roomId,
    required String eventId,
  }) async {
    return Right(true);
  }

  @override
  Future<Either<MatrixFailure, bool>> editMessage({
    required String roomId,
    required String eventId,
    required String newContent,
  }) {
    return Future.value(Left(UnknownFailure(message: 'Not implemented')));
  }

  @override
  Future<Either<MatrixFailure, bool>> enableEncryption(String roomId) {
    return Future.value(Left(UnknownFailure(message: 'Not implemented')));
  }

  @override
  Future<Either<MatrixFailure, MatrixUser>> getCurrentUser() async {
    final userId = _matrixClientManager.client.userID;
    if (userId != null) {
      final userProfile = await _matrixClientManager.client.getUserProfile(
        userId,
      );
      return Right(
        MatrixUser(displayName: userProfile.displayname, userId: userId),
      );
    } else {
      return Left(AuthenticationFailure(message: 'No user logged in'));
    }
  }

  // @override
  // Stream<Either<MatrixFailure, MatrixMessage>> streamMessages(String roomId) {
  //   final controller = StreamController<Either<MatrixFailure, MatrixMessage>>();
  //   _matrixClientManager.client.onTimelineEvent.stream.listen((event) {
  //     if (event.roomId == roomId) {
  //       final content = event.content['body'] as String? ?? '';
  //       if (content.isNotEmpty) {
  //         final message = MatrixMessage(
  //           eventId: event.eventId,
  //           senderDisplayName: null,
  //           roomId: roomId,
  //           senderId: event.senderId,
  //           type: MessageType.text,
  //           content: content,
  //           timestamp: event.originServerTs,
  //         );
  //         controller.add(Right(message));
  //       }
  //     }
  //   });

  //   return controller.stream;
  // }

  @override
  Future<Either<MatrixFailure, List<MatrixMessage>>> getMessages(
    String roomId, {
    int limit = 50,
    String? fromToken,
  }) async {
    final eventsResponse = await _matrixClientManager.client.getRoomEvents(
      roomId,
      Direction.f,
      limit: limit,
      from: fromToken,
    );

    final events = eventsResponse.chunk;

    final List<MatrixMessage> matrixMessages = [];

    for (final event in events) {
      final content = event.content['body'] as String? ?? '';
      if (content.isEmpty) continue;

      final senderName = await _matrixClientManager.client.getUserProfile(
        event.senderId,
      );

      log('Event type: ${event.type}, content: $content');

      matrixMessages.add(
        MatrixMessage(
          eventId: event.eventId,
          senderDisplayName: senderName.displayname,
          roomId: roomId,
          senderId: event.senderId,
          type: event.type.toMessageType(),
          content: content,
          timestamp: event.originServerTs,
        ),
      );
    }

    return Right(matrixMessages);
  }

  @override
  Future<Either<MatrixFailure, MatrixRoom>> getRoom(String roomId) async {
    final room = _matrixClientManager.client.getRoomById(roomId);
    if (room != null) {
      return Right(
        MatrixRoom(
          roomId: roomId,
          name: room.name,
          topic: room.topic,
          type: RoomType.directMessage,
          isPublic: room.isFederated,
        ),
      );
    } else {
      return Left(RoomFailure(message: 'Room not found'));
    }
  }

  @override
  Future<Either<MatrixFailure, List<MatrixRoom>>> getRooms() async {
    final roomsId = await _matrixClientManager.client.getJoinedRooms();

    log('Joined rooms: $roomsId');

    final rooms = roomsId
        .map((roomId) {
          final room = _matrixClientManager.client.getRoomById(roomId);
          if (room != null && !room.isSpace && room.spaceParents.isEmpty) {
            return MatrixRoom(
              roomId: roomId,
              name: room.name,
              topic: room.topic,
              type: RoomType.directMessage,
              isPublic: room.isFederated,
            );
          } else {
            return null;
          }
        })
        .whereType<MatrixRoom>()
        .toList();

    log('Fetched rooms: $rooms');

    return Right(rooms);
  }

  @override
  Future<Either<MatrixFailure, MatrixSpace>> getSpace(String spaceId) async {
    final spaceHierachie = await _matrixClientManager.client.getSpaceHierarchy(
      spaceId,
    );
    log('Fetching space with ID: $spaceId');
    log('Spaces: ${spaceHierachie.rooms}');

    final spaceInfo = _matrixClientManager.client.getRoomById(spaceId);

    final space = MatrixSpace(
      spaceId: spaceId,
      name: spaceInfo?.name ?? 'Unnamed Space',
      description: spaceInfo?.topic ?? 'No description',
      isPublic: spaceInfo?.guestAccess == GuestAccess.canJoin,
      createdAt: DateTime.now(),
      childRoomIds: spaceHierachie.rooms.map((r) => r.roomId).toList(),
    );

    return Right(space);
  }

  @override
  Future<Either<MatrixFailure, List<MatrixRoom>>> getSpaceRooms(
    String spaceId,
  ) async {
    final spaceHierachie = await _matrixClientManager.client.getSpaceHierarchy(
      spaceId,
    );

    final rooms = spaceHierachie.rooms
        .map((room) {
          log('Room in space: ${room.roomId}: ${room.toJson()}');
          final isVoiceRoom = room.roomType != null && room.roomType == 'org.matrix.msc3417.call';
          if (room.roomId != spaceId) {
            return MatrixRoom(
              roomId: room.roomId,
              name: room.name,
              topic: room.topic,
              type: isVoiceRoom ? RoomType.voiceChannel : RoomType.textChannel,
              isPublic: room.guestCanJoin,
              parentSpaceId: spaceId,
              
            );
          }
        })
        .whereType<MatrixRoom>()
        .toList();

    return Right(rooms);
  }

  @override
  Future<Either<MatrixFailure, List<MatrixSpace>>> getSpaces() async {
    final roomsId = await _matrixClientManager.client.getJoinedRooms();

    log('Joined rooms: $roomsId');

    final spaces = roomsId
        .map((roomId) {
          final room = _matrixClientManager.client.getRoomById(roomId);
          if (room != null && room.isSpace) {
            return MatrixSpace(
              spaceId: roomId,
              name: room.name,
              description: room.topic,
              isPublic: room.isFederated,
              createdAt: DateTime.now(),
            );
          } else {
            return null;
          }
        })
        .whereType<MatrixSpace>()
        .toList();

    return Right(spaces);
  }

  @override
  Stream<Either<MatrixFailure, Map<String, dynamic>>> getSyncStream() {
    return Stream.error(Left(UnknownFailure(message: 'Not implemented')));
  }

  @override
  Future<Either<MatrixFailure, MatrixUser>> getUser(String userId) async {
    final user = await _matrixClientManager.client.getUserProfile(userId);
    return Right(
      MatrixUser(
        displayName: user.displayname,
        userId: userId,
        avatarUrl: user.avatarUrl.toString(),
      ),
    );
  }

  @override
  Future<Either<MatrixFailure, bool>> inviteToRoom(
    String roomId,
    String userId,
  ) async {
    await _matrixClientManager.client.inviteUser(roomId, userId);
    return Right(true);
  }

  @override
  Future<Either<MatrixFailure, bool>> joinRoom(String roomId) async {
    await _matrixClientManager.client.joinRoom(roomId);
    return Right(true);
  }

  @override
  Future<Either<MatrixFailure, bool>> joinSpace(String spaceId) async {
    return Right(true);
  }

  @override
  Future<Either<MatrixFailure, bool>> leaveRoom(String roomId) async {
    await _matrixClientManager.client.leaveRoom(roomId);
    return Right(true);
  }

  @override
  Future<Either<MatrixFailure, bool>> leaveSpace(String spaceId) async {
    return Right(true);
  }

  @override
  Future<Either<MatrixFailure, bool>> login({
    required String username,
    required String password,
  }) async {
    try {
      await _matrixClientManager.client.login(
        LoginType.mLoginPassword,
        password: password,
        identifier: AuthenticationUserIdentifier(user: username),
      );
      return Right(true);
    } catch (e) {
      return Left(AuthenticationFailure(message: 'Login failed: $e'));
    }
  }

  @override
  Future<Either<MatrixFailure, bool>> logout() async {
    await _matrixClientManager.client.logout();
    return Right(true);
  }

  @override
  Future<Either<MatrixFailure, bool>> register({
    required String username,
    required String password,
    String? email,
  }) async {
    final result = await _matrixClientManager.client.register(
      username: username,
      password: password,
    );

    if (result.accessToken == null) {
      return Left(AuthenticationFailure(message: 'Registration failed'));
    }
    return Right(true);
  }

  @override
  Future<Either<MatrixFailure, bool>> removeReaction({
    required String roomId,
    required String eventId,
    required String emoji,
  }) {
    return Future.value(Left(UnknownFailure(message: 'Not implemented')));
  }

  @override
  Future<Either<MatrixFailure, bool>> removeRoomFromSpace(
    String spaceId,
    String roomId,
  ) async {
    final space = _matrixClientManager.client.getRoomById(spaceId);
    final room = _matrixClientManager.client.getRoomById(roomId);
    if (space == null || room == null) {
      return Left(RoomFailure(message: 'Space or Room not found'));
    }

    try {
      // Remove the room as a child from the space
      await space.client.setRoomStateWithKey(
        spaceId,
        EventTypes.SpaceChild,
        roomId,
        {},
      );

      // Remove the space as a parent from the room
      await room.client.setRoomStateWithKey(
        roomId,
        EventTypes.SpaceParent,
        spaceId,
        {},
      );

      return Right(true);
    } catch (e) {
      return Left(
        UnknownFailure(message: 'Failed to remove room from space: $e'),
      );
    }
  }

  @override
  Future<Either<MatrixFailure, List<MatrixMessage>>> searchMessages({
    required String query,
    String? roomId,
    int limit = 20,
  }) async {
    return Left(UnknownFailure(message: 'Failed to search messages'));
  }

  @override
  Future<Either<MatrixFailure, List<MatrixRoom>>> searchRooms({
    required String query,
    int limit = 20,
  }) async {
    final result = _matrixClientManager.client.getRoomByAlias(query);
    if (result != null) {
      return Right([
        MatrixRoom(
          roomId: result.id,
          name: result.name,
          topic: result.topic,
          type: RoomType.directMessage,
          isPublic: result.isFederated,
        ),
      ]);
    }
    return Left(UnknownFailure(message: 'Failed to search rooms'));
  }

  @override
  Future<Either<MatrixFailure, List<MatrixUser>>> searchUsers({
    required String query,
    int limit = 20,
  }) {
    return Future.value(Left(UnknownFailure(message: 'Not implemented')));
  }

  @override
  Future<Either<MatrixFailure, bool>> sendFileMessage({
    required String roomId,
    required String fileUrl,
    required String fileName,
    MessageType type = MessageType.file,
  }) {
    return Future.value(Left(UnknownFailure(message: 'Not implemented')));
  }

  @override
  Future<Either<MatrixFailure, MatrixMessage>> sendMessage({
    required String roomId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToEventId,
  }) async {
    final transactionId = CryptoRNG().generate().toString();
    final result = await _matrixClientManager.client.sendMessage(
      roomId,
      EventTypes.Message,
      transactionId,
      Map.from({'body': content, 'msgtype': 'm.text'}),
    );

    return Right(
      MatrixMessage(
        eventId: result,
        roomId: roomId,
        senderId: _matrixClientManager.client.userID ?? 'unknown',
        type: type,
        content: content,
        senderDisplayName: await _matrixClientManager.currentUserDisplayName,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Future<Either<MatrixFailure, bool>> sendTypingIndicator(
    String roomId,
    bool isTyping,
  ) {
    return Future.value(Right(true));
  }

  @override
  Future<Either<MatrixFailure, bool>> setPresence(UserPresence presence) {
    return Future.value(Right(true));
  }

  @override
  Future<Either<MatrixFailure, bool>> startSync() {
    return Future.value(Right(true));
  }

  @override
  Future<Either<MatrixFailure, bool>> stopSync() {
    return Future.value(Right(true));
  }

  @override
  Future<Either<MatrixFailure, bool>> updateUserProfile({
    String? displayName,
    String? avatarUrl,
  }) {
    return Future.value(Right(true));
  }

  @override
  Future<Either<MatrixFailure, String>> uploadFile({
    required String filePath,
    required String fileName,
    String? mimeType,
  }) {
    return Future.value(Left(UnknownFailure(message: 'Not implemented')));
  }

  @override
  Future<Either<MatrixFailure, bool>> verifyDevice(
    String userId,
    String deviceId,
  ) {
    return Future.value(Right(true));
  }
}
