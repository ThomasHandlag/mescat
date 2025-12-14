part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatError extends ChatState {
  final String message;

  const ChatError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ChatLoaded extends ChatState {
  final String? selectedRoomId;
  final List<MCMessageEvent> messages;
  final InputActionData inputAction;
  final bool isLoadingMore;
  final String? nextToken;

  const ChatLoaded({
    this.selectedRoomId,
    this.inputAction = const InputActionData(action: InputAction.none),
    this.messages = const [],
    this.isLoadingMore = false,
    this.nextToken,
  });

  bool get hasMoreMessages => nextToken != null;

  @override
  List<Object?> get props => [
    messages,
    inputAction,
    isLoadingMore,
    nextToken,
    selectedRoomId,
  ];

  ChatLoaded copyWith({
    String? selectedRoomId,
    List<MCMessageEvent>? messages,
    InputActionData? inputAction,
    bool? isLoadingMore,
    String? nextToken,
    MatrixRoom? selectedRoom,
  }) {
    return ChatLoaded(
      selectedRoomId: selectedRoomId ?? this.selectedRoomId,
      messages: messages ?? this.messages,
      inputAction: inputAction ?? this.inputAction,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      nextToken: nextToken,
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
