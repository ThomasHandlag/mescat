import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mescat/shared/widgets/mc_image.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

enum McFileType { video, audio, image, other }

/// Cache manager for media files
class _MediaFileCache {
  // Cache maps event ID to file path
  static final Map<String, String> _audioCache = {};
  static final Map<String, String> _videoCache = {};

  static String? getAudioPath(String eventId) => _audioCache[eventId];
  static String? getVideoPath(String eventId) => _videoCache[eventId];

  static void cacheAudioPath(String eventId, String path) {
    _audioCache[eventId] = path;
  }

  static void cacheVideoPath(String eventId, String path) {
    _videoCache[eventId] = path;
  }

  static Future<void> clearCache() async {
    _audioCache.clear();
    _videoCache.clear();
  }

  static String generateCacheKey(String eventId, String mimeType) {
    final bytes = utf8.encode('$eventId-$mimeType');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

class McFile extends StatefulWidget {
  const McFile({
    super.key,
    required this.event,
    this.width = 300,
    this.height = 200,
  });

  final Event event;
  final double width;
  final double height;

  @override
  State<McFile> createState() => _McFileState();
}

class _McFileState extends State<McFile> {
  Uint8List? _fileData;
  bool _isLoading = true;
  String? _error;
  McFileType _fileType = McFileType.other;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    try {
      final data = await widget.event.downloadAndDecryptAttachment();
      final mimeType = widget.event.attachmentMimetype;

      setState(() {
        _fileData = data.bytes;
        _fileType = _determineFileType(mimeType);
        _isLoading = false;
        _fileName = data.name.split(RegExp(r'[\\/]')).last;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load file: $e';
          _isLoading = false;
        });
      }
    }
  }

  McFileType _determineFileType(String mimeType) {
    if (mimeType.startsWith('video/')) {
      return McFileType.video;
    } else if (mimeType.startsWith('audio/')) {
      return McFileType.audio;
    } else if (mimeType.startsWith('image/')) {
      return McFileType.image;
    }
    return McFileType.other;
  }

  Size _getImageSize(Uint8List data) {
    final decodedImage = Image.memory(data);
    return Size(
      decodedImage.width?.toDouble() ?? widget.width,
      decodedImage.height?.toDouble() ?? widget.height,
    );
  }

  String get fileName {
    if (_fileName != null) return _fileName!;

    _fileName = widget.event.eventId;

    return _fileName!;
  }

