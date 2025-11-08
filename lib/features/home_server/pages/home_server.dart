import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/features/home_server/cubits/server_cubit.dart';
import 'package:mescat/shared/widgets/mc_button.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeServer extends StatefulWidget {
  const HomeServer({super.key});

  @override
  State<HomeServer> createState() => _HomeServerState();
}

class _HomeServerState extends State<HomeServer> {
  void _onSelectServer(ServerInfo info) {
    context.read<ServerCubit>().setServerUrl(info);
  }

  @override
  void initState() {
    super.initState();
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Home Server Info'),
        content: const Text(
          'Your home server is where your account and data are stored. '
          'You can use any Matrix-compatible server.',
        ),
        actions: [
          McButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  final FocusNode focusNode = FocusNode();

  Future<void> _initClient(String url) async {
    final client = getIt<Client>();
    setState(() {
      _checking = true;
    });
    try {
      await client.checkHomeserver(Uri.parse('https://$url'));
    } catch (e) {
      log('Failed to connect to server: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to server: $url')),
      );
      setState(() {
        _checking = false;
      });
      return;
    }
    client.homeserver = Uri.parse('https://$url');
    _toAuthPage();
  }

  void _toAuthPage() {
    Navigator.of(context).pop();
  }

  bool _checking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Server')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          child: BlocBuilder<ServerCubit, ServerState>(
            builder: (context, state) {
              return Column(
                spacing: 10,
                children: [
                  SearchAnchor(
                    builder: (context, controller) {
                      return SearchBar(
                        focusNode: focusNode,
                        leading: const Icon(Icons.search),
                        padding: const WidgetStatePropertyAll<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                        controller: controller,
                        shape: const WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        hintText: 'Search public servers',
                        hintStyle: WidgetStatePropertyAll(
                          TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                        elevation: const WidgetStatePropertyAll(4),
                        trailing: [
                          McButton(
                            onPressed: _showInfo,
                            child: const Icon(Icons.info_outline),
                          ),
                        ],
                        onChanged: (value) => controller.openView(),
                        onTap: () => controller.openView,
                      );
                    },
                    suggestionsBuilder: (context, controller) {
                      if (state is ServerListLoaded) {
                        log(state.servers.toString());
                        return state.servers
                            .where(
                              (server) =>
                                  server.domain.contains(controller.text),
                            )
                            .map(
                              (server) => ListTile(
                                onTap: () {
                                  _onSelectServer(server);
                                  controller.closeView(server.domain);
                                  focusNode.unfocus();
                                },
                                title: Text(server.domain),
                                trailing: server.location != null
                                    ? Text(server.location!)
                                    : null,
                              ),
                            )
                            .toList();
                      }
                      return [];
                    },
                    isFullScreen: false,
                  ),
                  const Text(
                    'Please read server rules and privacy policy before connecting.',
                  ),
                  const Text(
                    'By connecting, you agree to abide by the server\'s terms of service.',
                  ),
                  if (state is ServerListLoaded)
                    state.selectedServer != null
                        ? Row(
                            children: [
                              Text(
                                'Selected Server: ${state.selectedServer!.domain}',
                              ),
                              McButton(
                                onPressed: () {
                                  if (state.selectedServer!.rulesUrl != null) {
                                    launchUrl(
                                      Uri.parse(
                                        state.selectedServer!.rulesUrl!,
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Rules',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              const Text('&'),
                              McButton(
                                onPressed: () {
                                  if (state.selectedServer!.privacyUrl !=
                                      null) {
                                    launchUrl(
                                      Uri.parse(
                                        state.selectedServer!.privacyUrl!,
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Privacy',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Text('No server selected.'),
                  Row(
                    children: [
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          if (state is ServerListLoaded &&
                              state.selectedServer != null &&
                              !_checking) {
                            _initClient(state.selectedServer!.domain);
                          }
                        },
                        child: const Text('Connect'),
                      ),
                    ],
                  ),
                  if (_checking) const LinearProgressIndicator(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
