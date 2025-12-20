import 'dart:convert';
import 'dart:developer';
import 'dart:math' show min;
import 'dart:typed_data';
import 'dart:ui';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/contracts/abi/mescat.g.dart';
import 'package:mescat/contracts/contracts.dart';
import 'package:mescat/core/constants/matrix_constants.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:uuid/rng.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

final Logger logger = Logger(printer: PrettyPrinter(noBoxingByDefault: true));

extension UrlExtensions on String {
  bool get isValidYoutubeUrl {
    final youtubeRegex = RegExp(
      r'^(https?\:\/\/)?(www\.youtube\.com|youtu\.?be)\/.+$',
      caseSensitive: false,
      multiLine: false,
    );
    return youtubeRegex.hasMatch(this);
  }

  bool get isValidUrl {
    final urlRegex = RegExp(
      r'^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$',
      caseSensitive: false,
      multiLine: false,
    );
    return urlRegex.hasMatch(this);
  }
}

extension ClientDownloadContentExtension on Client {
  Future<Uint8List> downloadMxcCached(
    Uri mxc, {
    num? width,
    num? height,
    bool isThumbnail = false,
    bool? animated,
    ThumbnailMethod? thumbnailMethod,
    bool rounded = false,
  }) async {
    // To stay compatible with previous storeKeys:
    final cacheKey = isThumbnail
        // ignore: deprecated_member_use
        ? mxc.getThumbnail(
            this,
            width: width,
            height: height,
            animated: animated,
            method: thumbnailMethod!,
          )
        : mxc;

    final cachedData = await database.getFile(cacheKey);
    if (cachedData != null) return cachedData;

    final httpUri = isThumbnail
        ? await mxc.getThumbnailUri(
            this,
            width: width,
            height: height,
            animated: animated,
            method: thumbnailMethod,
          )
        : await mxc.getDownloadUri(this);

    log('Downloading Mxc from $httpUri, mxc: $mxc as thumbnail: $isThumbnail');

    log('Is scheme: ${mxc.isScheme('mxc')}');

    log('Homeserver: ${homeserver.toString()}');

    final response = await http.get(
      Uri.parse('https:$httpUri'),
      headers: accessToken == null
          ? null
          : {'authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode != 200) {
      throw Exception();
    }
    var imageData = response.bodyBytes;

    if (rounded) {
      imageData = await _convertToCircularImage(
        imageData,
        min(width ?? 64, height ?? 64).round(),
      );
    }

    await database.storeFile(cacheKey, imageData, 0);

    return imageData;
  }
}

Future<Uint8List> _convertToCircularImage(
  Uint8List imageBytes,
  int size,
) async {
  final codec = await instantiateImageCodec(imageBytes);
  final frame = await codec.getNextFrame();
  final originalImage = frame.image;

  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);

