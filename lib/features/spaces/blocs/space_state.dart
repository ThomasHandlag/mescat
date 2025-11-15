part of 'space_bloc.dart';

abstract class SpaceState extends Equatable {
  const SpaceState();

  @override
  List<Object?> get props => [];
}

class SpaceInitial extends SpaceState {}

class SpaceLoading extends SpaceState {}

class SpaceLoaded extends SpaceState {
  final List<MatrixSpace> spaces;
  final MatrixSpace? selectedSpace;

  const SpaceLoaded({required this.spaces, this.selectedSpace});

  @override
  List<Object?> get props => [spaces, selectedSpace];

  SpaceLoaded copyWith({List<MatrixSpace>? spaces, MatrixSpace? selectedSpace}) {
    return SpaceLoaded(
      spaces: spaces ?? this.spaces,
      selectedSpace: selectedSpace,
    );
  }
}

class SpaceError extends SpaceState {
  final String message;

  const SpaceError(this.message);

  @override
  List<Object?> get props => [message];
}
