part of 'member_bloc.dart';

abstract class MemberEvent extends Equatable {
  const MemberEvent();

  @override
  List<Object?> get props => [];
}

class LoadMembers extends MemberEvent {
  final String roomId;

  const LoadMembers(this.roomId);

  @override
  List<Object?> get props => [roomId];
}
class LoadUsersInSpace extends MemberEvent {
  final String spaceId;

  const LoadUsersInSpace(this.spaceId);

  @override
  List<Object?> get props => [spaceId];
}