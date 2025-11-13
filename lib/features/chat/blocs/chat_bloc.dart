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
  final EventPusher eventPusher;

  ChatBloc({
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.addReactionUseCase,
    required this.removeReactionUseCase,
    required this.deleteMessageUseCase,
    required this.editMessageUseCase,
    required this.replyMessageUseCase,
    required this.eventPusher,
  }) : super(ChatInitial()) {
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
    _eventSubscription();
  }

  void _eventSubscription() {
    eventPusher.eventStream.listen((event) {
      if (state is ChatLoaded) {
        final currentState = state as ChatLoaded;
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

  void _onReceiveMessage(ReceiveMessage event, Emitter<ChatState> emit) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      if (event.message.roomId == currentState.selectedRoomId) {
        final updatedMessages = [...currentState.messages, event.message];
        emit(currentState.copyWith(messages: updatedMessages));
      }
    }
  }

  void _onMessageReacted(MessageReacted event, Emitter<ChatState> emit) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
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

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());

    final result = await getMessagesUseCase(
      roomId: event.roomId,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.toString())),
      (messages) => emit(
        ChatLoaded(
          selectedRoomId: event.roomId,
          messages: messages,
          inputAction: const InputActionData(action: InputAction.none),
        ),
      ),
    );
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
      (message) {},
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

    result.fold(
      (failure) => emit(ChatError(message: failure.toString())),
      (success) {},
    );
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
      if (success && state is ChatLoaded) {
        final currentState = state as ChatLoaded;
        final updatedMessages = currentState.messages
            .where((msg) => msg.eventId != event.eventId)
            .toList();
        emit(currentState.copyWith(messages: updatedMessages));
      }
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
      if (state is ChatLoaded) {
        final currentState = state as ChatLoaded;
        final updatedMessages = currentState.messages.map((msg) {
          return msg.eventId == editedMessage.eventId ? editedMessage : msg;
        }).toList();
        emit(currentState.copyWith(messages: updatedMessages));
      }
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
      (message) {},
    );
  }

  Future<void> _onSetInputAction(
    SetInputAction event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
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
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      if (currentState.selectedRoomId == null) return;

      emit(currentState.copyWith(isLoadingMore: true));

      final result = await getMessagesUseCase(
        roomId: currentState.selectedRoomId!,
        limit: event.limit,
        fromToken: MCEvent.endToken,
      );

      result.fold((failure) => emit(ChatError(message: failure.toString())), (
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
