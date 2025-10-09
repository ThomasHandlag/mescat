import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mescat/core/mescat/domain/usecases/mescat_usecases.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:matrix/matrix.dart';

part 'room_state.dart';
part 'room_event.dart';

// Room BLoC
class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final GetRoomsUseCase getRoomsUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final CreateRoomUseCase createRoomUseCase;
  final JoinRoomUseCase joinRoomUseCase;
  final AddReactionUseCase addReactionUseCase;
  final RemoveReactionUseCase removeReactionUseCase;

  RoomBloc({
    required this.getRoomsUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.createRoomUseCase,
    required this.joinRoomUseCase,
    required this.addReactionUseCase,
    required this.removeReactionUseCase,
  }) : super(RoomInitial()) {
    on<LoadRooms>(_onLoadRooms);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<CreateRoom>(_onCreateRoom);
    on<JoinRoom>(_onJoinRoom);
    on<SelectRoom>(_onSelectRoom);
    on<AddReaction>(_onAddReaction);
    on<RemoveReaction>(_onRemoveReaction);
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
        add(LoadRooms());
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

    result.fold((failure) => emit(RoomError(failure.toString())), (success) {
      // Optionally handle success, e.g., refresh messages or update state
    });
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
}
