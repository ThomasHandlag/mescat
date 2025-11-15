import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/core/mescat/domain/usecases/mescat_usecases.dart';
import 'package:mescat/core/notifications/event_pusher.dart';

part 'space_event.dart';
part 'space_state.dart';

// Space BLoC
class SpaceBloc extends Bloc<SpaceEvent, SpaceState> {
  final GetSpacesUseCase getSpacesUseCase;
  final CreateSpaceUseCase createSpaceUseCase;
  final EventPusher eventPusher;

  SpaceBloc({
    required this.getSpacesUseCase,
    required this.createSpaceUseCase,
    required this.eventPusher,
  }) : super(SpaceInitial()) {
    on<LoadSpaces>(_onLoadSpaces);
    on<CreateSpace>(_onCreateSpace);
    on<SelectSpace>(_onSelectSpace);
    eventPusher.eventStream.listen((event) {
      if (event is McRoomEvent) {
        add(LoadSpaces());
      }
    });
  }

  Future<void> _onLoadSpaces(
    LoadSpaces event,
    Emitter<SpaceState> emit,
  ) async {
    emit(SpaceLoading());
    
    final result = await getSpacesUseCase();
    
    result.fold(
      (failure) => emit(SpaceError(failure.toString())),
      (spaces) => emit(SpaceLoaded(spaces: spaces)),
    );
  }

  Future<void> _onCreateSpace(
    CreateSpace event,
    Emitter<SpaceState> emit,
  ) async {
    final result = await createSpaceUseCase(
      name: event.name,
      description: event.description,
      isPublic: event.isPublic,
    );
    
    result.fold(
      (failure) => emit(SpaceError(failure.toString())),
      (space) {
        if (state is SpaceLoaded) {
          final currentState = state as SpaceLoaded;
          final updatedSpaces = [...currentState.spaces, space];
          emit(currentState.copyWith(spaces: updatedSpaces));
        }
      },
    );
  }

  Future<void> _onSelectSpace(
    SelectSpace event,
    Emitter<SpaceState> emit,
  ) async {
    if (state is SpaceLoaded) {
      final currentState = state as SpaceLoaded;
      emit(currentState.copyWith(selectedSpace: event.space));
    }
  }
}