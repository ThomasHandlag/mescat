import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/matrix/domain/entities/matrix_entities.dart';
import '../../../../core/matrix/domain/usecases/matrix_usecases.dart';

// Space Events
abstract class SpaceEvent extends Equatable {
  const SpaceEvent();

  @override
  List<Object?> get props => [];
}

class LoadSpaces extends SpaceEvent {}

class CreateSpace extends SpaceEvent {
  final String name;
  final String? description;
  final bool isPublic;

  const CreateSpace({
    required this.name,
    this.description,
    this.isPublic = false,
  });

  @override
  List<Object?> get props => [name, description, isPublic];
}

class SelectSpace extends SpaceEvent {
  final String? spaceId;

  const SelectSpace(this.spaceId);

  @override
  List<Object?> get props => [spaceId];
}

// Space States
abstract class SpaceState extends Equatable {
  const SpaceState();

  @override
  List<Object?> get props => [];
}

class SpaceInitial extends SpaceState {}

class SpaceLoading extends SpaceState {}

class SpaceLoaded extends SpaceState {
  final List<MatrixSpace> spaces;
  final String? selectedSpaceId;

  const SpaceLoaded({
    required this.spaces,
    this.selectedSpaceId,
  });

  @override
  List<Object?> get props => [spaces, selectedSpaceId];

  SpaceLoaded copyWith({
    List<MatrixSpace>? spaces,
    String? selectedSpaceId,
  }) {
    return SpaceLoaded(
      spaces: spaces ?? this.spaces,
      selectedSpaceId: selectedSpaceId ?? this.selectedSpaceId,
    );
  }
}

class SpaceError extends SpaceState {
  final String message;

  const SpaceError(this.message);

  @override
  List<Object?> get props => [message];
}

// Space BLoC
class SpaceBloc extends Bloc<SpaceEvent, SpaceState> {
  final GetSpacesUseCase getSpacesUseCase;
  final CreateSpaceUseCase createSpaceUseCase;

  SpaceBloc({
    required this.getSpacesUseCase,
    required this.createSpaceUseCase,
  }) : super(SpaceInitial()) {
    on<LoadSpaces>(_onLoadSpaces);
    on<CreateSpace>(_onCreateSpace);
    on<SelectSpace>(_onSelectSpace);
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
      emit(currentState.copyWith(selectedSpaceId: event.spaceId));
    }
  }
}