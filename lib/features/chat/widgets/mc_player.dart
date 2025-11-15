import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';

class McPlayer extends StatefulWidget {
  const McPlayer({super.key, required this.data});
  final Uint8List data;

  @override
  State<McPlayer> createState() => _McPlayerState();
}

class _McPlayerState extends State<McPlayer> {
  final audio.AudioPlayer _audioPlayer = audio.AudioPlayer();

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == audio.PlayerState.playing;
        });
      }
    });
    _audioPlayer.setSourceBytes(widget.data);
  }

  bool isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.audiotrack, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text('Audio message', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              if (isPlaying) {
                _audioPlayer.pause();
              } else {
                _audioPlayer.play(audio.BytesSource(widget.data));
              }
            },
            icon: isPlaying
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
          ),
        ],
      ),
    );
  }
}

class McVideoPlayer extends StatefulWidget {
  const McVideoPlayer({super.key, required this.data});
  final Uint8List data;

  @override
  State<McVideoPlayer> createState() => _McVideoPlayerState();
}

class _McVideoPlayerState extends State<McVideoPlayer> {
  late final player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    _prepareVideo();
  }

  void _prepareVideo() async {
    final tempDir = await getTemporaryDirectory();
    final file = await File(
      '${tempDir.path}/temp_video.mp4',
    ).writeAsBytes(widget.data);
    await player.open(Media(file.path));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Video(controller: controller),
    );
  }
}
