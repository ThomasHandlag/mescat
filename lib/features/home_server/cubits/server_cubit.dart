import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

part 'server_state.dart';

final class ServerCubit extends Cubit<ServerState> {
  ServerCubit() : super((const ServerEmpty()));

  final Logger _logger = Logger();

  final String _selected = 'selected_server';
  final String _serversBox = 'servers_box';
  static const String listKey = 'servers_list';

  void setServerUrl(ServerInfo server) async {
    final box = await Hive.openBox(_selected);
    final listBox = await Hive.openBox(_serversBox);
    final existingServers = listBox.get(listKey) as List<dynamic>? ?? [];
    if (!existingServers
        .any((element) => ServerInfo.fromJson(jsonDecode(element)).domain ==
            server.domain)) {
      existingServers.add(jsonEncode(server.toJson()));
      await listBox.put(listKey, existingServers);
    }
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
    ServerInfo selectedServer = servers.first;
    try {
      final serverBox = await Hive.openBox(_serversBox);
      final cachedServers = serverBox.get(listKey) as List<dynamic>?;
      if (cachedServers != null && cachedServers.isNotEmpty) {
        for (final serverMap in cachedServers) {
          final serverInfo = ServerInfo.fromJson(jsonDecode(serverMap));
          servers.add(serverInfo);
        }

        final selectedServerDomainBox = await Hive.openBox(_selected);
        final selectedServerJson = selectedServerDomainBox.get('server_info');
        if (selectedServerJson != null) {
          selectedServer = ServerInfo.fromJson(jsonDecode(selectedServerJson));
          emit(ServerListLoaded(servers, selectedServer: selectedServer));
        } else {
          selectedServerDomainBox.put('server_info', servers.first.toJson());
          emit(ServerListLoaded(servers, selectedServer: servers.first));
        }
      }
    } catch (e, stackTrace) {
      _logger.log(
        Level.error,
        'Failed to load servers list',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      emit(ServerListLoaded(servers, selectedServer: servers.first));
    }
  }
}
