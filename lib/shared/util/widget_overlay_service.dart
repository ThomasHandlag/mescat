import 'package:flutter/material.dart';

class WidgetOverlayService {
  static OverlayEntry? _overlayEntry;
  static Offset _position = const Offset(20, 100);
  static Size _size = const Size(320, 180);

  /// Shows a draggable overlay widget on top of all screens
  static void show(
    BuildContext context, {
    required Widget child,
    VoidCallback? onClose,
    VoidCallback? onExpand,
    Size? initialSize,
    Offset? initialPosition,
  }) {
    if (_overlayEntry != null) return;

    _size = initialSize ?? _size;
    _position = initialPosition ?? _position;

    _overlayEntry = OverlayEntry(
      builder: (context) => _DraggableOverlay(
        position: _position,
        size: _size,
        onPositionChanged: (newPosition) {
          _position = newPosition;
        },
        onClose: () {
          hide();
          onClose?.call();
        },
        onExpand: onExpand,
        child: child,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Hides the overlay widget
  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Checks if overlay is currently showing
  static bool get isShowing => _overlayEntry != null;

  /// Updates the overlay position
  static void updatePosition(Offset newPosition) {
    _position = newPosition;
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }
}

class _DraggableOverlay extends StatefulWidget {
  final Offset position;
  final Size size;
  final ValueChanged<Offset> onPositionChanged;
  final VoidCallback? onClose;
  final VoidCallback? onExpand;
  final Widget child;

  const _DraggableOverlay({
    required this.position,
    required this.size,
    required this.onPositionChanged,
    this.onClose,
    this.onExpand,
    required this.child,
  });

  @override
  State<_DraggableOverlay> createState() => _DraggableOverlayState();
}

class _DraggableOverlayState extends State<_DraggableOverlay> {
  late Offset _currentPosition;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.position;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      left: _currentPosition.dx.clamp(0, screenSize.width - widget.size.width),
      top: _currentPosition.dy.clamp(0, screenSize.height - widget.size.height),
      child: GestureDetector(
        onPanStart: (details) {
          setState(() => _isDragging = true);
        },
        onPanUpdate: (details) {
          setState(() {
            _currentPosition += details.delta;
          });
        },
        onPanEnd: (details) {
          setState(() => _isDragging = false);
          widget.onPositionChanged(_currentPosition);
        },
        onDoubleTap: widget.onExpand,
        child: Material(
          elevation: _isDragging ? 16 : 8,
          borderRadius: BorderRadius.circular(12),
          shadowColor: Colors.black.withAlpha(100),
          child: Container(
            width: widget.size.width,
            height: widget.size.height,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withAlpha(51),
              ),
            ),
            child: Stack(
              children: [
                // Content
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: widget.child,
                ),
                // Control buttons
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(128),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.onExpand != null)
                          IconButton(
                            icon: const Icon(
                              Icons.fullscreen,
                              size: 20,
                              color: Colors.white,
                            ),
                            onPressed: widget.onExpand,
                            tooltip: 'Expand',
                          ),
                        if (widget.onClose != null)
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.white,
                            ),
                            onPressed: widget.onClose,
                            tooltip: 'Close',
                          ),
                      ],
                    ),
                  ),
                ),
                // Drag indicator
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(128),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.drag_indicator,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
