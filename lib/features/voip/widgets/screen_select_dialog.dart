import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class ThumbnailWidget extends StatefulWidget {
  const ThumbnailWidget({
    super.key,
    required this.source,
    required this.selected,
    required this.onTap,
  });
  final DesktopCapturerSource source;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<ThumbnailWidget> createState() => _ThumbnailWidgetState();
}

class _ThumbnailWidgetState extends State<ThumbnailWidget> {
  final List<StreamSubscription> _subscriptions = [];
  Uint8List? _thumbnail;
  
  @override
  void initState() {
    super.initState();
    _subscriptions.add(
      widget.source.onThumbnailChanged.stream.listen((event) {
        if (mounted) {
          setState(() {
            _thumbnail = event;
          });
        }
      }),
    );
    _subscriptions.add(
      widget.source.onNameChanged.stream.listen((event) {
        if (mounted) {
          setState(() {});
        }
      }),
    );
  }

  @override
  void dispose() {
    for (var element in _subscriptions) {
      element.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: widget.selected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: widget.selected
            ? BorderSide(
                width: 3,
                color: Theme.of(context).colorScheme.primary,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                child: _thumbnail != null
                    ? Image.memory(
                        _thumbnail!,
                        gaplessPlayback: true,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(0x4D),
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.source.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight:
                          widget.selected ? FontWeight.bold : FontWeight.normal,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScreenSelectDialog extends StatefulWidget {
  const ScreenSelectDialog({super.key});

  @override
  State<ScreenSelectDialog> createState() => _ScreenSelectDialogState();
}

class _ScreenSelectDialogState extends State<ScreenSelectDialog>
    with SingleTickerProviderStateMixin {
  final Map<String, DesktopCapturerSource> _sources = {};
  SourceType _sourceType = SourceType.Screen;
  DesktopCapturerSource? _selectedSource;
  final List<StreamSubscription<DesktopCapturerSource>> _subscriptions = [];
  Timer? _timer;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    Future.delayed(const Duration(milliseconds: 100), () {
      _getSources();
    });

    _subscriptions.add(
      desktopCapturer.onAdded.stream.listen((source) {
        if (mounted) {
          setState(() {
            _sources[source.id] = source;
          });
        }
      }),
    );

    _subscriptions.add(
      desktopCapturer.onRemoved.stream.listen((source) {
        if (mounted) {
          setState(() {
            _sources.remove(source.id);
          });
        }
      }),
    );

    _subscriptions.add(
      desktopCapturer.onThumbnailChanged.stream.listen((source) {
        if (mounted) {
          setState(() {});
        }
      }),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    for (var element in _subscriptions) {
      element.cancel();
    }
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      return;
    }
    _sourceType =
        _tabController.index == 0 ? SourceType.Screen : SourceType.Window;
    _getSources();
  }

  void _onConfirm() {
    Navigator.pop<DesktopCapturerSource>(context, _selectedSource);
  }

  void _onCancel() {
    Navigator.pop<DesktopCapturerSource>(context, null);
  }

  Future<void> _getSources() async {
    try {
      var sources = await desktopCapturer.getSources(types: [_sourceType]);

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        desktopCapturer.updateSources(types: [_sourceType]);
      });

      if (mounted) {
        setState(() {
          _sources.clear();
          for (var element in sources) {
            _sources[element.id] = element;
          }
        });
      }
    } catch (e) {
      log('Error getting sources: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 720,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.screen_share,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Choose what to share',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _onCancel,
                    tooltip: 'Cancel',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Tab Bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.desktop_windows),
                  text: 'Entire Screen',
                ),
                Tab(
                  icon: Icon(Icons.window),
                  text: 'Window',
                ),
              ],
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSourceGrid(SourceType.Screen, 2),
                  _buildSourceGrid(SourceType.Window, 3),
                ],
              ),
            ),

            // Actions
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _onCancel,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _selectedSource != null ? _onConfirm : null,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceGrid(SourceType type, int crossAxisCount) {
    final sources = _sources.entries
        .where((element) => element.value.type == type)
        .map((e) => e.value)
        .toList();

    if (sources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == SourceType.Screen
                  ? Icons.desktop_access_disabled
                  : Icons.window_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(0x56),
            ),
            const SizedBox(height: 16),
            Text(
              type == SourceType.Screen
                  ? 'No screens available'
                  : 'No windows available',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(0x80),
                  ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 16 / 12,
      ),
      itemCount: sources.length,
      itemBuilder: (context, index) {
        final source = sources[index];
        return ThumbnailWidget(
          source: source,
          selected: _selectedSource?.id == source.id,
          onTap: () {
            setState(() {
              _selectedSource = source;
            });
          },
        );
      },
    );
  }
}
