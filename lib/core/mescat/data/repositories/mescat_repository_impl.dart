import 'dart:async';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:matrix/matrix.dart' hide Level;
import 'package:mescat/core/constants/matrix_constants.dart';
import 'package:mescat/core/mescat/matrix_client.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/core/mescat/domain/repositories/mescat_repository.dart';
import 'package:uuid/rng.dart';

final class MCRepositoryImpl implements MCRepository {
  final MatrixClientManager _matrixClientManager;

  const MCRepositoryImpl(this._matrixClientManager);

  @override
  Future<Either<MCFailure, bool>> addReaction({
    required String roomId,
    required String eventId,
    required String emoji,
  }) async {
    try {
      await _matrixClientManager.client.sendMessage(
        roomId,
        EventTypes.Reaction,
        CryptoRNG().generate().toString(),
        {
          'm.relates_to': {
            'event_id': eventId,
            'key': emoji,
            'rel_type': 'm.annotation',
          },
        },
      );
      return Future.value(const Right(true));
    } catch (e) {
      return Future.value(
        const Left(MessageFailure(message: 'Failed to add reaction')),
      );
    }
  }

  @override
  Future<Either<MCFailure, MCMessageEvent>> replyMessage({
    required String roomId,
    required String content,
    required String replyToEventId,
    String msgtype = MessageTypes.Text,
  }) async {
    // Construct the reply content according to Matrix spec
    final replyContent = {
      'msgtype': msgtype,
      'body': content,
      'm.relates_to': {
        'm.in_reply_to': {'event_id': replyToEventId},
      },
    };
    final txnId = CryptoRNG().generate().toString();

    final nEvenId = await _matrixClientManager.client.sendMessage(
      roomId,
      EventTypes.Message,
      txnId,
      replyContent,
    );

    return Right(
      MCMessageEvent(
        eventTypes: EventTypes.Message,
        eventId: nEvenId,
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
  Future<Either<MCFailure, MCMessageEvent>> editMessageContent({
    required String roomId,
    required String eventId,
    required String newContent,
  }) async {
    final editContent = {
      'msgtype': MessageTypes.Text,
      'body': newContent,
      'm.new_content': {'msgtype': MessageTypes.Text, 'body': newContent},
      'm.relates_to': {'rel_type': 'm.replace', 'event_id': eventId},
    };
    final txnId = CryptoRNG().generate().toString();

    final nEvenId = await _matrixClientManager.client.sendMessage(
      roomId,
      EventTypes.Message,
      txnId,
      editContent,
    );

    return Right(
      MCMessageEvent(
        eventTypes: EventTypes.Message,
        eventId: nEvenId,
        roomId: roomId,
        senderId: _matrixClientManager.client.userID ?? 'unknown',
        msgtype: MessageTypes.Text,
        body: newContent,
        senderDisplayName: await _matrixClientManager.currentUserDisplayName,
        timestamp: DateTime.now(),
        isCurrentUser: true,
      ),
    );
  }

  @override
  Future<Either<MCFailure, bool>> addRoomToSpace(
    String spaceId,
    String roomId,
  ) async {
    final space = _matrixClientManager.client.getRoomById(spaceId);
    final room = _matrixClientManager.client.getRoomById(roomId);
    if (space == null || room == null) {
      return const Left(RoomFailure(message: 'Space or Room not found'));
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

      return const Right(true);
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

    final room = _matrixClientManager.client.getRoomById(roomId);

    if (room == null) {
      return const Left(UnknownFailure(message: 'Failed to create room'));
    }
    return Right(
      MatrixRoom(
        roomId: roomId,
        name: name,
        topic: topic,
        type: type,
        isPublic: isPublic,
        parentSpaceId: parentSpaceId,
        room: room,
      ),
    );
  }

  @override
  Future<Either<MCFailure, List<MCUser>>> getRoomMembers(String roomId) async {
    final members = await _matrixClientManager.client.getMembersByRoom(roomId);

    if (members == null) {
      return const Right([]);
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
        avatarUrl: user.avatarUrl?.toFilePath(),
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
    final txnId = CryptoRNG().generate().toString();
    await _matrixClientManager.client.redactEvent(roomId, eventId, txnId);
    return const Right(true);
  }

  @override
  Future<Either<MCFailure, MCMessageEvent>> editMessage({
    required String roomId,
    required String eventId,
    required String newContent,
  }) async {
    try {
      final result = await _matrixClientManager.client.sendMessage(
        roomId,
        EventTypes.Message,
        CryptoRNG().generate().toString(),
        {
          'msgtype': MessageTypes.Text,
          'body': newContent,
          'm.new_content': {'msgtype': MessageTypes.Text, 'body': newContent},
          'm.relates_to': {'rel_type': 'm.replace', 'event_id': eventId},
        },
      );
      return Right(
        MCMessageEvent(
          eventTypes: EventTypes.Message,
          eventId: result,
          roomId: roomId,
          senderId: _matrixClientManager.client.userID ?? 'unknown',
          msgtype: MessageTypes.Text,
          body: newContent,
          senderDisplayName: await _matrixClientManager.currentUserDisplayName,
          timestamp: DateTime.now(),
          isCurrentUser: true,
        ),
      );
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to edit message: $e'));
    }
  }

  @override
  Future<Either<MCFailure, bool>> enableEncryption(String roomId) {
    return Future.value(const Left(UnknownFailure(message: 'Not implemented')));
  }

  @override
  Future<Either<MCFailure, MCUser>> getCurrentUser() async {
    final userId = _matrixClientManager.client.userID;
    if (_matrixClientManager.client.isLogged() && userId != null) {
      final userProfile = await _matrixClientManager.client.getUserProfile(
        userId,
      );
      return Right(
        MCUser(displayName: userProfile.displayname, userId: userId),
      );
    } else {
      return const Left(AuthenticationFailure(message: 'No user logged in'));
    }
  }

  @override
  Future<Either<MCFailure, List<MCMessageEvent>>> getMessages(
    String roomId, {
    int limit = 150,
    String? fromToken,
    String? filter,
    String? toToken,
  }) async {
    final eventsResponse = await _matrixClientManager.client.getRoomEvents(
      roomId,
      Direction.b,
      limit: limit,
      filter: filter,
      from: fromToken,
      to: toToken,
    );

    final mtEvents = eventsResponse.chunk;

    MCEvent.startToken = eventsResponse.start;
    MCEvent.endToken = eventsResponse.end;

    final List<MCMessageEvent> matrixMessages = [];

    for (final mtEvent in mtEvents.reversed) {
      switch (mtEvent.type) {
        case EventTypes.Message:
          {
            final room = _matrixClientManager.client.getRoomById(roomId);
            if (mtEvent.content.isEmpty) {
              continue;
            }
            if (room != null) {
              final event = Event.fromMatrixEvent(mtEvent, room);
              final user = await _matrixClientManager.client.getUserProfile(
                mtEvent.senderId,
              );

              MatrixFile? file;
              RepliedEventContent? repliedEventContent;
              final text = event.content['body'] as String? ?? '';
              final imageInfo = event.content['info'] as Map<String, dynamic>?;
              final width = imageInfo != null ? imageInfo['w'] : null;
              final height = imageInfo != null ? imageInfo['h'] : null;

              if (event.hasAttachment) {
                file = await event.downloadAndDecryptAttachment();
              }

              if (event.relationshipType == RelationshipTypes.reply) {
                final repliedMTEvent = await _matrixClientManager.client
                    .getOneRoomEvent(roomId, event.relationshipEventId!);

                final repliedEvent = Event.fromMatrixEvent(
                  repliedMTEvent,
                  room,
                );
                final repliedEventMsgtype =
                    repliedMTEvent.content['msgtype'] as String? ??
                    MessageTypes.Text;

                final senderName =
                    (await _matrixClientManager.client.getUserProfile(
                      repliedEvent.senderId,
                    )).displayname;
                final content = switch (repliedEventMsgtype) {
                  MessageTypes.Text =>
                    repliedMTEvent.content['body'] as String? ?? '',
                  _ => repliedEvent.attachmentMimetype,
                };
                repliedEventContent = RepliedEventContent(
                  content: content,
                  eventId: repliedMTEvent.eventId,
                  senderName: senderName ?? repliedEvent.senderId,
                );
              }
              final messageEvent = MCMessageEvent(
                eventId: mtEvent.eventId,
                roomId: roomId,
                senderId: mtEvent.senderId,
                senderDisplayName: user.displayname ?? mtEvent.senderId,
                senderAvatarUrl: user.avatarUrl?.toFilePath(),
                msgtype: event.messageType,
                body: text,
                timestamp: mtEvent.originServerTs,
                eventTypes: mtEvent.type,
                isCurrentUser:
                    mtEvent.senderId == _matrixClientManager.client.userID,
                metadata: mtEvent.content,
                file: file,
                height: height,
                width: width,
                mimeType: event.attachmentMimetype,
                repliedEvent: repliedEventContent,
              );

              matrixMessages.add(messageEvent);

              if (event.relationshipType == RelationshipTypes.edit) {
                final originMessage = matrixMessages.firstWhere(
                  (msg) => msg.eventId == event.relationshipEventId,
                  orElse: () => MCMessageEvent(
                    eventId: '',
                    roomId: roomId,
                    senderId: '',
                    senderDisplayName: '',
                    msgtype: '',
                    body: '',
                    timestamp: DateTime.now(),
                    isCurrentUser: false,
                    eventTypes: '',
                  ),
                );
                if (originMessage.eventId.isNotEmpty) {
                  final updatedMessage = originMessage.copyWith(
                    body: messageEvent.body,
                    isEdited: true,
                    editedTimestamp: messageEvent.timestamp,
                  );
                  final index = matrixMessages.indexOf(originMessage);
                  matrixMessages[index] = updatedMessage;
                } else {
                  matrixMessages.add(messageEvent);
                }
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
          room: room,
        ),
      );
    } else {
      return const Left(RoomFailure(message: 'Room not found'));
    }
  }

  @override
  Future<Either<MCFailure, List<MatrixRoom>>> getRooms() async {
    final roomsId = await _matrixClientManager.client.getJoinedRooms();

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
              room: room,
            );
          } else {
            return null;
          }
        })
        .whereType<MatrixRoom>()
        .toList();

    return Right(rooms);
  }

  @override
  Future<Either<MCFailure, MatrixSpace>> getSpace(String spaceId) async {
    final spaceHierachie = await _matrixClientManager.client.getSpaceHierarchy(
      spaceId,
    );
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
    try {
      final rooms = _matrixClientManager.client.rooms
          .map((room) {
            bool isVoiceRoom = false;

            final createEvent = room.getState(EventTypes.RoomCreate);

            if (createEvent != null &&
                createEvent.content.containsKey('type')) {
              final roomType = createEvent.content['type'] as String;
              // 'org.matrix.msc3417.call'
              if (roomType == 'org.matrix.msc3417.call') {
                isVoiceRoom = room.canJoinGroupCall & true;
              }
            }

            if (room.id != spaceId &&
                room.spaceParents.any((parent) => parent.roomId == spaceId)) {
              return MatrixRoom(
                roomId: room.id,
                name: room.name,
                topic: room.topic,
                type: isVoiceRoom
                    ? RoomType.voiceChannel
                    : RoomType.textChannel,
                isPublic: room.guestAccess == GuestAccess.canJoin,
                parentSpaceId: spaceId,
                avatarUrl: room.avatar?.toFilePath(),
                canHaveCall: isVoiceRoom,
                isEncrypted: room.encrypted,
                isMuted: room.isArchived,
                lastActivity: room.latestEventReceivedTime,
                lastMessage: room.lastEvent?.content['body'] as String?,
                memberCount: room.summary.mJoinedMemberCount ?? 0,
                room: room,
              );
            }
          })
          .whereType<MatrixRoom>()
          .toList();

      return Right(rooms);
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to fetch space rooms: $e'));
    }
  }

  @override
  Future<Either<MCFailure, List<MatrixSpace>>> getSpaces() async {
    try {
      final rooms = _matrixClientManager.client.rooms;
      _matrixClientManager.logger.log(Level.debug, 'All rooms: $rooms');
      final spaces = rooms
          .map((r) {
            if (r.isSpace) {
              return MatrixSpace(
                spaceId: r.id,
                name: r.name,
                description: r.topic,
                isPublic: r.isFederated,
                createdAt: DateTime.now(),
              );
            }
          })
          .whereType<MatrixSpace>()
          .toList();
      return Right(spaces);
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to fetch spaces: $e'));
    }
  }

  @override
  Stream<Either<MCFailure, Map<String, dynamic>>> getSyncStream() {
    return Stream.error(const Left(UnknownFailure(message: 'Not implemented')));
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
    return const Right(true);
  }

  @override
  Future<Either<MCFailure, bool>> joinRoom(String roomId) async {
    await _matrixClientManager.client.joinRoom(roomId);
    return const Right(true);
  }

  @override
  Future<Either<MCFailure, bool>> joinSpace(String spaceId) async {
    return const Right(true);
  }

  @override
  Future<Either<MCFailure, bool>> leaveRoom(String roomId) async {
    await _matrixClientManager.client.leaveRoom(roomId);
    return const Right(true);
  }

  @override
  Future<Either<MCFailure, bool>> leaveSpace(String spaceId) async {
    return const Right(true);
  }

  @override
  Future<Either<MCFailure, MCUser>> login({
    required String username,
    required String password,
    String? serverUrl,
  }) async {
    try {
      if (serverUrl != null && serverUrl.isNotEmpty) {
        await _matrixClientManager.client.checkHomeserver(Uri.parse(serverUrl));
      }
      final loginResponse = await _matrixClientManager.client.login(
        LoginType.mLoginPassword,
        password: password,
        identifier: AuthenticationUserIdentifier(user: username),
      );

      final user = await _matrixClientManager.client.getUserProfile(
        loginResponse.userId,
      );

      return Right(
        MCUser(
          displayName: user.displayname,
          userId: loginResponse.userId,
          avatarUrl: user.avatarUrl?.toFilePath(),
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
        ),
      );
    } catch (e) {
      return Left(AuthenticationFailure(message: 'Login failed: $e'));
    }
  }

  @override
  Future<Either<MCFailure, MCUser>> oauthLogin({
    required String token,
  }) async {
    try {
      final loginResponse = await _matrixClientManager.client.login(
        LoginType.mLoginToken,
        token: token,
        initialDeviceDisplayName: MatrixConfig.defaultClientName
      );

      final user = await _matrixClientManager.client.getUserProfile(
        loginResponse.userId,
      );

      return Right(
        MCUser(
          displayName: user.displayname,
          userId: loginResponse.userId,
          avatarUrl: user.avatarUrl?.toFilePath(),
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
        ),
      );
    } catch (e) {
      return Left(
        AuthenticationFailure(message: 'Third-party login failed: $e'),
      );
    }
  }

  @override
  Future<Either<MCFailure, bool>> logout() async {
    try {
      await _matrixClientManager.store.clear();
      await _matrixClientManager.client.logout();
      return const Right(true);
    } catch (e) {
      return Left(UnknownFailure(message: 'Logout failed: $e'));
    }
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
      return const Left(AuthenticationFailure(message: 'Registration failed'));
    }
    return const Right(true);
  }

  @override
  Future<Either<MCFailure, bool>> removeReaction({
    required String roomId,
    required String eventId,
    required String emoji,
  }) async {
    final txnId = CryptoRNG().generate().toString();
    await _matrixClientManager.client.redactEvent(roomId, eventId, txnId);
    return Future.value(const Right(true));
  }

  @override
  Future<Either<MCFailure, bool>> removeRoomFromSpace(
    String spaceId,
    String roomId,
  ) async {
    final space = _matrixClientManager.client.getRoomById(spaceId);
    final room = _matrixClientManager.client.getRoomById(roomId);
    if (space == null || room == null) {
      return const Left(RoomFailure(message: 'Space or Room not found'));
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

      return const Right(true);
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
    return const Left(UnknownFailure(message: 'Failed to search messages'));
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
          room: result,
        ),
      ]);
    }
    return const Left(UnknownFailure(message: 'Failed to search rooms'));
  }

  @override
  Future<Either<MCFailure, List<MCUser>>> searchUsers({
    required String query,
    int limit = 20,
  }) {
    return Future.value(const Left(UnknownFailure(message: 'Not implemented')));
  }

  @override
  Future<Either<MCFailure, bool>> sendFileMessage({
    required String roomId,
    required String fileUrl,
    required String fileName,
    String type = MessageTypes.File,
  }) {
    return Future.value(const Left(UnknownFailure(message: 'Not implemented')));
  }

  @override
  Future<Either<MCFailure, MCMessageEvent>> sendMessage({
    required String roomId,
    required String content,
    String msgtype = MessageTypes.Text,
    String eventType = EventTypes.Message,
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
    return Future.value(const Right(true));
  }

  @override
  Future<Either<MCFailure, bool>> setPresence(UserPresence presence) {
    return Future.value(const Right(true));
  }

  @override
  Future<Either<MCFailure, bool>> startSync() {
    return Future.value(const Right(true));
  }

  @override
  Future<Either<MCFailure, bool>> stopSync() {
    return Future.value(const Right(true));
  }

  @override
  Future<Either<MCFailure, bool>> updateUserProfile({
    String? displayName,
    String? avatarUrl,
  }) {
    return Future.value(const Right(true));
  }

  @override
  Future<Either<MCFailure, String>> uploadFile({
    required String filePath,
    required String fileName,
    String? mimeType,
  }) {
    return Future.value(const Left(UnknownFailure(message: 'Not implemented')));
  }

  @override
  Future<Either<MCFailure, bool>> verifyDevice(String userId, String deviceId) {
    return Future.value(const Right(true));
  }

  @override
  Future<Either<MCFailure, bool>> setServer(String serverUrl) async {
    try {
      await _matrixClientManager.client.checkHomeserver(Uri.parse(serverUrl));
      return const Right(true);
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to set server: $e'));
    }
  }

  @override
  Future<Either<MCFailure, MatrixRoom>> updateRoom(MatrixRoom room) async {
    final existingRoom = _matrixClientManager.client.getRoomById(room.roomId);
    if (existingRoom == null) {
      return const Left(RoomFailure(message: 'Room not found'));
    }
    try {
      if (room.name != null && room.name != existingRoom.name) {
        existingRoom.setName(room.name!);
      }
      if (room.topic != null && room.topic != existingRoom.topic) {
        existingRoom.setDescription(room.topic!);
      }

      if (room.isPublic != existingRoom.isFederated) {
        existingRoom.setGuestAccess(
          room.isPublic ? GuestAccess.canJoin : GuestAccess.forbidden,
        );
      }

      if (room.isEncrypted) {
        existingRoom.enableEncryption();
      }

      final updatedRoom = MatrixRoom(
        roomId: room.roomId,
        name: room.name ?? existingRoom.name,
        topic: room.topic ?? existingRoom.topic,
        type: room.type,
        isPublic: room.isPublic,
        parentSpaceId: room.parentSpaceId,
        room: existingRoom,
      );

      return Right(updatedRoom);
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to update room: $e'));
    }
  }

  @override
  Future<Either<MCFailure, bool>> startCall({
    required String roomId,
    required bool isVideo,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<MCFailure, bool>> endCall({required String roomId}) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<MCFailure, bool>> toggleAudio({required bool isMuted}) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<MCFailure, bool>> toggleVideo({
    required bool isCameraOn,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<MCFailure, bool>> switchCamera() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<MCFailure, List<CallParticipant>>> getCallParticipants({
    required String roomId,
  }) async {
    throw UnimplementedError();
  }
}
