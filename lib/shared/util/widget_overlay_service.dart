import 'package:flutter/widgets.dart';
import 'package:mescat/shared/util/draggable_overlay.dart';

/// Overlay service for managing multiple overlay types
class WidgetOverlayService extends InheritedWidget {
  static final Map<String, OverlayEntry> _overlays = {};
  static final Map<String, Offset> _positions = {};
  static final Map<String, Size> _sizes = {};

  final BuildContext appContext;

  const WidgetOverlayService({
    super.key,
    required super.child,
    required this.appContext,
  });

  static WidgetOverlayService of(BuildContext context) {
    final service = context
        .dependOnInheritedWidgetOfExactType<WidgetOverlayService>();
    if (service == null) {
      throw Exception(
        'WidgetOverlayService not found in widget tree. Please wrap your app with WidgetOverlayService.',
      );
    }
    return service;
  }

  @override
  bool updateShouldNotify(covariant WidgetOverlayService oldWidget) {
    return appContext != oldWidget.appContext;
  }

  /// Shows a draggable overlay widget on top of all screens
  void show({
    String? id,
    required Widget child,
    VoidCallback? onClose,
    Function(BuildContext overlayContext)? onExpand,
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
      builder: (context) => DraggableOverlay(
        position: position,
        size: size,
        draggable: draggable,
        onPositionChanged: (newPosition) {
          _positions[overlayId] = newPosition;
        },
        onClose: onClose,
        onExpand: onExpand != null ? () => onExpand(context) : null,
        child: child,
      ),
    );

    _overlays[overlayId] = overlayEntry;
    Overlay.of(appContext).insert(overlayEntry);
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
