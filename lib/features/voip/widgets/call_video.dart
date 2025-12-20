import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:matrix/matrix.dart';

class CallVideo extends StatefulWidget {
  final WrappedMediaStream? stream;
  final RTCVideoViewObjectFit fit;
  final bool isMirror;

  const CallVideo({
    super.key,
    this.stream,
    this.fit = RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
    this.isMirror = false,
  });

  @override
  State<CallVideo> createState() => _CallVideoState();
}

class _CallVideoState extends State<CallVideo> {
  RTCVideoRenderer? _renderer;
  MediaStream? get mediaStream => widget.stream?.stream;
  StreamSubscription? _streamSub;

  Future<RTCVideoRenderer> _initializeRenderer() async {
    _renderer ??= RTCVideoRenderer();
    await _renderer!.initialize();
    _renderer!.srcObject = mediaStream;
    return _renderer!;
  }

  void disposeRenderer() {
    try {
      _renderer?.srcObject = null;
      _renderer?.dispose();
      _renderer = null;
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  void initState() {
    _streamSub = widget.stream?.onStreamChanged.stream.listen((stream) {
      setState(() {
        _renderer?.srcObject = stream;
      });
    });
    _initializeRenderer();
    super.initState();
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    disposeRenderer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RTCVideoRenderer>(
      key: widget.key,
      future: _initializeRenderer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return RTCVideoView(
            snapshot.data!,
            objectFit: widget.fit,
            mirror: widget.isMirror,
          );
        } else {
          return Container();
        }
      },
    );
  }
}
