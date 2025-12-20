import 'package:flutter/material.dart';

class DraggableOverlay extends StatefulWidget {
  final Offset position;
  final Size size;
  final ValueChanged<Offset> onPositionChanged;
  final VoidCallback? onClose;
  final VoidCallback? onExpand;
  final Widget child;
  final bool draggable;

  const DraggableOverlay({
    super.key,
    required this.position,
    required this.size,
    required this.onPositionChanged,
    this.onClose,
    this.onExpand,
    required this.child,
    this.draggable = true,
  });

  @override
  State<DraggableOverlay> createState() => _DraggableOverlayState();
}

class _DraggableOverlayState extends State<DraggableOverlay> {
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

    final content = Material(
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
                        icon: const Icon(Icons.fullscreen, size: 20),
                        onPressed: widget.onExpand,
                        tooltip: 'Expand',
                      ),
                  ],
                ),
              ),
            ),
            // Drag indicator
            if (widget.draggable)
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
                  child: const Icon(Icons.drag_indicator, size: 16, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );

    return Positioned(
      left: _currentPosition.dx.clamp(0, screenSize.width - widget.size.width),
      top: _currentPosition.dy.clamp(0, screenSize.height - widget.size.height),
      child: widget.draggable
          ? GestureDetector(
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
              child: content,
            )
          : content,
    );
  }
}
