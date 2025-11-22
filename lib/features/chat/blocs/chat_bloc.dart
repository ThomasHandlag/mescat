import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/core/mescat/domain/usecases/mescat_usecases.dart';
import 'package:mescat/core/notifications/event_pusher.dart';
import 'package:matrix/matrix.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final AddReactionUseCase addReactionUseCase;
  final RemoveReactionUseCase removeReactionUseCase;
  final DeleteMessageUseCase deleteMessageUseCase;
  final EditMessageUseCase editMessageUseCase;
  final ReplyMessageUseCase replyMessageUseCase;
  final GetRoomUsecase getRoomUseCase;
  final EventPusher eventPusher;

  ChatBloc({
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.addReactionUseCase,
    required this.removeReactionUseCase,
    required this.deleteMessageUseCase,
    required this.editMessageUseCase,
    required this.replyMessageUseCase,
    required this.getRoomUseCase,
    required this.eventPusher,
  }) : super(const ChatInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<AddReaction>(_onAddReaction);
    on<RemoveReaction>(_onRemoveReaction);
    on<DeleteMessage>(_onDeleteMessage);
    on<EditMessage>(_onEditMessage);
    on<ReplyMessage>(_onReplyMessage);
    on<SetInputAction>(_onSetInputAction);
    on<LoadMoreMessages>(_onLoadMoreMessages);
    on<ReceiveMessage>(_onReceiveMessage);
    on<MessageReacted>(_onMessageReacted);
    on<SelectRoom>(_onSelectRoom);
    _eventSubscription();
  }

  void _eventSubscription() {
    eventPusher.eventStream.listen((event) {
      if (state is! ChatLoaded) return;

      final currentState = state as ChatLoaded;
      if (event.roomId != currentState.selectedRoomId) return;

      if (event is MCMessageEvent) {
        add(ReceiveMessage(event));
      } else if (event is MCReactionEvent) {
        add(MessageReacted(event: event));
      }
    });
  }

  void _onReceiveMessage(ReceiveMessage event, Emitter<ChatState> emit) {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    if (event.message.roomId != currentState.selectedRoomId) return;

    emit(
      currentState.copyWith(
        messages: [...currentState.messages, event.message],
      ),
    );
  }

  void _onMessageReacted(MessageReacted event, Emitter<ChatState> emit) {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    final messageIndex = currentState.messages.indexWhere(
      (msg) => msg.eventId == event.event.relatedEventId,
    );

    if (messageIndex == -1) return;

    final updatedMessages = List<MCMessageEvent>.from(currentState.messages);
    final message = updatedMessages[messageIndex];
    updatedMessages[messageIndex] = message.copyWith(
      reactions: [...message.reactions, event.event],
    );

    emit(currentState.copyWith(messages: updatedMessages));
  }

  Future<void> _onSelectRoom(SelectRoom event, Emitter<ChatState> emit) async {
    if (event.roomId == '0') {
      emit(const ChatInitial());
      return;
    }

    final roomResult = await getRoomUseCase(event.roomId);

    roomResult.fold(
      (failure) {
        emit(ChatError(message: failure.toString()));
      },
      (room) {
        emit(ChatLoading(selectedRoom: room));
        add(LoadMessages(roomId: event.roomId));
      },
    );
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    final result = await getMessagesUseCase(
      roomId: event.roomId,
      limit: event.limit,
    );

    result.fold((failure) => emit(ChatError(message: failure.toString())), (
      data,
    ) {
      if (state is ChatLoaded) return;

      final messages = data['messages'] as List<MCMessageEvent>;
      final nextToken = data['nextToken'] as String?;

      emit(
        ChatLoaded(
          selectedRoomId: event.roomId,
          messages: messages,
          inputAction: const InputActionData(action: InputAction.none),
          nextToken: nextToken,
          selectedRoom: state.selectedRoom,
        ),
      );
    });
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final result = await sendMessageUseCase(
      roomId: event.roomId,
      content: event.content,
      type: event.type,
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.toString())),
      (_) {}, // Message will be received via event stream
    );
  }

  Future<void> _onAddReaction(
    AddReaction event,
    Emitter<ChatState> emit,
  ) async {
    final result = await addReactionUseCase(
      roomId: event.roomId,
      eventId: event.eventId,
      emoji: event.emoji,
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.toString())),
      (success) {},
    );
  }

  Future<void> _onRemoveReaction(
    RemoveReaction event,
    Emitter<ChatState> emit,
  ) async {
    final result = await removeReactionUseCase(
      roomId: event.roomId,
      eventId: event.eventId,
      emoji: event.emoji,
    );

    result.fold((failure) => emit(ChatError(message: failure.toString())), (
      success,
    ) {
      if (state is! ChatLoaded && !success) return;

      final currentState = state as ChatLoaded;
      final messageIndex = currentState.messages.indexWhere(
        (msg) => msg.eventId == event.eventId,
      );
      if (messageIndex == -1) return;

      final updatedMessages = List<MCMessageEvent>.from(currentState.messages);
      final message = updatedMessages[messageIndex];
      final reactEvents = List<MCReactionEvent>.from(message.reactions);

      final reactEventIndex = reactEvents.indexWhere(
        (react) => react.key == event.emoji,
      );

      if (reactEventIndex == -1) return;

      final reactEvent = reactEvents[reactEventIndex];

      reactEvents[reactEventIndex] = reactEvent.copyWith(
        reactEventIds: reactEvent.reactEventIds
            .where((id) => id.key != event.reactEventId)
            .toList(),
      );

      log(
        'Updated reactEventIds: ${reactEvents[reactEventIndex].reactEventIds.map((e) => e.key).toList()}',
      );

      updatedMessages[messageIndex] = message.copyWith(reactions: reactEvents);

      emit(currentState.copyWith(messages: updatedMessages));
    });
  }

  Future<void> _onDeleteMessage(
    DeleteMessage event,
    Emitter<ChatState> emit,
  ) async {
    final result = await deleteMessageUseCase(
      roomId: event.roomId,
      eventId: event.eventId,
    );

    result.fold((failure) => emit(ChatError(message: failure.toString())), (
      success,
    ) {
      if (!success || state is! ChatLoaded) return;

      final currentState = state as ChatLoaded;
      final updatedMessages = currentState.messages
          .where((msg) => msg.eventId != event.eventId)
          .toList();
      emit(currentState.copyWith(messages: updatedMessages));
    });
  }

  Future<void> _onEditMessage(
    EditMessage event,
    Emitter<ChatState> emit,
  ) async {
    final result = await editMessageUseCase(
      roomId: event.roomId,
      eventId: event.eventId,
      newContent: event.newContent,
    );

    result.fold((failure) => emit(ChatError(message: failure.toString())), (
      editedMessage,
    ) {
      if (state is! ChatLoaded) return;

      final currentState = state as ChatLoaded;
      final updatedMessages = currentState.messages.map((msg) {
        return msg.eventId == editedMessage.eventId ? editedMessage : msg;
      }).toList();
      emit(currentState.copyWith(messages: updatedMessages));
    });
  }

  Future<void> _onReplyMessage(
    ReplyMessage event,
    Emitter<ChatState> emit,
  ) async {
    final result = await replyMessageUseCase(
      roomId: event.roomId,
      content: event.content,
      replyToEventId: event.replyToEventId,
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.toString())),
      (_) {}, // Message will be received via event stream
    );
  }

  void _onSetInputAction(SetInputAction event, Emitter<ChatState> emit) {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    emit(
      currentState.copyWith(
        inputAction: InputActionData(
          action: event.action,
          targetEventId: event.targetEventId,
          initialContent: event.initialContent,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreMessages(
    LoadMoreMessages event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;

    // Check if we can load more
    if (currentState.selectedRoomId == null ||
        currentState.isLoadingMore ||
        currentState.nextToken == null) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await getMessagesUseCase(
      roomId: currentState.selectedRoomId!,
      limit: event.limit,
      fromToken: currentState.nextToken,
    );

    result.fold(
      (failure) {
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (data) {
        final newMessages = data['messages'] as List<MCMessageEvent>;
        final nextToken = data['nextToken'] as String?;

        if (newMessages.isEmpty) {
          emit(currentState.copyWith(isLoadingMore: false, nextToken: null));
          return;
        }

        emit(
          currentState.copyWith(
            messages: [...newMessages, ...currentState.messages],
            isLoadingMore: false,
            nextToken: nextToken,
          ),
        );
      },
    );
  }
}
