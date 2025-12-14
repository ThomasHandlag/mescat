import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/shared/util/extensions.dart';
import 'dart:developer' as dev;

class McImage extends StatefulWidget {
  final Uri? uri;
  final Event? event;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool isThumbnail;
  final bool animated;
  final Duration retryDuration;
  final Duration animationDuration;
  final Curve animationCurve;
  final ThumbnailMethod thumbnailMethod;
  final Widget Function(BuildContext context)? placeholder;
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  )?
  errorBuilder;
  final String? cacheKey;
  final Client? client;
  final BorderRadius borderRadius;
  final Uint8List? data;

  const McImage({
    this.uri,
    this.event,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorBuilder,
    this.isThumbnail = true,
    this.animated = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.retryDuration = const Duration(seconds: 2),
    this.animationCurve = Curves.easeInOut,
    this.thumbnailMethod = ThumbnailMethod.scale,
    this.cacheKey,
    this.client,
    this.borderRadius = BorderRadius.zero,
    super.key,
    this.data,
  });

  const McImage.memory({
    required this.data,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorBuilder,
    this.animated = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.borderRadius = BorderRadius.zero,
    this.isThumbnail = true,
    super.key,
  }) : uri = null,
       event = null,
       retryDuration = const Duration(seconds: 2),
       thumbnailMethod = ThumbnailMethod.scale,
       cacheKey = null,
       client = null;

  @override
  State<McImage> createState() => _McImageState();
}

class _McImageState extends State<McImage> {
  static final Map<String, Uint8List> _imageDataCache = {};
  Uint8List? _imageDataNoCache;

  Uint8List? get _imageData => widget.cacheKey == null
      ? _imageDataNoCache
      : _imageDataCache[widget.cacheKey];

  set _imageData(Uint8List? data) {
    if (data == null) return;
    final cacheKey = widget.cacheKey;
    cacheKey == null
        ? _imageDataNoCache = data
        : _imageDataCache[cacheKey] = data;
  }

  Future<void> _load() async {
    if (!mounted) return;
    try {
      final client = getIt<Client>();
      final uri = widget.uri;
      final event = widget.event;

      if (uri != null) {
        final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
        final width = widget.width;
        final realWidth = width == null ? null : width * devicePixelRatio;
        final height = widget.height;
        final realHeight = height == null ? null : height * devicePixelRatio;

        final remoteData = await client.downloadMxcCached(
          uri,
          width: realWidth,
          height: realHeight,
          thumbnailMethod: widget.thumbnailMethod,
          isThumbnail: widget.isThumbnail,
          animated: widget.animated,
        );
        if (!mounted) return;
        setState(() {
          _imageData = remoteData;
        });
      }

      if (event != null) {
        final data = await event.downloadAndDecryptAttachment(
          getThumbnail: widget.isThumbnail,
        );
        if (data.detectFileType is MatrixImageFile || widget.isThumbnail) {
          if (!mounted) return;
          setState(() {
            _imageData = data.bytes;
          });
          return;
        }
      }
    } catch (e, s) {
      dev.log('Unable to load mxc image', error: e, stackTrace: s);
      rethrow;
    }
  }

  void _tryLoad() async {
    if (_imageData != null || widget.data != null) {
      return;
    }
    try {
      await _load();
    } on IOException catch (_) {
      if (!mounted) return;
      await Future.delayed(widget.retryDuration);
      _tryLoad();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryLoad());
  }

  Widget placeholder(BuildContext context) =>
      widget.placeholder?.call(context) ??
      Container(
        width: widget.width,
        height: widget.height,
        alignment: Alignment.center,
      );

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final width = widget.width;
    final realWidth = width == null ? null : width * devicePixelRatio;
    final height = widget.height;
    final realHeight = height == null ? null : height * devicePixelRatio;
    final data = widget.data ?? _imageData;
    final hasData = data != null && data.isNotEmpty;

    return AnimatedSwitcher(
      duration: widget.animationDuration,
      child: hasData
          ? ClipRRect(
              borderRadius: widget.borderRadius,
              child: Image.memory(
                data,
                width: realWidth,
                height: realHeight,
                fit: widget.fit,
                filterQuality: widget.isThumbnail
                    ? FilterQuality.low
                    : FilterQuality.medium,
                errorBuilder:
                    widget.errorBuilder ??
                    (context, e, s) {
                      Logs().d('Unable to render mxc image', e, s);
                      return SizedBox(
                        width: widget.width,
                        height: widget.height,
                        child: Material(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: min(widget.height ?? 64, 64),
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      );
                    },
              ),
            )
          : placeholder(context),
    );
  }
}

extension on MatrixFile {
  MatrixFile get detectFileType {
    if (msgType == MessageTypes.Image) {
      return MatrixImageFile(bytes: bytes, name: name);
    }
    if (msgType == MessageTypes.Video) {
      return MatrixVideoFile(bytes: bytes, name: name);
    }
    if (msgType == MessageTypes.Audio) {
      return MatrixAudioFile(bytes: bytes, name: name);
    }
    return this;
  }
}
