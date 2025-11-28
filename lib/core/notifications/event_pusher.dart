import 'dart:async';

import 'package:logger/logger.dart';
import 'package:matrix/matrix.dart' hide Level;

import 'package:mescat/core/constants/matrix_constants.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/core/mescat/matrix_client.dart';
import 'package:mescat/features/notifications/data/notification_service.dart';

final class EventPusher {
  final MatrixClientManager clientManager;
  final NotificationService notificationService;
  final Logger logger = Logger();

  EventPusher({
    required this.clientManager,
    required this.notificationService,
  }) {
    registNotificationListener();

    clientManager.client.onTimelineEvent.stream.listen((event) async {
      final user = await clientManager.client.getUserProfile(event.senderId);

      if (event.type == EventTypes.Message) {
        final messageType = event.content['msgtype'] as String?;

        if (messageType == null) {
          return;
        }

        RepliedEventContent? repliedEventContent;
        if (event.inReplyToEventId() != null) {
          final repliedMxEvent = await clientManager.client.getOneRoomEvent(
            event.room.id,
            event.inReplyToEventId()!,
          );
          final repliedEvent = Event.fromMatrixEvent(
            repliedMxEvent,
            event.room,
          );
          if (repliedEvent.messageType == MessageTypes.Text) {
            final repliedUser = await event.fetchSenderUser();
            if (repliedUser == null) {
              logger.log(
                Level.warning,
                "Failed to fetch replied user for event: $repliedEvent",
              );
              return;
            }
            repliedEventContent = RepliedEventContent(
              content: repliedEvent.body,
              eventId: repliedEvent.eventId,
              senderName: repliedUser.displayName ?? repliedEvent.senderId,
            );
          }
        }

        final text = event.content['body'] as String;

        _controller.add(
          MCMessageEvent(
            roomId: event.room.id,
            senderId: event.senderId,
            senderDisplayName: user.displayname,
            timestamp: event.originServerTs,
            eventId: event.eventId,
            body: text,
            eventTypes: event.type,
            isCurrentUser: clientManager.currentUserId == event.senderId,
            msgtype: messageType,
            senderAvatarUrl: user.avatarUrl,
            repliedEvent: repliedEventContent,
            event: event,
          ),
        );
      } else if (event.type == EventTypes.Reaction) {
        final reactionContent =
            event.content['m.relates_to'] as Map<String, dynamic>?;
        if (reactionContent != null) {
          final reactedEventId = reactionContent['event_id'] as String?;
          final reactionKey = reactionContent['key'] as String?;

          if (reactedEventId != null && reactionKey != null) {
            _controller.add(
              MCReactionEvent(
                roomId: event.room.id,
                senderId: event.senderId,
                senderDisplayNames: [user.displayname],
                timestamp: event.originServerTs,
                eventId: event.eventId,
                relatedEventId: reactedEventId,
                key: reactionKey,
                eventTypes: event.type,
                isCurrentUser: clientManager.currentUserId == event.senderId,
                reactEventIds: [MapEntry(event.eventId, event.senderId)],
              ),
            );
          } else {
            logger.log(
              Level.warning,
              "Invalid reaction event content: $reactionContent",
            );
          }
        } else {
          logger.log(
            Level.warning,
            "Missing reaction content in event: $event",
          );
        }
      } else if (event.type == MatrixEventTypes.msc3417) {
        logger.log(
          Level.debug,
          'Received MSC3401 event: ${event.content.toString()}',
        );
      } else if (event.type == EventTypes.GroupCallMemberInvite) {
        logger.log(
          Level.debug,
          'Received GroupCallMemberCandidates event: ${event.content.toString()}',
        );
      } else if (event.type == EventTypes.GroupCallMemberAnswer) {
        logger.log(
          Level.debug,
          'Received GroupCallMemberCandidates event: ${event.content.toString()}',
        );
      } else if (event.type == EventTypes.GroupCallMemberHangup) {
        logger.log(
          Level.debug,
          'Received GroupCallMemberCandidates event: ${event.content.toString()}',
        );
      } else if (event.type == EventTypes.GroupCallMemberNegotiate) {
        logger.log(
          Level.debug,
          'Received GroupCallMemberCandidates event: ${event.content.toString()}',
        );
      } else if (event.type == EventTypes.GroupCallMemberCandidates) {
        logger.log(
          Level.debug,
          'Received GroupCallMemberCandidates event: ${event.content.toString()}',
        );
      } else if (event.type == EventTypes.RoomMember) {
        _controller.add(
          McRoomEvent(
            eventId: event.eventId,
            roomId: event.room.id,
            senderId: event.senderId,
            timestamp: event.originServerTs,
            eventTypes: event.type,
          ),
        );
      } else if (event.type == EventTypes.Redaction) {
        logger.log(Level.debug, 'Received Redaction event: ${event.toJson()}');
        /*
        {content: {
        redacts: $m5voHeo7Ks0iqfgUHpDOWk3Fq9kvxW0ISRXoVtt1EZg},
         type: m.room.redaction, 
         event_id: $KSQ8yxZTjayoEtpqX_DKkgevYdaGDPY3Bo82i2B1Le8, 
         room_id: !EHQGTIEVCzRGmUkFIq:matrix.org, 
         sender: @thuongtv21:matrix.org, 
         origin_server_ts: 1764318773214, 
         unsigned: {membership: join, age: 722}, 
         redacts: $m5voHeo7Ks0iqfgUHpDOWk3Fq9kvxW0ISRXoVtt1EZg, status: 1}
      */
      } else {
        logger.log(Level.debug, "Unhandled event type: ${event.type}");
      }
    });
  }

  final StreamController<MCEvent> _controller =
      StreamController<MCEvent>.broadcast();

  Stream<MCEvent> get eventStream => _controller.stream;

  void registNotificationListener() async {
    clientManager.client.onNotification.stream.listen((event) async {
      final roomId = event.room.id;
      final roomName = event.room.name;
      if (event.type == EventTypes.CallInvite) {
        final inviterName = event.senderId;

        notificationService.showInviteNotification(
          roomId: roomId,
          roomName: roomName,
          inviterName: inviterName,
        );
      } else if (event.type == EventTypes.Message) {
        final roomId = event.room.id;
        final senderName = event.senderId;
        final messageContent = event.content['body'] as String? ?? '';
        notificationService.showMessageNotification(
          roomId: roomId,
          roomName: roomName,
          senderName: senderName,
          message: messageContent,
          eventId: event.eventId,
        );
      } else if (event.type == EventTypes.GroupCallMemberInvite) {
        final roomId = event.room.id;
        final inviterName = event.senderId;
        notificationService.showInviteNotification(
          roomId: roomId,
          roomName: roomName,
          inviterName: inviterName,
        );
      } else if (event.type == EventTypes.RoomMember) {
        final roomId = event.room.id;
        final inviterName = event.senderId;
        notificationService.showInviteNotification(
          roomId: roomId,
          roomName: roomName,
          inviterName: inviterName,
        );
      }
    });
  }
}
