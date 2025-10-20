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
  final MatrixRoom? selectedRoom;
  // final List<MCMessageEvent> messages;
  // final bool isLoadingMessages;
  // final InputActionData inputAction;
  // final bool isLoadingMore;

  const RoomLoaded({
    required this.rooms,
    this.selectedRoomId,
    // this.inputAction = const InputActionData(action: InputAction.none),
    // this.messages = const [],
    // this.isLoadingMessages = false,
    // this.isLoadingMore = false,
    this.selectedRoom,
  });

  @override
  List<Object?> get props => [
    rooms,
    selectedRoomId,
    // messages,
    // isLoadingMessages,
    // inputAction,
    // isLoadingMore,
    selectedRoom,
  ];

  RoomLoaded copyWith({
    List<MatrixRoom>? rooms,
    String? selectedRoomId,
    // List<MCMessageEvent>? messages,
    // bool? isLoadingMessages,
    // InputActionData? inputAction,
    // bool? isLoadingMore,
    MatrixRoom? selectedRoom,
  }) {
    return RoomLoaded(
      rooms: rooms ?? this.rooms,
      selectedRoomId: selectedRoomId ?? this.selectedRoomId,
      // messages: messages ?? this.messages,
      // isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      // inputAction: inputAction ?? this.inputAction,
      // isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      selectedRoom: selectedRoom ?? this.selectedRoom,
    );
  }
}

class RoomError extends RoomState {
  final String message;

  const RoomError(this.message);

  @override
  List<Object?> get props => [message];
}

// enum InputAction { none, reply, edit }

// class InputActionData extends Equatable {
//   final InputAction action;
//   final String? targetEventId;
//   final String? initialContent;

//   const InputActionData({
//     required this.action,
//     this.targetEventId,
//     this.initialContent,
//   });

//   @override
//   List<Object?> get props => [action, targetEventId, initialContent];
// }
