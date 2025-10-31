// import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

// import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:mescat/core/mescat/domain/usecases/mescat_usecases.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
// import 'package:matrix/matrix.dart';
import 'package:mescat/core/notifications/event_pusher.dart';

part 'room_state.dart';
part 'room_event.dart';

// Room BLoC
class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final GetRoomsUseCase getRoomsUseCase;
  final CreateRoomUseCase createRoomUseCase;
  final JoinRoomUseCase joinRoomUseCase;
  final EventPusher eventPusher;
  final Logger logger = Logger();

  RoomBloc({
    required this.getRoomsUseCase,
    required this.createRoomUseCase,
    required this.joinRoomUseCase,
    
    required this.eventPusher,
  }) : super(RoomInitial()) {
    on<LoadRooms>(_onLoadRooms);
    on<CreateRoom>(_onCreateRoom);
    on<JoinRoom>(_onJoinRoom);
    on<SelectRoom>(_onSelectRoom);
    on<UpdateRoom>(_onUpdateRoom);
  }

  Future<void> _onUpdateRoom(UpdateRoom event, Emitter<RoomState> emit) async {
    if (state is RoomLoaded) {}
  }

  Future<void> _onLoadRooms(LoadRooms event, Emitter<RoomState> emit) async {
    emit(RoomLoading());

    final result = await getRoomsUseCase(event.spaceId);

    result.fold((failure) => emit(RoomError(failure.toString())), (rooms) {
      emit(
        RoomLoaded(
          rooms: rooms,
          selectedRoomId: rooms.isNotEmpty ? rooms.first.roomId : null,
          selectedRoom: rooms.isNotEmpty ? rooms.first : null,
        ),
      );

      if (state is RoomLoaded) {
        final currentState = state as RoomLoaded;
        if (currentState.selectedRoomId != null) {
          event.onComplete?.call(currentState.selectedRoom!);
        }
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
      MatrixRoom? selectedRoom;
      final index = currentState.rooms.indexWhere(
        (room) => room.roomId == event.roomId,
      );
      if (index != -1) {
        selectedRoom = currentState.rooms[index];
      }
      emit(
        currentState.copyWith(
          selectedRoomId: event.roomId,
          selectedRoom: selectedRoom,
          // messages: [], 
        ),
      );
      // Load messages for the selected room
      if (event.roomId != null) {
        event.onComplete?.call(roomId: event.roomId!);
      }
    }
  }
}
