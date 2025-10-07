import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/matrix/domain/entities/matrix_entities.dart';
import '../../../../core/matrix/domain/usecases/matrix_usecases.dart';

// Room Events
abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object?> get props => [];
}

class LoadRooms extends RoomEvent {
  final String? spaceId;

  const LoadRooms({this.spaceId});

  @override
  List<Object?> get props => [spaceId];
}

class LoadMessages extends RoomEvent {
  final String roomId;
  final int limit;

  const LoadMessages({
    required this.roomId,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [roomId, limit];
}

class SendMessage extends RoomEvent {
  final String roomId;
  final String content;
  final MessageType type;

  const SendMessage({
    required this.roomId,
    required this.content,
    this.type = MessageType.text,
  });

  @override
  List<Object?> get props => [roomId, content, type];
}

class CreateRoom extends RoomEvent {
  final String name;
  final String? topic;
  final RoomType type;
  final bool isPublic;
  final String? parentSpaceId;

  const CreateRoom({
    required this.name,
    this.topic,
    this.type = RoomType.textChannel,
    this.isPublic = false,
    this.parentSpaceId,
  });

  @override
  List<Object?> get props => [name, topic, type, isPublic, parentSpaceId];
}

class JoinRoom extends RoomEvent {
  final String roomId;

  const JoinRoom(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class LeaveRoom extends RoomEvent {
  final String roomId;

  const LeaveRoom(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class SelectRoom extends RoomEvent {
  final String? roomId;

  const SelectRoom(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

// Room States
abstract class RoomState extends Equatable {
  const RoomState();

  @override
  List<Object?> get props => [];
}

class RoomInitial extends RoomState {}

class RoomLoading extends RoomState {}

class RoomLoaded extends RoomState {
  final List<MatrixRoom> rooms;
  final String? selectedRoomId;
  final List<MatrixMessage> messages;
  final bool isLoadingMessages;

  const RoomLoaded({
    required this.rooms,
    this.selectedRoomId,
    this.messages = const [],
    this.isLoadingMessages = false,
  });

  @override
  List<Object?> get props => [rooms, selectedRoomId, messages, isLoadingMessages];

  RoomLoaded copyWith({
    List<MatrixRoom>? rooms,
    String? selectedRoomId,
    List<MatrixMessage>? messages,
    bool? isLoadingMessages,
  }) {
    return RoomLoaded(
      rooms: rooms ?? this.rooms,
      selectedRoomId: selectedRoomId ?? this.selectedRoomId,
      messages: messages ?? this.messages,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
    );
  }
}

class RoomError extends RoomState {
  final String message;

  const RoomError(this.message);

  @override
  List<Object?> get props => [message];
}

// Room BLoC
class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final GetRoomsUseCase getRoomsUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final CreateRoomUseCase createRoomUseCase;
  final JoinRoomUseCase joinRoomUseCase;

  RoomBloc({
    required this.getRoomsUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.createRoomUseCase,
    required this.joinRoomUseCase,
  }) : super(RoomInitial()) {
    on<LoadRooms>(_onLoadRooms);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<CreateRoom>(_onCreateRoom);
    on<JoinRoom>(_onJoinRoom);
    on<SelectRoom>(_onSelectRoom);
  }

  Future<void> _onLoadRooms(
    LoadRooms event,
    Emitter<RoomState> emit,
  ) async {
    emit(RoomLoading());
    
    final result = await getRoomsUseCase(event.spaceId);
    
    result.fold(
      (failure) => emit(RoomError(failure.toString())),
      (rooms) => emit(RoomLoaded(rooms: rooms)),
    );
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
        (messages) => emit(currentState.copyWith(
          messages: messages,
          isLoadingMessages: false,
        )),
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
    
    result.fold(
      (failure) => emit(RoomError(failure.toString())),
      (message) {
        if (state is RoomLoaded) {
          final currentState = state as RoomLoaded;
          final updatedMessages = [...currentState.messages, message];
          emit(currentState.copyWith(messages: updatedMessages));
        }
      },
    );
  }

  Future<void> _onCreateRoom(
    CreateRoom event,
    Emitter<RoomState> emit,
  ) async {
    final result = await createRoomUseCase(
      name: event.name,
      topic: event.topic,
      type: event.type,
      isPublic: event.isPublic,
      parentSpaceId: event.parentSpaceId,
    );
    
    result.fold(
      (failure) => emit(RoomError(failure.toString())),
      (room) {
        if (state is RoomLoaded) {
          final currentState = state as RoomLoaded;
          final updatedRooms = [...currentState.rooms, room];
          emit(currentState.copyWith(rooms: updatedRooms));
        }
      },
    );
  }

  Future<void> _onJoinRoom(
    JoinRoom event,
    Emitter<RoomState> emit,
  ) async {
    final result = await joinRoomUseCase(event.roomId);
    
    result.fold(
      (failure) => emit(RoomError(failure.toString())),
      (success) {
        if (success) {
          // Reload rooms to show the newly joined room
          add(LoadRooms());
        }
      },
    );
  }

  Future<void> _onSelectRoom(
    SelectRoom event,
    Emitter<RoomState> emit,
  ) async {
    if (state is RoomLoaded) {
      final currentState = state as RoomLoaded;
      emit(currentState.copyWith(
        selectedRoomId: event.roomId,
        messages: [], // Clear messages when switching rooms
      ));
      
      // Load messages for the selected room
      if (event.roomId != null) {
        add(LoadMessages(roomId: event.roomId!));
      }
    }
  }
}