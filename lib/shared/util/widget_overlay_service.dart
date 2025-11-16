import 'package:flutter/material.dart';
import 'package:mescat/core/constants/app_constants.dart';

/// Overlay service for managing multiple overlay types
class WidgetOverlayService {
  static final Map<String, OverlayEntry> _overlays = {};
  static final Map<String, Offset> _positions = {};
  static final Map<String, Size> _sizes = {};

  /// Shows a draggable overlay widget on top of all screens
  static void show(
    BuildContext context, {
    String? id,
    required Widget child,
    VoidCallback? onClose,
    VoidCallback? onExpand,
    Size? initialSize,
    Offset? initialPosition,
    bool draggable = true,
  }) {
    final overlayId = id ?? 'default';
    if (_overlays.containsKey(overlayId)) return;

    final size = initialSize ?? const Size(320, 180);
    final position = initialPosition ?? const Offset(20, 100);

    _sizes[overlayId] = size;
    _positions[overlayId] = position;

    final overlayEntry = OverlayEntry(
      builder: (context) => _DraggableOverlay(
        position: position,
        size: size,
        draggable: draggable,
        onPositionChanged: (newPosition) {
          _positions[overlayId] = newPosition;
        },
        onClose: () {
          hide(overlayId);
          onClose?.call();
        },
        onExpand: onExpand,
        child: child,
      ),
    );

    _overlays[overlayId] = overlayEntry;
    Overlay.of(context).insert(overlayEntry);
  }

  /// Shows a centered modal overlay (non-draggable)
  static void showModal(
    BuildContext context, {
    String? id,
    required Widget child,
    VoidCallback? onClose,
    bool barrierDismissible = true,
    Color? barrierColor,
    Size? size,
  }) {
    final overlayId = id ?? 'modal';
    if (_overlays.containsKey(overlayId)) return;

    final overlayEntry = OverlayEntry(
      builder: (context) => _ModalOverlay(
        onClose: () {
          hide(overlayId);
          onClose?.call();
        },
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor ?? Colors.black.withAlpha(128),
        size: size,
        child: child,
      ),
    );

    _overlays[overlayId] = overlayEntry;
    Overlay.of(context).insert(overlayEntry);
  }

  /// Shows a snackbar-style notification at the bottom
  static void showSnackbar(
    BuildContext context, {
    String? id,
    required String message,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    VoidCallback? onTap,
    bool dismissible = true,
  }) {
    final overlayId = id ?? 'snackbar_${DateTime.now().millisecondsSinceEpoch}';
    if (_overlays.containsKey(overlayId)) return;

    final overlayEntry = OverlayEntry(
      builder: (context) => _SnackbarOverlay(
        message: message,
        backgroundColor: backgroundColor,
        textColor: textColor,
        icon: icon,
        onTap: onTap,
      ),
    );

    _overlays[overlayId] = overlayEntry;
    Overlay.of(context).insert(overlayEntry);

    if (dismissible) {
      Future.delayed(duration, () => hide(overlayId));
    }
  }

  /// Shows a loading overlay
  static void showLoading(
    BuildContext context, {
    String? id,
    String? message,
    bool barrierDismissible = false,
  }) {
    final overlayId = id ?? 'loading';
    if (_overlays.containsKey(overlayId)) return;

    final overlayEntry = OverlayEntry(
      builder: (context) => _LoadingOverlay(
        message: message,
        barrierDismissible: barrierDismissible,
        onDismiss: () => hide(overlayId),
      ),
    );

    _overlays[overlayId] = overlayEntry;
    Overlay.of(context).insert(overlayEntry);
  }