  Future<void> _downloadFile() async {
    if (_fileData == null) return;

    try {
      final directory = await getDownloadsDirectory();
      final fileName = _fileName;
      final fileExtension = widget.event.attachmentMimetype.split('/').last;
      final filePath =
          '${directory!.path}/${_fileName?.split(RegExp(r'[\\/]')).last ?? '$fileName.$fileExtension'}';
      final file = File(filePath);
      await file.writeAsBytes(_fileData!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File saved to: $filePath'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _fileData == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Failed to load file',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        _buildFileContent(),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            child: IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: _downloadFile,
              tooltip: 'Download file',
              iconSize: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileContent() {
    return switch (_fileType) {
      McFileType.video => _McVideoPlayerWidget(
        data: _fileData!,
        width: widget.width,
        height: widget.height,
        eventId: widget.event.eventId,
        mimeType: widget.event.attachmentMimetype,
      ),
      McFileType.audio => _McAudioPlayerWidget(
        data: _fileData!,
        fileName: fileName,
        mimeType: widget.event.attachmentMimetype,
        eventId: widget.event.eventId,
      ),
      McFileType.image => _buildPreferedImage(),
      McFileType.other => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_drive_file,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fileName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.event.attachmentMimetype,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    };
  }

  Widget _buildPreferedImage() {
    final size = _getImageSize(_fileData!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: McImage.memory(
        data: _fileData!,
        width: size.width,
        height: size.height,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _McAudioPlayerWidget extends StatefulWidget {
  const _McAudioPlayerWidget({
    required this.data,
    required this.fileName,
    required this.mimeType,
    required this.eventId,
  });

  final Uint8List data;
  final String fileName;
  final String mimeType;
  final String eventId;

  @override
  State<_McAudioPlayerWidget> createState() => _McAudioPlayerWidgetState();
}

class _McAudioPlayerWidgetState extends State<_McAudioPlayerWidget> {
  final audio.AudioPlayer _audioPlayer = audio.AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _cachedFilePath;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == audio.PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    // Check if we have a cached file path
    final cachedPath = _MediaFileCache.getAudioPath(widget.eventId);

    if (cachedPath != null && await File(cachedPath).exists()) {
      // Use cached file
      _cachedFilePath = cachedPath;
      await _audioPlayer.setSource(audio.DeviceFileSource(cachedPath));
    } else {
      // Create new cache file
      final tempDir = await getTemporaryDirectory();
      final extension = _getFileExtension(widget.mimeType);
      final cacheKey = _MediaFileCache.generateCacheKey(
        widget.eventId,
        widget.mimeType,
      );

      // the path should adapt to platform conventions
      final filePath =
          '${tempDir.path}${Platform.pathSeparator}audio_$cacheKey$extension';

      final file = await File(filePath).writeAsBytes(widget.data);
      _cachedFilePath = file.path;
      _MediaFileCache.cacheAudioPath(widget.eventId, file.path);

      await _audioPlayer.setSource(audio.DeviceFileSource(file.path));
    }
  }

  String _getFileExtension(String mimeType) {
    final parts = mimeType.split('/');
    if (parts.length > 1) {
      return '.${parts[1]}';
    }
    return '.mp3';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.audiotrack,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.fileName,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_isPlaying) {
                    _audioPlayer.pause();
                  } else {
                    if (_cachedFilePath != null) {
                      _audioPlayer.play(
                        audio.DeviceFileSource(_cachedFilePath!),
                      );
                    } else {
                      _audioPlayer.play(audio.BytesSource(widget.data));
                    }
                  }
                },
                icon: Icon(
                  _isPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 40,
                ),
                color: Theme.of(context).colorScheme.primary,
              ),
              Expanded(
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHigh,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _McVideoPlayerWidget extends StatefulWidget {
  const _McVideoPlayerWidget({
    required this.data,
    required this.width,
    required this.height,
    required this.eventId,
    required this.mimeType,
  });

  final Uint8List data;
  final double width;
  final double height;
  final String eventId;
  final String mimeType;

  @override
  State<_McVideoPlayerWidget> createState() => _McVideoPlayerWidgetState();
}

class _McVideoPlayerWidgetState extends State<_McVideoPlayerWidget> {
  late final Player player;
  late final VideoController controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);
    _prepareVideo();
  }

  Future<void> _prepareVideo() async {
    try {
      // Check if we have a cached file path
      final cachedPath = _MediaFileCache.getVideoPath(widget.eventId);

      String filePath;
      if (cachedPath != null && await File(cachedPath).exists()) {
        // Use cached file
        filePath = cachedPath;
      } else {
        // Create new cache file
        final tempDir = await getTemporaryDirectory();
        final extension = _getFileExtension(widget.mimeType);
        final cacheKey = _MediaFileCache.generateCacheKey(
          widget.eventId,
          widget.mimeType,
        );
        filePath = '${tempDir.path}/video_$cacheKey$extension';

        final file = await File(filePath).writeAsBytes(widget.data);
        _MediaFileCache.cacheVideoPath(widget.eventId, file.path);
      }

      await player.open(Media(filePath));

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error preparing video: $e');
    }
  }

  String _getFileExtension(String mimeType) {
    final parts = mimeType.split('/');
    if (parts.length > 1) {
      return '.${parts[1]}';
    }
    return '.mp4';
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _isInitialized
            ? Video(controller: controller, controls: MaterialVideoControls)
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
