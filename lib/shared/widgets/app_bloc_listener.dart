import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/authentication/blocs/auth_bloc.dart';
import 'package:mescat/features/chat/blocs/chat_bloc.dart';
import 'package:mescat/features/chat/pages/chat_page.dart';
import 'package:mescat/features/chat/widgets/collapse_call_view.dart';
import 'package:mescat/features/rooms/blocs/room_bloc.dart';
import 'package:mescat/features/spaces/blocs/space_bloc.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';
import 'package:mescat/shared/util/mc_dialog.dart';
import 'package:mescat/shared/util/widget_overlay_service.dart';

class AppBlocListener extends StatelessWidget {
  const AppBlocListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext buildContext) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MescatBloc, MescatStatus>(
          listener: (context, state) {
            if (state is NetworkError || state is Unauthenticated) {
              WidgetOverlayService.hideAll();
            }
          },
        ),
        BlocListener<CallBloc, MCCallState>(
          listener: (context, state) {
            if (state is! CallInProgress) {
              WidgetOverlayService.hide();
            }
          },
        ),
        BlocListener<SpaceBloc, SpaceState>(
          listener: (context, state) {
            final callState = context.read<CallBloc>().state;
            if (callState is CallInProgress &&
                state is SpaceLoaded &&
                callState.mRoom.parentSpaceId != state.selectedSpace?.spaceId) {
              context.read<CallBloc>().add(const LeaveCall());
            }
          },
        ),
        BlocListener<RoomBloc, RoomState>(
          listener: (context, state) {
            final callState = context.read<CallBloc>().state;
            if (state is RoomLoaded) {
              if (state.selectedRoom?.canHaveCall == true) {
                if (callState is CallInProgress) {
                  if (state.selectedRoomId == callState.roomId) {
                    WidgetOverlayService.hide();
                    context.read<ChatBloc>().add(SelectRoom(callState.roomId));
                    if (Platform.isAndroid || Platform.isIOS) {
                      showFullscreenDialog(
                        buildContext,
                        ChatPage(context: buildContext),
                      );
                    }
                  } else {
                    context.read<CallBloc>().add(
                      JoinCall(mRoom: state.selectedRoom!),
                    );
                    context.read<ChatBloc>().add(
                      SelectRoom(state.selectedRoom!.roomId),
                    );
                    if (Platform.isAndroid || Platform.isIOS) {
                      showFullscreenDialog(
                        buildContext,
                        ChatPage(context: buildContext),
                      );
                    }
                  }
                } else {
                  context.read<CallBloc>().add(
                    JoinCall(mRoom: state.selectedRoom!),
                  );
                  if ((Platform.isAndroid || Platform.isIOS) &&
                      state.selectedRoom != null) {
                    showFullscreenDialog(
                      buildContext,
                      ChatPage(context: buildContext),
                    );
                  }
                }
              } else {
                if (state.selectedRoom == null) {
                  return;
                }
                final room = state.selectedRoom!;
                context.read<ChatBloc>().add(SelectRoom(room.roomId));

                if (callState is CallInProgress) {
                  WidgetOverlayService.show(
                    buildContext,
                    onExpand: () {
                      context.read<RoomBloc>().add(
                        SelectedRoom(callState.mRoom),
                      );
                      context.read<ChatBloc>().add(
                        SelectRoom(callState.mRoom.roomId),
                      );
                    },
                    child: const CollapseCallView(),
                  );
                }

                if (Platform.isAndroid || Platform.isIOS) {
                  showFullscreenDialog(
                    buildContext,
                    ChatPage(context: buildContext),
                  );
                }
              }
            }
          },
        ),
      ],
      child: child,
    );
  }
}
