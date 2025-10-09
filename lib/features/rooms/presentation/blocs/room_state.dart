part of 'room_bloc.dart';

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
  final List<MCMessageEvent> messages;
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
    List<MCMessageEvent>? messages,
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