  /// Shows a tooltip-style overlay at a specific position
  static void showTooltip(
    BuildContext context, {
    String? id,
    required Widget child,
    required Offset position,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlayId = id ?? 'tooltip_${DateTime.now().millisecondsSinceEpoch}';
    if (_overlays.containsKey(overlayId)) return;

    final overlayEntry = OverlayEntry(
      builder: (context) => _TooltipOverlay(position: position, child: child),
    );

    _overlays[overlayId] = overlayEntry;
    Overlay.of(context).insert(overlayEntry);

    Future.delayed(duration, () => hide(overlayId));
  }

  /// Shows a bottom sheet overlay
  static void showBottomSheet(
    BuildContext context, {
    String? id,
    required Widget child,
    VoidCallback? onClose,
    bool isDismissible = true,
    double? height,
  }) {
    final overlayId = id ?? 'bottom_sheet';
    if (_overlays.containsKey(overlayId)) return;

    final overlayEntry = OverlayEntry(
      builder: (context) => _BottomSheetOverlay(
        onClose: () {
          hide(overlayId);
          onClose?.call();
        },
        isDismissible: isDismissible,
        height: height,
        child: child,
      ),
    );

    _overlays[overlayId] = overlayEntry;
    Overlay.of(context).insert(overlayEntry);
  }

  /// Hides a specific overlay by ID, or the default overlay if no ID provided
  static void hide([String? id]) {
    final overlayId = id ?? 'default';
    _overlays[overlayId]?.remove();
    _overlays.remove(overlayId);
    _positions.remove(overlayId);
    _sizes.remove(overlayId);
  }

  /// Hides all overlays
  static void hideAll() {
    for (final entry in _overlays.values) {
      entry.remove();
    }
    _overlays.clear();
    _positions.clear();
    _sizes.clear();
  }

  /// Checks if a specific overlay is showing
  static bool isShowing([String? id]) {
    final overlayId = id ?? 'default';
    return _overlays.containsKey(overlayId);
  }

  /// Gets all active overlay IDs
  static List<String> get activeOverlays => _overlays.keys.toList();

  /// Updates the position of a specific overlay
  static void updatePosition(String id, Offset newPosition) {
    _positions[id] = newPosition;
    _overlays[id]?.markNeedsBuild();
  }
}

class _DraggableOverlay extends StatefulWidget {
  final Offset position;
  final Size size;
  final ValueChanged<Offset> onPositionChanged;
  final VoidCallback? onClose;
  final VoidCallback? onExpand;
  final Widget child;
  final bool draggable;

  const _DraggableOverlay({
    required this.position,
    required this.size,
    required this.onPositionChanged,
    this.onClose,
    this.onExpand,
    required this.child,
    this.draggable = true,
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

// Modal Overlay
class _ModalOverlay extends StatelessWidget {
  final VoidCallback onClose;
  final bool barrierDismissible;
  final Color barrierColor;
  final Size? size;
  final Widget child;

  const _ModalOverlay({
    required this.onClose,
    required this.barrierDismissible,
    required this.barrierColor,
    this.size,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Barrier
        Positioned.fill(
          child: GestureDetector(
            onTap: barrierDismissible ? onClose : null,
            child: Container(color: barrierColor),
          ),
        ),
        // Content
        Center(
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: size?.width,
              height: size?.height,
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

// Snackbar Overlay
class _SnackbarOverlay extends StatefulWidget {
  final String message;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final VoidCallback? onTap;

  const _SnackbarOverlay({
    required this.message,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.onTap,
  });

  @override
  State<_SnackbarOverlay> createState() => _SnackbarOverlayState();
}

class _SnackbarOverlayState extends State<_SnackbarOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16 + UIConstraints.mMessageInputHeight,
      left: 16 + UIConstraints.mSpaceSidebar,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    widget.backgroundColor ??
                    Theme.of(context).colorScheme.inverseSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color:
                          widget.textColor ??
                          Theme.of(context).colorScheme.onInverseSurface,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color:
                            widget.textColor ??
                            Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Loading Overlay
class _LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool barrierDismissible;
  final VoidCallback onDismiss;

  const _LoadingOverlay({
    this.message,
    required this.barrierDismissible,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: barrierDismissible ? onDismiss : null,
            child: Container(color: Colors.black.withAlpha(128)),
          ),
        ),
        Center(
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Tooltip Overlay
class _TooltipOverlay extends StatelessWidget {
  final Offset position;
  final Widget child;

  const _TooltipOverlay({required this.position, required this.child});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inverseSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
              fontSize: 12,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// Bottom Sheet Overlay
class _BottomSheetOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final bool isDismissible;
  final double? height;
  final Widget child;

  const _BottomSheetOverlay({
    required this.onClose,
    required this.isDismissible,
    this.height,
    required this.child,
  });

  @override
  State<_BottomSheetOverlay> createState() => _BottomSheetOverlayState();
}

class _BottomSheetOverlayState extends State<_BottomSheetOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final sheetHeight = widget.height ?? screenHeight * 0.5;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.isDismissible ? widget.onClose : null,
            child: Container(color: Colors.black.withAlpha(128)),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: _slideAnimation,
            child: Material(
              elevation: 16,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                height: sheetHeight,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(77),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
