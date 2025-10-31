import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:mescat/core/http/servers_list_api.dart';

part 'server_state.dart';

final class ServerCubit extends Cubit<ServerState> {
  ServerCubit() : super((const ServerEmpty()));

  final Logger _logger = Logger();

  final String _selected = 'selected_server';
  final String _serversBox = 'servers_box';
  static const String listKey = 'servers_list';

  void setServerUrl(ServerInfo server) async {
    final box = await Hive.openBox(_selected);
    await box.put('server_info', server.toJson());
    if (state is ServerListLoaded) {
      final currentState = state as ServerListLoaded;
      emit(currentState.copyWith(selectedServer: server));
    }
  }

  Future<void> loadServersList() async {
    emit(const ServerListLoading());
    final List<ServerInfo> servers = [
      const ServerInfo(
        domain: 'matrix.org',
        online: 1,
        rulesUrl: null,
        privacyUrl: null,
        location: null,
        slidingSync: true,
        email: true,
        captcha: true,
      ),
    ];
    try {
      final serverBox = await Hive.openBox(_serversBox);
      final cachedServers = serverBox.get(listKey) as List<dynamic>?;
      if (cachedServers != null && cachedServers.isNotEmpty) {
        for (final serverMap in cachedServers) {
          final serverInfo = ServerInfo.fromJson(jsonDecode(serverMap));
          servers.add(serverInfo);
        }
        servers.add(
          const ServerInfo(
            domain: 'matrix.org',
            online: 1,
            rulesUrl: null,
            privacyUrl: null,
            location: null,
            slidingSync: true,
            email: true,
            captcha: true,
          ),
        );

        final selectedServerDomainBox = await Hive.openBox(_selected);
        final selectedServer = selectedServerDomainBox.get('server_info');
        emit(
          ServerListLoaded(
            servers,
            selectedServer: ServerInfo.fromJson(jsonDecode(selectedServer)),
          ),
        );
        return;
      } else {
        final fetchedServers = await ServersListApi.fetchServersList();
        if (fetchedServers.contains(null) || fetchedServers.isEmpty) {
          emit(const ServerListLoaded([]));
          return;
        }
        for (final server in fetchedServers) {
          if (server == null) {
            continue;
          }
          final serverInfo = ServerInfo.fromJson(server);
          servers.add(serverInfo);
        }
        await serverBox.put(listKey, servers.map((e) => e.toJson()).toList());
        emit(ServerListLoaded(servers));
      }
    } catch (e, stackTrace) {
      _logger.log(
        Level.error,
        'Failed to load servers list',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
