import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mescat/shared/util/mc_dialog.dart';
import 'package:mescat/shared/widgets/mc_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:mescat/shared/util/string_util.dart';

class YoutubeDialog extends StatefulWidget {
  final YoutubePlayerController controller;
  final String message;
  final String? displayName;
  final Uri? avatarUrl;
  const YoutubeDialog({
    super.key,
    required this.controller,
    required this.message,
    this.displayName,
    this.avatarUrl,
  });

  @override
  State<YoutubeDialog> createState() => _YoutubeDialogState();
}

class _YoutubeDialogState extends State<YoutubeDialog> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          setState(() {
            _isVisible = !_isVisible;
          });
        },
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              Center(
                child: YoutubePlayerBuilder(
                  onExitFullScreen: () {
                    SystemChrome.setPreferredOrientations(
                      DeviceOrientation.values,
                    );
                  },
                  onEnterFullScreen: () {
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.landscapeLeft,
                      DeviceOrientation.landscapeRight,
                    ]);
                  },
                  player: YoutubePlayer(
                    controller: widget.controller,
                    bottomActions: const [
                      CurrentPosition(),
                      ProgressBar(isExpanded: true),
                      RemainingDuration(),
                      FullScreenButton(),
                    ],
                  ),
                  builder: (context, player) => player,
                ),
              ),
              if (_isVisible) ...[
                Align(
                  alignment: Alignment.topLeft,
                  child: SafeArea(
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.avatarUrl != null)
                          CircleAvatar(child: McImage(uri: widget.avatarUrl!))
                        else
                          CircleAvatar(
                            child: Text(getInitials(widget.displayName ?? '')),
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.displayName != null)
                                Text(
                                  widget.displayName!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              Text(
                                widget.message,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class YoutubeWebview extends StatefulWidget {
  final String videoUrl;
  final Size videoSize;
  final String message;
  final String? displayName;
  final Uri? avatarUrl;

  const YoutubeWebview({
    super.key,
    required this.videoUrl,
    this.videoSize = const Size(300, 200),
    required this.message,
    this.displayName,
    this.avatarUrl,
  });

  @override
  State<YoutubeWebview> createState() => _YoutubeWebviewState();
}

class _YoutubeWebviewState extends State<YoutubeWebview> {
  late YoutubePlayerController _controller;

  String getId(String youtubeUrl) {
    final uri = Uri.parse(youtubeUrl);

    // Case 1: Normal YouTube link: https://www.youtube.com/watch?v=VIDEO_ID
    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v']!;
    }

    // Case 2: Shortened youtu.be link: https://youtu.be/VIDEO_ID?si=...
    if (uri.host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }

    return youtubeUrl;
  }

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.videoSize.width,
      height: widget.videoSize.height + 24,
      child: Stack(
        children: [
          Column(
            children: [
              Text(
                _controller.metadata.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Image.network(
                YoutubePlayer.getThumbnail(
                  videoId: getId(widget.videoUrl),
                  quality: ThumbnailQuality.medium,
                ),
                width: widget.videoSize.width,
                height: widget.videoSize.height,
                fit: BoxFit.cover,
              ),
            ],
          ),
          Container(color: Colors.black26),
          Align(
            alignment: Alignment.center,
            child: IconButton(
              iconSize: 48,
              color: Colors.white70,
              icon: const Icon(Icons.play_circle_outline),
              onPressed: () {
                _showVideoDialog();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showVideoDialog() {
    showFullscreenDialog(
      context,
      YoutubeDialog(
        controller: _controller,
        message: widget.message,
        displayName: widget.displayName,
        avatarUrl: widget.avatarUrl,
      ),
    );
  }
}
