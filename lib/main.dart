import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_vodozemac/flutter_vodozemac.dart' as vod;
// import 'package:mescat/core/utils/app_bloc_observer.dart';
import 'package:mescat/features/authentication/pages/auth_page.dart';
import 'package:mescat/features/chat/pages/chat_page.dart';
import 'package:mescat/features/chat/widgets/collapse_call_view.dart';
import 'package:mescat/features/home_server/cubits/server_cubit.dart';
import 'package:mescat/shared/util/mc_dialog.dart';
import 'package:mescat/shared/util/widget_overlay_service.dart';
import 'package:rive/rive.dart';

import 'package:mescat/features/chat/blocs/chat_bloc.dart';
import 'package:mescat/features/voip/blocs/call_bloc.dart';
import 'package:mescat/shared/pages/home_page.dart';
import 'package:mescat/shared/pages/loading_page.dart';
import 'package:mescat/features/members/blocs/member_bloc.dart';
import 'package:mescat/core/themes/app_themes.dart';
import 'package:mescat/features/authentication/blocs/auth_bloc.dart';
import 'package:mescat/features/rooms/blocs/room_bloc.dart';
import 'package:mescat/features/spaces/blocs/space_bloc.dart';
import 'package:mescat/dependency_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await vod.init();
  await setupDependencyInjection();
  await RiveNative.init();
  // Bloc.observer = AppBlocObserver();
  runApp(const MescatBlocProvider());
}

final class MescatBlocProvider extends StatelessWidget {
  const MescatBlocProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MescatBloc(
            loginUseCase: getIt(),
            registerUseCase: getIt(),
            logoutUseCase: getIt(),
            getCurrentUserUseCase: getIt(),
            setServerUseCase: getIt(),
            oauthLoginUseCase: getIt(),
          )..add(InitialEvent()),
        ),
        BlocProvider(
          create: (context) => ChatBloc(
            getMessagesUseCase: getIt(),
            sendMessageUseCase: getIt(),
            addReactionUseCase: getIt(),
            removeReactionUseCase: getIt(),
            deleteMessageUseCase: getIt(),
            editMessageUseCase: getIt(),
            replyMessageUseCase: getIt(),
            eventPusher: getIt(),
          ),
        ),
        BlocProvider(
          create: (context) =>
              CallBloc(eventPusher: getIt(), callHandler: getIt()),
        ),
        BlocProvider(create: (context) => ServerCubit()..loadServersList()),
        BlocProvider(
          create: (context) => RoomBloc(
            getRoomsUseCase: getIt(),
            createRoomUseCase: getIt(),
            joinRoomUseCase: getIt(),
            eventPusher: getIt(),
          ),
        ),
        BlocProvider(
          create: (context) => SpaceBloc(
            getSpacesUseCase: getIt(),
            createSpaceUseCase: getIt(),
            eventPusher: getIt(),
          ),
        ),
        BlocProvider(
          create: (context) => MemberBloc(getRoomMembersUseCase: getIt()),
        ),
        BlocProvider(
          create: (context) => ChatBloc(
            getMessagesUseCase: getIt(),
            sendMessageUseCase: getIt(),
            addReactionUseCase: getIt(),
            removeReactionUseCase: getIt(),
            deleteMessageUseCase: getIt(),
            editMessageUseCase: getIt(),
            replyMessageUseCase: getIt(),
            eventPusher: getIt(),
          ),
        ),
      ],
      child: SafeArea(
        child: MaterialApp(
          title: 'Mescat',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeMode.system,
          home: const MescatApp(),
        ),
      ),
    );
  }
}

final class MescatApp extends StatelessWidget {
  const MescatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CallBloc, MCCallState>(
          listener: (context, state) {
            if (state is! CallInProgress) {
              WidgetOverlayService.hide();
            }
          },
        ),
        BlocListener<MescatBloc, MescatStatus>(
          listener: (context, state) {
            if (state is NetworkError || state is Unauthenticated) {
              context.read<CallBloc>().add(const LeaveCall());
              WidgetOverlayService.hide();
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
                    if (Platform.isAndroid || Platform.isIOS) {
                      showFullscreenDialog(
                        context,
                        ChatPage(parentContext: context),
                      );
                    }
                  } else {
                    context.read<CallBloc>().add(
                      JoinCall(mRoom: state.selectedRoom!),
                    );
                    if (Platform.isAndroid || Platform.isIOS) {
                      showFullscreenDialog(
                        context,
                        ChatPage(parentContext: context),
                      );
                    }
                  }
                } else {
                  context.read<CallBloc>().add(
                    JoinCall(mRoom: state.selectedRoom!),
                  );
                  if (Platform.isAndroid || Platform.isIOS) {
                    showFullscreenDialog(
                      context,
                      ChatPage(parentContext: context),
                    );
                  }
                }
              } else {
                if (state.selectedRoom == null) {
                  return;
                }
                final room = state.selectedRoom!;
                context.read<ChatBloc>().add(LoadMessages(roomId: room.roomId));

                if (callState is CallInProgress) {
                  WidgetOverlayService.show(
                    context,
                    onExpand: () {
                      context.read<RoomBloc>().add(
                        SelectRoom(callState.mRoom, flag: true),
                      );
                    },
                    child: const CollapseCallView(),
                  );
                }

                if (Platform.isAndroid || Platform.isIOS) {
                  showFullscreenDialog(
                    context,
                    ChatPage(parentContext: context),
                  );
                }
              }
            }
          },
        ),
      ],
      child: BlocBuilder<MescatBloc, MescatStatus>(
        builder: (context, state) {
          if (state is Authenticated) {
            return const HomePage();
          } else if (state is Loading || state is Inititial) {
            return const LoadingPage();
          } else if (state is NetworkError) {
            return Scaffold(body: Center(child: Text(state.message)));
          } else {
            return const AuthPage();
          }
        },
      ),
    );
  }
}
