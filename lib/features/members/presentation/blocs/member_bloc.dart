import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/core/mescat/domain/usecases/mescat_usecases.dart';

part 'member_event.dart';
part 'member_state.dart';

// Member BLoC
class MemberBloc extends Bloc<MemberEvent, MemberState> {
  final GetRoomMembersUseCase getRoomMembersUseCase;

  MemberBloc({required this.getRoomMembersUseCase}) : super(MemberInitial()) {
    on<LoadMembers>(_onLoadMembers);
    on<LoadUsersInSpace>(_onLoadUsersInSpace);
  }

  Future<void> _onLoadMembers(
    LoadMembers event,
    Emitter<MemberState> emit,
  ) async {
    emit(MemberLoading());

    final result = await getRoomMembersUseCase(event.roomId);

    result.fold(
      (failure) => emit(MemberInitial()), // Handle failure state as needed
      (members) => emit(MemberLoaded(members: members)),
    );
  }

  Future<void> _onLoadUsersInSpace(
    LoadUsersInSpace event,
    Emitter<MemberState> emit,
  ) async {
    emit(MemberLoading());

    final result = await getRoomMembersUseCase(event.spaceId);

    result.fold(
      (failure) => emit(MemberInitial()), // Handle failure state as needed
      (members) => emit(MemberLoaded(members: members)),
    );
  }
}