  final paint = Paint();
  final rect = Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());

  final clipPath = Path()
    ..addOval(
      Rect.fromCircle(center: Offset(size / 2, size / 2), radius: size / 2),
    );

  canvas.clipPath(clipPath);

  canvas.drawImageRect(
    originalImage,
    Rect.fromLTWH(
      0,
      0,
      originalImage.width.toDouble(),
      originalImage.height.toDouble(),
    ),
    rect,
    paint,
  );

  final picture = recorder.endRecording();
  final circularImage = await picture.toImage(size, size);

  final byteData = await circularImage.toByteData(format: ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

extension StringToColor on String {
  Color generateFromString() {
    final hash = codeUnits.fold(0, (prev, elem) => prev + elem);
    final r = (hash * 123) % 256;
    final g = (hash * 456) % 256;
    final b = (hash * 789) % 256;
    return Color.fromARGB(255, r, g, b);
  }
}

extension ColorExt on Color {
  Color getContrastingTextColor() {
    final brightness =
        (r * 299 + g * 587 + b * 114) / 1000; // Perceived brightness
    return brightness > 128 ? Colors.black : Colors.white;
  }
}

extension RoomExt on Room {
  RoomType getRoomType() {
    bool isVoiceRoom = false;
    final createEvent = getState(EventTypes.RoomCreate);
    if (createEvent != null && createEvent.content.containsKey('type')) {
      final roomType = createEvent.content['type'] as String;
      // 'org.matrix.msc3417.call'
      if (roomType == MatrixEventTypes.msc3417) {
        isVoiceRoom = canJoinGroupCall & true;
      }
    }
    return isVoiceRoom ? RoomType.voiceChannel : RoomType.textChannel;
  }
}

extension EventListExt on List<Event> {
  Event? firstWhereOrNull(bool Function(Event) test) {
    for (var event in this) {
      if (test(event)) {
        return event;
      }
    }
    return null;
  }
}

extension ClientExt on Client {
  Future<Either<MCFailure, Map<String, dynamic>>> getMessages(
    String roomId, {
    int limit = 150,
    String? fromToken,
    String? filter,
    String? toToken,
  }) async {
    try {
      final eventsResponse = await getRoomEvents(
        roomId,
        Direction.b,
        limit: limit,
        filter: filter,
        from: fromToken,
        to: toToken,
      );

      final mtEvents = eventsResponse.chunk;
      final nextToken = eventsResponse.end;
      final List<MCMessageEvent> matrixMessages = [];

      final room = getRoomById(roomId);

      for (final mtEvent in mtEvents.reversed) {
        switch (mtEvent.type) {
          case EventTypes.Message:
            {
              if (room == null) continue;

              final event = Event.fromMatrixEvent(mtEvent, room);
              final user = await getUserProfile(mtEvent.senderId);

              if (event.redacted) {
                final client = Web3Client(MescatContracts.url, http.Client());
                final address = EthereumAddress.fromHex(MescatContracts.mescat);
                final mescat = Mescat(address: address, client: client);

                try {
                  final ssse = await mescat.getSSSS((eid: event.eventId));
                  if (ssse.eventId.isEmpty) continue;
                  // roomlogger.d(
                  //   'fetched from blockchain: ${ssse.cid} id: ${ssse.content} hasCid: ${ssse.eventId} ${ssse.toString()}',
                  // );
                  final ssEvent = Event.fromJson(
                    jsonDecode(ssse.content),
                    room,
                  );
                  final user = await getUserProfile(ssEvent.senderId);

                  if (ssse.hasCid && ssse.cid.isNotEmpty) {
                    // if hasCid
                    matrixMessages.add(
                      MCMessageEvent(
                        eventId: ssEvent.eventId,
                        roomId: roomId,
                        senderId: ssEvent.senderId,
                        senderDisplayName: user.displayname ?? ssEvent.senderId,
                        msgtype: ssEvent.messageType,
                        body: ssEvent.body.isEmpty
                            ? 'This message was redacted'
                            : ssEvent.body, // content
                        timestamp: ssEvent.originServerTs,
                        eventTypes: ssEvent.type,
                        isCurrentUser: ssEvent.senderId == userID,
                        event: ssEvent,
                        cid: ssse.cid, // cid
                      ),
                    );
                  } else {
                    matrixMessages.add(
                      MCMessageEvent(
                        eventId: ssEvent.eventId,
                        roomId: roomId,
                        senderId: ssEvent.senderId,
                        senderDisplayName: user.displayname ?? ssEvent.senderId,
                        msgtype: ssEvent.messageType,
                        body: ssEvent.body.isEmpty
                            ? 'This message was redacted'
                            : ssEvent.body, // content
                        timestamp: ssEvent.originServerTs,
                        eventTypes: ssEvent.type,
                        isCurrentUser: ssEvent.senderId == userID,
                        event: ssEvent,
                      ),
                    );
                  }
                } catch (e) {
                  logger.e('Error decoding redacted event from blockchain: $e');
                  continue;
                }
              }

              RepliedEventContent? repliedEventContent;
              final text =
                  event.content['body'] as String? ?? 'encrypted message';

              if (event.inReplyToEventId() != null) {
                final repliedMTEvent = await getOneRoomEvent(
                  roomId,
                  event.inReplyToEventId()!,
                );

                final repliedEvent = Event.fromMatrixEvent(
                  repliedMTEvent,
                  room,
                );
                final repliedEventMsgtype =
                    repliedMTEvent.content['msgtype'] as String? ??
                    MessageTypes.Text;

                final senderName = (await getUserProfile(
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
                senderAvatarUrl: user.avatarUrl,
                msgtype: event.messageType,
                body: text,
                timestamp: mtEvent.originServerTs,
                eventTypes: mtEvent.type,
                isCurrentUser: mtEvent.senderId == userID,
                repliedEvent: repliedEventContent,
                event: event,
              );

              matrixMessages.add(messageEvent);

              if (event.relationshipType == RelationshipTypes.edit) {
                final oIndex = matrixMessages.indexWhere(
                  (msg) => msg.eventId == event.relationshipEventId,
                );

                if (oIndex == -1) continue;

                final originMessage = matrixMessages[oIndex];

                if (originMessage.eventId.isNotEmpty) {
                  final updatedMessage = originMessage.copyWith(
                    body: messageEvent.body,
                    isEdited: true,
                    editedTimestamp: messageEvent.timestamp,
                  );
                  final index = matrixMessages.indexOf(originMessage);
                  matrixMessages[index] = updatedMessage;
                }
              }
            }
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

              if (index != -1 && key != null && reactedEventId != null) {
                final existingReaction = matrixMessages[index].reactions
                    .firstWhere(
                      (react) =>
                          react.key == key &&
                          react.relatedEventId == reactedEventId,
                      orElse: () => MCReactionEvent(
                        key: '',
                        relatedEventId: '',
                        reactEventIds: const [],
                        eventId: '',
                        roomId: '',
                        senderId: '',
                        timestamp: DateTime.now(),
                        eventTypes: '',
                        senderDisplayNames: const [],
                        isCurrentUser: false,
                      ),
                    );

                final room = getRoomById(roomId);
                if (room == null) continue;
                final event = Event.fromMatrixEvent(mtEvent, room);
                final senderName = (await getUserProfile(
                  event.senderId,
                )).displayname;

                if (existingReaction.key.isEmpty) {
                  // New reaction
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
                    senderDisplayNames: [senderName],
                    isCurrentUser: mtEvent.senderId == userID,
                  );

                  final msg = matrixMessages[index];
                  final reactions = List<MCReactionEvent>.from(msg.reactions)
                    ..add(reactEvent);
                  matrixMessages[index] = msg.copyWith(reactions: reactions);
                } else {
                  // Add to existing reaction
                  final msg = matrixMessages[index];
                  final reactions = List<MCReactionEvent>.from(msg.reactions);
                  final reactIndex = reactions.indexOf(existingReaction);

                  reactions[reactIndex] = existingReaction.copyWith(
                    senderDisplayNames: [
                      ...existingReaction.senderDisplayNames,
                      senderName,
                    ],
                    reactEventIds: [
                      ...existingReaction.reactEventIds,
                      MapEntry(mtEvent.eventId, mtEvent.senderId),
                    ],
                    isCurrentUser: mtEvent.senderId == userID,
                  );
                  matrixMessages[index] = msg.copyWith(reactions: reactions);
                }
              }
            }
            break;
          case EventTypes.RoomMember:
          case EventTypes.RoomName:
          case EventTypes.RoomTopic:
          case EventTypes.RoomAvatar:
          case EventTypes.SpaceChild:
          case EventTypes.SpaceParent:
          case EventTypes.Encrypted:
          default:
            break;
        }
      }
      return Right({'messages': matrixMessages, 'nextToken': nextToken});
    } catch (e, stackTrace) {
      logger.e('Error getting messages: $e', error: e, stackTrace: stackTrace);
      return Left(UnknownFailure(message: 'Failed to get messages: $e'));
    }
  }

  Future<Either<MCFailure, MCMessageEvent>> sendCustomMessage({
    required String roomId,
    required String content,
    String msgtype = MessageTypes.Text,
    String eventType = EventTypes.Message,
    bool viaToken = false,
    String? privKey,
  }) async {
    try {
      final transactionId = CryptoRNG().generate().toString();
      final result = await sendMessage(
        roomId,
        eventType,
        transactionId,
        Map.from({'body': content, 'msgtype': msgtype}),
      );

      final mEvent = await getOneRoomEvent(roomId, result);

      final event = Event.fromMatrixEvent(mEvent, getRoomById(roomId)!);

      if (viaToken) {
        final httpClient = http.Client();
        final web3Client = Web3Client(MescatContracts.url, httpClient);

        final credential = EthPrivateKey.fromHex(privKey!);

        final mescat = Mescat(
          address: EthereumAddress.fromHex(MescatContracts.mescat),
          client: web3Client,
        );

        mescat.setSSSS((
          cid: '',
          content: jsonEncode(event.toJson()),
          eid: event.eventId,
          hasCid: false,
        ), credentials: credential);
      }

      final user = await getUserProfile(userID!);

      return Right(
        MCMessageEvent(
          eventTypes: eventType,
          eventId: result,
          roomId: roomId,
          senderId: userID ?? 'unknown',
          msgtype: msgtype,
          body: content,
          senderDisplayName: user.displayname,
          timestamp: DateTime.now(),
          isCurrentUser: true,
          event: event,
        ),
      );
    } catch (e) {
      logger.e('Error sending message: $e');
      return Left(UnknownFailure(message: 'Failed to send message: $e'));
    }
  }

  Future<Either<MCFailure, MCMessageEvent>> replyMessage({
    required String roomId,
    required String content,
    required String replyToEventId,
    String msgtype = MessageTypes.Text,
    bool viaToken = false,
    String? privKey,
  }) async {
    // Construct the reply content according to Matrix spec
    try {
      final replyContent = {
        'msgtype': msgtype,
        'body': content,
        'm.relates_to': {
          'm.in_reply_to': {'event_id': replyToEventId},
        },
      };
      final txnId = CryptoRNG().generate().toString();

      final nEvenId = await sendMessage(
        roomId,
        EventTypes.Message,
        txnId,
        replyContent,
      );

      final event = Event.fromMatrixEvent(
        await getOneRoomEvent(roomId, nEvenId),
        getRoomById(roomId)!,
      );

      if (viaToken) {
        final httpClient = http.Client();
        final web3Client = Web3Client(MescatContracts.url, httpClient);

        final credential = EthPrivateKey.fromHex(privKey!);

        final mescat = Mescat(
          address: EthereumAddress.fromHex(MescatContracts.mescat),
          client: web3Client,
        );

        mescat.setSSSS((
          cid: '',
          content: jsonEncode(event.toJson()),
          eid: event.eventId,
          hasCid: false,
        ), credentials: credential);
      }

      final user = await getUserProfile(userID!);

      return Right(
        MCMessageEvent(
          eventTypes: EventTypes.Message,
          eventId: nEvenId,
          roomId: roomId,
          senderId: userID ?? 'unknown',
          msgtype: msgtype,
          body: content,
          senderDisplayName: user.displayname,
          timestamp: DateTime.now(),
          isCurrentUser: true,
          event: event,
        ),
      );
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to reply to message: $e'));
    }
  }

  Future<Either<MCFailure, MCMessageEvent>> editMessageContent({
    required String roomId,
    required String eventId,
    required String newContent,
  }) async {
    try {
      final editContent = {
        'msgtype': MessageTypes.Text,
        'body': newContent,
        'm.new_content': {'msgtype': MessageTypes.Text, 'body': newContent},
        'm.relates_to': {'rel_type': 'm.replace', 'event_id': eventId},
      };
      final txnId = CryptoRNG().generate().toString();

      final nEvenId = await sendMessage(
        roomId,
        EventTypes.Message,
        txnId,
        editContent,
      );

      final mEvent = await getOneRoomEvent(roomId, nEvenId);

      final event = Event.fromMatrixEvent(mEvent, getRoomById(roomId)!);

      final user = await getUserProfile(userID!);

      return Right(
        MCMessageEvent(
          eventTypes: EventTypes.Message,
          eventId: nEvenId,
          roomId: roomId,
          senderId: userID ?? 'unknown',
          msgtype: MessageTypes.Text,
          body: newContent,
          senderDisplayName: user.displayname,
          timestamp: DateTime.now(),
          isCurrentUser: true,
          event: event,
        ),
      );
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to edit message: $e'));
    }
  }

  Future<Either<MCFailure, bool>> addReaction({
    required String roomId,
    required String eventId,
    required String emoji,
  }) async {
    try {
      await sendMessage(
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

  Future<Either<MCFailure, bool>> removeReaction({
    required String roomId,
    required String eventId,
    required String emoji,
  }) async {
    final txnId = CryptoRNG().generate().toString();
    await redactEvent(roomId, eventId, txnId);
    return Future.value(const Right(true));
  }

  Future<Either<MCFailure, bool>> removeRoomFromSpace(
    String spaceId,
    String roomId,
  ) async {
    final space = getRoomById(spaceId);
    final room = getRoomById(roomId);
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

  Future<Either<MCFailure, bool>> deleteMessage({
    required String roomId,
    required String eventId,
  }) async {
    final txnId = CryptoRNG().generate().toString();
    await redactEvent(roomId, eventId, txnId);
    return const Right(true);
  }

  Future<Either<MCFailure, MCMessageEvent>> editMessage({
    required String roomId,
    required String eventId,
    required String newContent,
  }) async {
    try {
      final result = await sendMessage(
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

      final mEvent = await getOneRoomEvent(roomId, result);

      final event = Event.fromMatrixEvent(mEvent, getRoomById(roomId)!);

      final user = await getUserProfile(userID!);

      return Right(
        MCMessageEvent(
          eventTypes: EventTypes.Message,
          eventId: result,
          roomId: roomId,
          senderId: userID ?? 'unknown',
          msgtype: MessageTypes.Text,
          body: newContent,
          senderDisplayName: user.displayname,
          timestamp: DateTime.now(),
          isCurrentUser: true,
          event: event,
        ),
      );
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to edit message: $e'));
    }
  }
}
