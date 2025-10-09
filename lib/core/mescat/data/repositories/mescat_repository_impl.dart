import 'dart:async';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/mescat/matrix_client.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/core/mescat/domain/repositories/matrix_repository.dart';
import 'package:uuid/rng.dart';

final class MCRepositoryImpl implements MCRepository {
  final MatrixClientManager _matrixClientManager;

  const MCRepositoryImpl(this._matrixClientManager);

  @override
  Future<Either<MCFailure, bool>> addReaction({
    required String roomId,
    required String eventId,
    required String emoji,
  }) {
    // _matrixClientManager.client.se
    return Future.value(Left(UnknownFailure(message: 'Not implemented')));
  }

  @override
  Future<Either<MCFailure, bool>> addRoomToSpace(
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
  Future<Either<MCFailure, MatrixRoom>> createRoom({
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
  Future<Either<MCFailure, List<MCUser>>> getRoomMembers(String roomId) async {
    final members = await _matrixClientManager.client.getMembersByRoom(roomId);

    if (members == null) {
      return Right([]);
    }

    final matrixUsers = members.map((member) async {
      final user = await _matrixClientManager.client.getUserProfile(
        member.senderId,
      );

      final presence = await _matrixClientManager.client.getPresence(
        member.senderId,
      );
      final isOnline = presence.presence == PresenceType.online;
      return MCUser(
        displayName: user.displayname,
        userId: member.senderId,
        avatarUrl: user.avatarUrl?.toString(),
        isOnline: isOnline,
      );
    }).toList();

    return Right(await Future.wait(matrixUsers));
  }

  @override
  Future<Either<MCFailure, MatrixSpace>> createSpace({
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
  Future<Either<MCFailure, bool>> deleteMessage({
    required String roomId,
    required String eventId,
  }) async {
    // await _matrixClientManager.client.deleteEvent(roomId, eventId);
    return Right(true);
  }

  @override
  Future<Either<MCFailure, bool>> editMessage({
    required String roomId,
    required String eventId,
    required String newContent,
  }) {
    return Future.value(Left(UnknownFailure(message: 'Not implemented')));
  }

  @override
  Future<Either<MCFailure, bool>> enableEncryption(String roomId) {
    return Future.value(Left(UnknownFailure(message: 'Not implemented')));
  }

  @override
  Future<Either<MCFailure, MCUser>> getCurrentUser() async {
    final userId = _matrixClientManager.client.userID;
    if (userId != null) {
      final userProfile = await _matrixClientManager.client.getUserProfile(
        userId,
      );
      return Right(
        MCUser(displayName: userProfile.displayname, userId: userId),
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
  Future<Either<MCFailure, List<MCMessageEvent>>> getMessages(
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

    final mtEvents = eventsResponse.chunk;

    final List<MCMessageEvent> matrixMessages = [];

    for (final mtEvent in mtEvents) {
      log('Processing event: ${mtEvent.eventId}, content: ${mtEvent.content}');
      switch (mtEvent.type) {
        case EventTypes.Message:
          {
            final room = _matrixClientManager.client.getRoomById(roomId);
            MatrixFile? file;
            if (room != null) {
              final event = Event.fromMatrixEvent(mtEvent, room);

              if (event.hasAttachment) {
                file = await event.downloadAndDecryptAttachment();
              }

              final messageEvent = await _mapMessageEvent(
                mtEvent,
                roomId,
                file,
              );
              if (messageEvent != null) {
                matrixMessages.add(messageEvent);
              }
            }
          }
          break;
        case EventTypes.Encrypted:
          {}
          break;
        case EventTypes.Redaction:
          break;
        case EventTypes.Reaction:
          {
            final object =
                mtEvent.content['m.relates_to'] as Map<String, dynamic>?;
            final reactedEventId = object?['event_id'] as String?;
            final key = object?['key'] as String?;

            final index = matrixMessages.indexWhere(
              (msg) => msg.eventId == reactedEventId,
            );
            if (index != -1) {
              final isExist = matrixMessages[index].reactions.any(
                (react) =>
                    react.key == key && react.relatedEventId == reactedEventId,
              );

              if (isExist) {
                final msg = matrixMessages[index];
                final reactions = List<MCReactionEvent>.from(msg.reactions);
                final reactIndex = reactions.indexWhere(
                  (react) =>
                      react.key == key &&
                      react.relatedEventId == reactedEventId,
                );

                final senderName =
                    (await _matrixClientManager.client.getUserProfile(
                      mtEvent.senderId,
                    )).displayname;

                final existedReaction = reactions.removeAt(reactIndex);
                reactions.add(
                  existedReaction.copyWith(
                    senderDisplayNames: [
                      ...existedReaction.senderDisplayNames,
                      senderName,
                    ],
                    reactEventIds: [
                      ...existedReaction.reactEventIds,
                      MapEntry(mtEvent.eventId, mtEvent.senderId),
                    ],
                    isCurrentUser:
                        mtEvent.senderId == _matrixClientManager.client.userID,
                  ),
                );
                matrixMessages[index] = msg.copyWith(reactions: reactions);
              } else {
                if (key != null && reactedEventId != null) {
                  final reactEvent = MCReactionEvent(
                    key: key,
                    relatedEventId: reactedEventId,
                    reactEventIds: [
                      MapEntry(mtEvent.eventId, mtEvent.senderId),
                    ],
                    eventId: mtEvent.eventId,
                    roomId: roomId,
                    senderId: mtEvent.senderId,
                    timestamp: mtEvent.originServerTs,
                    eventTypes: mtEvent.type,
                    senderDisplayNames: [mtEvent.senderId],
                    isCurrentUser:
                        mtEvent.senderId == _matrixClientManager.client.userID,
                  );
                  final msg = matrixMessages[index];
                  final reactions = List<MCReactionEvent>.from(msg.reactions);
                  reactions.add(reactEvent);
                  matrixMessages[index] = msg.copyWith(reactions: reactions);
                }
              }
            }
          }
          break;
        case EventTypes.RoomMember:
          break;
        case EventTypes.RoomName:
          break;
        case EventTypes.RoomTopic:
          break;
        case EventTypes.RoomAvatar:
          break;
        case EventTypes.SpaceChild:
          break;
        case EventTypes.SpaceParent:
          break;
        default:
          {
            break;
          }
      }
    }

    // EventTypes

    return Right(matrixMessages);
  }

  @override
  Future<Either<MCFailure, MatrixRoom>> getRoom(String roomId) async {
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
  Future<Either<MCFailure, List<MatrixRoom>>> getRooms() async {
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
  Future<Either<MCFailure, MatrixSpace>> getSpace(String spaceId) async {
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
  Future<Either<MCFailure, List<MatrixRoom>>> getSpaceRooms(
    String spaceId,
  ) async {
    final spaceHierachie = await _matrixClientManager.client.getSpaceHierarchy(
      spaceId,
    );

    final rooms = spaceHierachie.rooms
        .map((room) {
          final isVoiceRoom =
              room.roomType != null &&
              room.roomType == 'org.matrix.msc3417.call';
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
  Future<Either<MCFailure, List<MatrixSpace>>> getSpaces() async {
    final roomsId = await _matrixClientManager.client.getJoinedRooms();

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
  Stream<Either<MCFailure, Map<String, dynamic>>> getSyncStream() {
    return Stream.error(Left(UnknownFailure(message: 'Not implemented')));
  }

  @override
  Future<Either<MCFailure, MCUser>> getUser(String userId) async {
    final user = await _matrixClientManager.client.getUserProfile(userId);
    return Right(
      MCUser(
        displayName: user.displayname,
        userId: userId,
        avatarUrl: user.avatarUrl.toString(),
      ),
    );
  }

  @override
  Future<Either<MCFailure, bool>> inviteToRoom(
    String roomId,
    String userId,
  ) async {
    await _matrixClientManager.client.inviteUser(roomId, userId);
    return Right(true);
  }

  @override
  Future<Either<MCFailure, bool>> joinRoom(String roomId) async {
    await _matrixClientManager.client.joinRoom(roomId);
    return Right(true);
  }

  @override
  Future<Either<MCFailure, bool>> joinSpace(String spaceId) async {
    return Right(true);
  }

  @override
  Future<Either<MCFailure, bool>> leaveRoom(String roomId) async {
    await _matrixClientManager.client.leaveRoom(roomId);
    return Right(true);
  }

  @override
  Future<Either<MCFailure, bool>> leaveSpace(String spaceId) async {
    return Right(true);
  }

  @override
  Future<Either<MCFailure, bool>> login({
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
  Future<Either<MCFailure, bool>> logout() async {
    await _matrixClientManager.client.logout();
    return Right(true);
  }

  @override
  Future<Either<MCFailure, bool>> register({
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
  Future<Either<MCFailure, bool>> removeReaction({
    required String roomId,
    required String eventId,
    required String emoji,
  }) async {
    final txnId = CryptoRNG().generate().toString();
    await _matrixClientManager.client.redactEvent(roomId, eventId, txnId);
    return Future.value(Right(true));
  }

  @override
  Future<Either<MCFailure, bool>> removeRoomFromSpace(
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
  Future<Either<MCFailure, List<MCMessageEvent>>> searchMessages({
    required String query,
    String? roomId,
    int limit = 20,
  }) async {
    return Left(UnknownFailure(message: 'Failed to search messages'));
  }

  @override
  Future<Either<MCFailure, List<MatrixRoom>>> searchRooms({
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
  Future<Either<MCFailure, List<MCUser>>> searchUsers({
    required String query,
    int limit = 20,
  }) {
    return Future.value(Left(UnknownFailure(message: 'Not implemented')));
  }

  @override
  Future<Either<MCFailure, bool>> sendFileMessage({
    required String roomId,
    required String fileUrl,
    required String fileName,
    String type = MessageTypes.File,
  }) {
    return Future.value(Left(UnknownFailure(message: 'Not implemented')));
  }

  @override
  Future<Either<MCFailure, MCMessageEvent>> sendMessage({
    required String roomId,
    required String content,
    String msgtype = MessageTypes.Text,
    String eventType = EventTypes.Message,
    String? replyToEventId,
  }) async {
    final transactionId = CryptoRNG().generate().toString();
    final result = await _matrixClientManager.client.sendMessage(
      roomId,
      eventType,
      transactionId,
      Map.from({'body': content, 'msgtype': msgtype}),
    );

    return Right(
      MCMessageEvent(
        eventTypes: eventType,
        eventId: result,
        roomId: roomId,
        senderId: _matrixClientManager.client.userID ?? 'unknown',
        msgtype: msgtype,
        body: content,
        senderDisplayName: await _matrixClientManager.currentUserDisplayName,
        timestamp: DateTime.now(),
        isCurrentUser: true,
      ),
    );
  }

  @override
  Future<Either<MCFailure, bool>> sendTypingIndicator(
    String roomId,
    bool isTyping,
  ) {
    return Future.value(Right(true));
  }

  @override
  Future<Either<MCFailure, bool>> setPresence(UserPresence presence) {
    return Future.value(Right(true));
  }

  @override
  Future<Either<MCFailure, bool>> startSync() {
    return Future.value(Right(true));
  }

  @override
  Future<Either<MCFailure, bool>> stopSync() {
    return Future.value(Right(true));
  }

  @override
  Future<Either<MCFailure, bool>> updateUserProfile({
    String? displayName,
    String? avatarUrl,
  }) {
    return Future.value(Right(true));
  }

  @override
  Future<Either<MCFailure, String>> uploadFile({
    required String filePath,
    required String fileName,
    String? mimeType,
  }) {
    return Future.value(Left(UnknownFailure(message: 'Not implemented')));
  }

  @override
  Future<Either<MCFailure, bool>> verifyDevice(String userId, String deviceId) {
    return Future.value(Right(true));
  }

  Future<MCMessageEvent?> _mapMessageEvent(
    MatrixEvent event,
    String roomId,
    MatrixFile? file,
  ) async {
    final eventType = (event.content['msgtype'] as String?);
    final senderName = await _matrixClientManager.client.getUserProfile(
      event.senderId,
    );

    switch (eventType) {
      case MessageTypes.Text:
        {
          final content = event.content['body'] as String? ?? '';
          return MCMessageEvent(
            eventTypes: EventTypes.Message,
            eventId: event.eventId,
            senderDisplayName: senderName.displayname,
            roomId: roomId,
            senderId: event.senderId,
            msgtype: eventType!,
            body: content,
            timestamp: event.originServerTs,
            isCurrentUser: event.senderId == _matrixClientManager.client.userID,
          );
        }
      case MessageTypes.Image:
        {
          final info = event.content['info'] as Map<String, dynamic>? ?? {};
          final thumbnailInfo =
              info['thumbnail_info'] as Map<String, dynamic>? ?? {};

          return MCImageEvent(
            height: thumbnailInfo['h'] as int? ?? 0,
            width: thumbnailInfo['w'] as int? ?? 0,
            mimeType: thumbnailInfo['mimetype'] as String? ?? '',
            eventId: event.eventId,
            senderDisplayName: senderName.displayname,
            roomId: roomId,
            senderId: event.senderId,
            msgtype: eventType!,
            timestamp: event.originServerTs,
            file: file!,
            isCurrentUser: event.senderId == _matrixClientManager.client.userID,
          );
        }
      case MessageTypes.File:
        {
          final content = event.content['body'] as String? ?? '';
          return MCMessageEvent(
            eventTypes: EventTypes.Message,
            eventId: event.eventId,
            senderDisplayName: senderName.displayname,
            roomId: roomId,
            senderId: event.senderId,
            msgtype: eventType!,
            body: content,
            timestamp: event.originServerTs,
            file: file,
            isCurrentUser: event.senderId == _matrixClientManager.client.userID,
          );
        }
      case MessageTypes.Audio:
        {
          final content = event.content['body'] as String? ?? '';
          return MCMessageEvent(
            eventTypes: EventTypes.Message,
            eventId: event.eventId,
            senderDisplayName: senderName.displayname,
            roomId: roomId,
            senderId: event.senderId,
            msgtype: eventType!,
            body: content,
            timestamp: event.originServerTs,
            isCurrentUser: event.senderId == _matrixClientManager.client.userID,
          );
        }
      case MessageTypes.Video:
        {
          final content = event.content['body'] as String? ?? '';
          return MCMessageEvent(
            eventTypes: EventTypes.Message,
            eventId: event.eventId,
            senderDisplayName: senderName.displayname,
            roomId: roomId,
            senderId: event.senderId,
            msgtype: eventType!,
            body: content,
            timestamp: event.originServerTs,
            isCurrentUser: event.senderId == _matrixClientManager.client.userID,
            file: file,
          );
        }
      default:
        {
          return null;
        }
    }
  }
}
