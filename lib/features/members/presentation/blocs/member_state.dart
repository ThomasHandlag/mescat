part of 'member_bloc.dart';

abstract class MemberState extends Equatable {
  const MemberState();

  @override
  List<Object?> get props => [];
}

final class MemberInitial extends MemberState {}

final class MemberLoading extends MemberState {}

final class MemberLoaded extends MemberState {
  final List<MCUser> members;

  const MemberLoaded({required this.members});

  @override
  List<Object?> get props => [members];
}
