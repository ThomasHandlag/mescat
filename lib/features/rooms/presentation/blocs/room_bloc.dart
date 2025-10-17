import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:mescat/core/mescat/domain/usecases/mescat_usecases.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/notifications/event_pusher.dart';

part 'room_state.dart';
part 'room_event.dart';

// Room BLoC
class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final GetRoomsUseCase getRoomsUseCase;
  final CreateRoomUseCase createRoomUseCase;
  final JoinRoomUseCase joinRoomUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final AddReactionUseCase addReactionUseCase;
  final RemoveReactionUseCase removeReactionUseCase;
  final DeleteMessageUseCase deleteMessageUseCase;
  final EditMessageUseCase editMessageUseCase;
  final ReplyMessageUseCase replyMessageUseCase;
  final EventPusher eventPusher;
  final Logger _logger = Logger();

  RoomBloc({
    required this.getRoomsUseCase,
    required this.createRoomUseCase,
    required this.joinRoomUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.addReactionUseCase,
    required this.removeReactionUseCase,
    required this.deleteMessageUseCase,
    required this.editMessageUseCase,
    required this.replyMessageUseCase,
    required this.eventPusher,
  }) : super(RoomInitial()) {
    on<LoadRooms>(_onLoadRooms);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<CreateRoom>(_onCreateRoom);
    on<JoinRoom>(_onJoinRoom);
    on<SelectRoom>(_onSelectRoom);
    on<AddReaction>(_onAddReaction);
    on<RemoveReaction>(_onRemoveReaction);
    on<DeleteMessage>(_onDeleteMessage);
    on<EditMessage>(_onEditMessage);
    on<ReplyMessage>(_onReplyMessage);
    on<SetInputAction>(_onSetInputAction);
    on<LoadMoreMessages>(_onLoadMoreMessages);
    on<ReceiveMessage>(_onReceiveMessage);
    on<MessageReacted>(_onMessageReacted);
    on<UpdateRoom>(_onUpdateRoom);
    on<SelectRoomWithCall>(_onSelectRoomWithCall);
    _eventSubscription();
  }

  void _eventSubscription() {
    eventPusher.eventStream.listen((event) {
      if (state is RoomLoaded) {
        final currentState = state as RoomLoaded;
        if (event.roomId == currentState.selectedRoomId) {
          if (event is MCMessageEvent) {
            add(ReceiveMessage(event));
          }
        } else if (event is MCReactionEvent) {
          add(MessageReacted(event: event));
        }
      }
    });
  }

  Future<void> _onSelectRoomWithCall(
    SelectRoomWithCall event,
    Emitter<RoomState> emit,
  ) async {}

  Future<void> _onUpdateRoom(UpdateRoom event, Emitter<RoomState> emit) async {
    if (state is RoomLoaded) {}
  }

  void _onReceiveMessage(ReceiveMessage event, Emitter<RoomState> emit) {
    if (state is RoomLoaded) {
      final currentState = state as RoomLoaded;
      if (event.message.roomId == currentState.selectedRoomId) {
        final updatedMessages = [...currentState.messages, event.message];
        emit(currentState.copyWith(messages: updatedMessages));
      }
    }
  }

  void _onMessageReacted(MessageReacted event, Emitter<RoomState> emit) {
    if (state is RoomLoaded) {
      final currentState = state as RoomLoaded;
      final updatedMessages = List<MCMessageEvent>.from(currentState.messages);
      final messageIndex = updatedMessages.indexWhere(
        (msg) => msg.eventId == event.event.relatedEventId,
      );
      if (messageIndex != -1) {
        final message = updatedMessages[messageIndex];
        updatedMessages[messageIndex] = message.copyWith(
          reactions: [...message.reactions, event.event],
        );

        emit(currentState.copyWith(messages: List.from(updatedMessages)));
      }
    }
  }

  Future<void> _onLoadRooms(LoadRooms event, Emitter<RoomState> emit) async {
    emit(RoomLoading());

    final result = await getRoomsUseCase(event.spaceId);

    result.fold((failure) => emit(RoomError(failure.toString())), (rooms) {
      emit(
        RoomLoaded(
          rooms: rooms,
          selectedRoomId: rooms.isNotEmpty ? rooms.first.roomId : null,
        ),
      );

      if (state is RoomLoaded) {
        final currentState = state as RoomLoaded;
        if (currentState.selectedRoomId != null) {
          add(LoadMessages(roomId: currentState.selectedRoomId!));
        }
      }
    });
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<RoomState> emit,
  ) async {
    if (state is RoomLoaded) {
      final currentState = state as RoomLoaded;
      emit(currentState.copyWith(isLoadingMessages: true));

      final result = await getMessagesUseCase(
        roomId: event.roomId,
        limit: event.limit,
      );

      result.fold(
        (failure) => emit(RoomError(failure.toString())),
        (messages) => emit(
          currentState.copyWith(messages: messages, isLoadingMessages: false),
        ),
      );
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<RoomState> emit,
  ) async {
    final result = await sendMessageUseCase(
      roomId: event.roomId,
      content: event.content,
      type: event.type,
    );

    result.fold((failure) => emit(RoomError(failure.toString())), (message) {
      if (state is RoomLoaded) {
        final currentState = state as RoomLoaded;
        final updatedMessages = [...currentState.messages, message];
        emit(currentState.copyWith(messages: updatedMessages));
      }
    });
  }

  Future<void> _onCreateRoom(CreateRoom event, Emitter<RoomState> emit) async {
    final result = await createRoomUseCase(
      name: event.name,
      topic: event.topic,
      type: event.type,
      isPublic: event.isPublic,
      parentSpaceId: event.parentSpaceId,
    );

    result.fold((failure) => emit(RoomError(failure.toString())), (room) {
      if (state is RoomLoaded) {
        final currentState = state as RoomLoaded;
        final updatedRooms = [...currentState.rooms, room];
        emit(currentState.copyWith(rooms: updatedRooms));
      }
    });
  }

  Future<void> _onJoinRoom(JoinRoom event, Emitter<RoomState> emit) async {
    final result = await joinRoomUseCase(event.roomId);

    result.fold((failure) => emit(RoomError(failure.toString())), (success) {
      if (success) {
        // Reload rooms to show the newly joined room
        add(const LoadRooms());
      }
    });
  }

  Future<void> _onSelectRoom(SelectRoom event, Emitter<RoomState> emit) async {
    if (state is RoomLoaded) {
      final currentState = state as RoomLoaded;
      emit(
        currentState.copyWith(
          selectedRoomId: event.roomId,
          messages: [], // Clear messages when switching rooms
        ),
      );
      // Load messages for the selected room
      if (event.roomId != null) {
        add(LoadMessages(roomId: event.roomId!));
      }
    }
  }

  Future<void> _onAddReaction(
    AddReaction event,
    Emitter<RoomState> emit,
  ) async {
    final result = await addReactionUseCase(
      roomId: event.roomId,
      eventId: event.eventId,
      emoji: event.emoji,
    );

    result.fold((failure) => emit(RoomError(failure.toString())), (success) {});
  }

  Future<void> _onRemoveReaction(
    RemoveReaction event,
    Emitter<RoomState> emit,
  ) async {
    final result = await removeReactionUseCase(
      roomId: event.roomId,
      eventId: event.eventId,
      emoji: event.emoji,
    );

    result.fold((failure) => emit(RoomError(failure.toString())), (success) {
      // Optionally handle success, e.g., refresh messages or update state
    });
  }

  Future<void> _onDeleteMessage(
    DeleteMessage event,
    Emitter<RoomState> emit,
  ) async {
    final result = await deleteMessageUseCase(
      roomId: event.roomId,
      eventId: event.eventId,
    );

    result.fold((failure) => emit(RoomError(failure.toString())), (success) {
      if (success && state is RoomLoaded) {
        final currentState = state as RoomLoaded;
        final updatedMessages = currentState.messages
            .where((msg) => msg.eventId != event.eventId)
            .toList();
        emit(currentState.copyWith(messages: updatedMessages));
      }
    });
  }

  Future<void> _onEditMessage(
    EditMessage event,
    Emitter<RoomState> emit,
  ) async {
    final result = await editMessageUseCase(
      roomId: event.roomId,
      eventId: event.eventId,
      newContent: event.newContent,
    );

    result.fold((failure) => emit(RoomError(failure.toString())), (
      editedMessage,
    ) {
      if (state is RoomLoaded) {
        final currentState = state as RoomLoaded;
        final updatedMessages = currentState.messages.map((msg) {
          return msg.eventId == editedMessage.eventId ? editedMessage : msg;
        }).toList();
        emit(currentState.copyWith(messages: updatedMessages));
      }
    });
  }

  Future<void> _onReplyMessage(
    ReplyMessage event,
    Emitter<RoomState> emit,
  ) async {
    final result = await replyMessageUseCase(
      roomId: event.roomId,
      content: event.content,
      replyToEventId: event.replyToEventId,
    );

    result.fold((failure) => emit(RoomError(failure.toString())), (message) {
      if (state is RoomLoaded) {
        final currentState = state as RoomLoaded;
        final updatedMessages = [...currentState.messages, message];
        emit(currentState.copyWith(messages: updatedMessages));
      }
    });
  }

  Future<void> _onSetInputAction(
    SetInputAction event,
    Emitter<RoomState> emit,
  ) async {
    if (state is RoomLoaded) {
      final currentState = state as RoomLoaded;
      final updatedInputAction = InputActionData(
        action: event.action,
        targetEventId: event.targetEventId,
        initialContent: event.initialContent,
      );
      emit(currentState.copyWith(inputAction: updatedInputAction));
    }
  }

  Future<void> _onLoadMoreMessages(
    LoadMoreMessages event,
    Emitter<RoomState> emit,
  ) async {
    if (state is RoomLoaded) {
      final currentState = state as RoomLoaded;
      if (currentState.selectedRoomId == null) return;

      emit(currentState.copyWith(isLoadingMore: true));

      final result = await getMessagesUseCase(
        roomId: currentState.selectedRoomId!,
        limit: event.limit,
        fromToken: MCEvent.endToken,
      );

      result.fold((failure) => emit(RoomError(failure.toString())), (
        newMessages,
      ) {
        // Prepend new messages to the existing list
        final updatedMessages = [...newMessages, ...currentState.messages];
        emit(
          currentState.copyWith(
            messages: updatedMessages,
            isLoadingMore: false,
          ),
        );
      });
    }
  }
}
