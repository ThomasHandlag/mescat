part of 'space_bloc.dart';

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

