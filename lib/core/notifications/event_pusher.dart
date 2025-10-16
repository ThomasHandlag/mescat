import 'dart:async';

import 'package:logger/logger.dart';
import 'package:matrix/matrix.dart' hide Level;
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/core/mescat/matrix_client.dart';
import 'package:mescat/features/rooms/presentation/blocs/room_bloc.dart';
import 'package:mescat/features/spaces/presentation/blocs/space_bloc.dart';

final class EventPusher {
  final MatrixClientManager clientManager;
  // final SpaceBloc spaceBloc;
  // final RoomBloc roomBloc;

  final Logger _logger = Logger();

  EventPusher({
    required this.clientManager,
    // required this.spaceBloc,
    // required this.roomBloc,
  }) {
    _logger.log(Level.info, "EventPusher initializing...");
    clientManager.client.onTimelineEvent.stream.listen((event) async {
      _logger.log(Level.debug, "New timeline event: ${event.type} ${event.content}");
      final user = await clientManager.client.getUserProfile(event.senderId);

      if (event.type == EventTypes.Message) {
        final messageType = event.content['msgtype'] as String;

        RepliedEventContent? repliedEventContent;
        if (event.relationshipType == RelationshipTypes.reply) {
          final repliedMxEvent = await clientManager.client.getOneRoomEvent(
            event.room.id,
            event.eventId,
          );
          final repliedEvent = Event.fromMatrixEvent(
            repliedMxEvent,
            event.room,
          );
          if (repliedEvent.messageType == MessageTypes.Text) {
            repliedEventContent = RepliedEventContent(
              content: repliedEvent.body,
              eventId: repliedEvent.eventId,
              senderName: // TODO: check exceptions here
                  repliedEvent.asUser.displayName ?? repliedEvent.senderId,
            );
          }
        }

        final text = event.content['body'] as String;
        final imageInfo = event.content['info'] as Map<String, dynamic>?;
        final width = imageInfo != null ? imageInfo['w'] : null;
        final height = imageInfo != null ? imageInfo['h'] : null;
        MatrixFile? mtFile;

        if (event.hasAttachment) {
          mtFile = await event.downloadAndDecryptAttachment();
        }

        _controller.add(
          MCMessageEvent(
            roomId: event.room.id,
            senderId: event.senderId,
            senderDisplayName: user.displayname,
            width: width,
            height: height,
            timestamp: event.originServerTs,
            eventId: event.eventId,
            file: mtFile,
            body: text,
            eventTypes: event.type,
            isCurrentUser: clientManager.currentUserId == event.senderId,
            msgtype: messageType,
            mimeType: event.attachmentMimetype,
            senderAvatarUrl: user.avatarUrl?.toFilePath(),
            repliedEvent: repliedEventContent,
          ),
        );
      } else if (event.type == EventTypes.Reaction) {
        _logger.log(Level.debug, "Reaction event: $event");
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
            _logger.log(
              Level.warning,
              "Invalid reaction event content: $reactionContent",
            );
          }
        } else {
          _logger.log(
            Level.warning,
            "Missing reaction content in event: $event",
          );
        }
      } else {
        _logger.log(Level.debug, "Unhandled event type: ${event.type}");
      }
    });
  }

  final StreamController<MCEvent> _controller =
      StreamController<MCEvent>.broadcast();

  Stream<MCEvent> get eventStream => _controller.stream;
}
