import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/members/presentation/blocs/member_bloc.dart';
import 'package:mescat/features/spaces/presentation/blocs/space_bloc.dart';
import 'package:mescat/shared/widgets/user_banner.dart';

class SpaceMembersList extends StatelessWidget {
  const SpaceMembersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      width: 250,
      child: BlocListener<SpaceBloc, SpaceState>(
        listener: (context, state) {
          if (state is SpaceLoaded &&
              state.selectedSpaceId != null &&
              state.selectedSpaceId!.isNotEmpty) {
            context.read<MemberBloc>().add(LoadMembers(state.selectedSpaceId!));
          }
        },
        child: BlocBuilder<MemberBloc, MemberState>(
          builder: (context, state) {
            if (state is MemberInitial) {
              return const Center(child: Text('No members loaded'));
            } else if (state is MemberLoaded && state.members.isEmpty) {
              return const Center(child: Text('No members in this space'));
            } else if (state is MemberLoaded && state.members.isNotEmpty) {
              return ListView.builder(
                itemCount: state.members.length,
                itemBuilder: (context, index) {
                  final member = state.members[index];
                  return UserBanner(
                    username: member.displayName ?? member.userId,
                    avatarUrl: member.avatarUrl,
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
