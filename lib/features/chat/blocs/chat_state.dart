part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatError extends ChatState {
  final String message;

  const ChatError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ChatLoaded extends ChatState {
  final String? selectedRoomId;
  final MatrixRoom? selectedRoom;
  final List<MCMessageEvent> messages;
  final bool isLoadingMessages;
  final InputActionData inputAction;
  final bool isLoadingMore;

  const ChatLoaded({
    this.selectedRoomId,
    this.inputAction = const InputActionData(action: InputAction.none),
    this.messages = const [],
    this.isLoadingMessages = false,
    this.isLoadingMore = false,
    this.selectedRoom,
  });

  @override
  List<Object?> get props => [
    messages,
    isLoadingMessages,
    inputAction,
    isLoadingMore,
    selectedRoomId,
    selectedRoom,
  ];

  ChatLoaded copyWith({
    String? selectedRoomId,
    List<MCMessageEvent>? messages,
    bool? isLoadingMessages,
    InputActionData? inputAction,
    bool? isLoadingMore,
    MatrixRoom? selectedRoom,
  }) {
    return ChatLoaded(
      selectedRoomId: selectedRoomId ?? this.selectedRoomId,
      messages: messages ?? this.messages,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      inputAction: inputAction ?? this.inputAction,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      selectedRoom: selectedRoom ?? this.selectedRoom,
    );
  }
}

enum InputAction { none, reply, edit }

class InputActionData extends Equatable {
  final InputAction action;
  final String? targetEventId;
  final String? initialContent;

  const InputActionData({
    required this.action,
    this.targetEventId,
    this.initialContent,
  });

  @override
  List<Object?> get props => [action, targetEventId, initialContent];
}
