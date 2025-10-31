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
  final String? selectedSpaceId;

  const SpaceLoaded({required this.spaces, this.selectedSpaceId});

  @override
  List<Object?> get props => [spaces, selectedSpaceId];

  SpaceLoaded copyWith({List<MatrixSpace>? spaces, String? selectedSpaceId}) {
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
