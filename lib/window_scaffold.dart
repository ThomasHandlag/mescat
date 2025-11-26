import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

/// Custom window scaffold for desktop platforms (Windows, macOS, Linux)
/// Provides a custom title bar with window controls and draggable area
class WindowScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final Color? titleBarColor;
  final Color? titleBarTextColor;
  final Color? buttonColor;
  final Color? buttonHoverColor;
  final Color? closeButtonHoverColor;
  final bool showTitle;
  final Widget? leading;
  final List<Widget>? actions;
  final double titleBarHeight;

  const WindowScaffold({
    super.key,
    required this.child,
    this.title,
    this.titleBarColor,
    this.titleBarTextColor,
    this.buttonColor,
    this.buttonHoverColor,
    this.closeButtonHoverColor,
    this.showTitle = true,
    this.leading,
    this.actions,
    this.titleBarHeight = 40,
  });

  @override
  Widget build(BuildContext context) {
    // Only show custom window controls on desktop platforms
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
      return child;
    }

    final theme = Theme.of(context);
    // final effectiveTitleBarColor = titleBarColor ?? theme.primaryColor;
    final effectiveTitleBarTextColor =
        titleBarTextColor ??
        theme.primaryTextTheme.titleLarge?.color ??
        Colors.white;
    final effectiveButtonColor = buttonColor ?? Colors.white.withAlpha(204);
    final effectiveButtonHoverColor =
        buttonHoverColor ?? Colors.white.withAlpha(51);
    final effectiveCloseButtonHoverColor = closeButtonHoverColor ?? Colors.red;

    return Column(
      children: [
        WindowTitleBar(
          height: titleBarHeight,
          backgroundColor:
              titleBarColor ?? const Color.fromARGB(255, 34, 33, 37),
          title: title,
          titleColor: effectiveTitleBarTextColor,
          showTitle: showTitle,
          leading: leading,
          actions: actions,
          buttonColor: effectiveButtonColor,
          buttonHoverColor: effectiveButtonHoverColor,
          closeButtonHoverColor: effectiveCloseButtonHoverColor,
        ),
        Expanded(child: child),
      ],
    );
  }
}

/// Custom title bar widget for the window
class WindowTitleBar extends StatelessWidget {
  final double height;
  final Color backgroundColor;
  final String? title;
  final Color titleColor;
  final bool showTitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Color buttonColor;
  final Color buttonHoverColor;
  final Color closeButtonHoverColor;

  const WindowTitleBar({
    super.key,
    required this.height,
    required this.backgroundColor,
    this.title,
    required this.titleColor,
    required this.showTitle,
    this.leading,
    this.actions,
    required this.buttonColor,
    required this.buttonHoverColor,
    required this.closeButtonHoverColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: backgroundColor,
      child: Row(
        children: [
          // Leading widget (e.g., app icon)
          if (leading != null) leading!,

          // Draggable area with title
          Expanded(
            child: MoveWindow(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: showTitle && title != null
                    ? Text(
                        title!,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),

          // Custom actions
          if (actions != null) ...actions!,

          // Window control buttons
          WindowButtons(
            buttonColor: buttonColor,
            buttonHoverColor: buttonHoverColor,
            closeButtonHoverColor: closeButtonHoverColor,
          ),
        ],
      ),
    );
  }
}

/// Window control buttons (minimize, maximize/restore, close)
class WindowButtons extends StatelessWidget {
  final Color buttonColor;
  final Color buttonHoverColor;
  final Color closeButtonHoverColor;

  const WindowButtons({
    super.key,
    required this.buttonColor,
    required this.buttonHoverColor,
    required this.closeButtonHoverColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(
          colors: WindowButtonColors(
            iconNormal: buttonColor,
            mouseOver: buttonHoverColor,
            iconMouseOver: buttonColor,
          ),
        ),
        MaximizeWindowButton(
          colors: WindowButtonColors(
            iconNormal: buttonColor,
            mouseOver: buttonHoverColor,
            iconMouseOver: buttonColor,
          ),
        ),
        CloseWindowButton(
          colors: WindowButtonColors(
            iconNormal: buttonColor,
            mouseOver: closeButtonHoverColor,
            iconMouseOver: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Custom minimize button
class MinimizeWindowButton extends StatelessWidget {
  final WindowButtonColors colors;
  final VoidCallback? onPressed;

  const MinimizeWindowButton({super.key, required this.colors, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return WindowButton(
      colors: colors,
      iconBuilder: (buttonContext) =>
          MinimizeIcon(color: buttonContext.iconColor),
      onPressed: onPressed ?? () => appWindow.minimize(),
    );
  }
}

/// Custom maximize/restore button
class MaximizeWindowButton extends StatelessWidget {
  final WindowButtonColors colors;
  final VoidCallback? onPressed;

  const MaximizeWindowButton({super.key, required this.colors, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return WindowButton(
      colors: colors,
      iconBuilder: (buttonContext) =>
          MaximizeIcon(color: buttonContext.iconColor),
      onPressed: onPressed ?? () => appWindow.maximizeOrRestore(),
    );
  }
}

/// Custom close button
class CloseWindowButton extends StatelessWidget {
  final WindowButtonColors colors;
  final VoidCallback? onPressed;

  const CloseWindowButton({super.key, required this.colors, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return WindowButton(
      colors: colors,
      iconBuilder: (buttonContext) => CloseIcon(color: buttonContext.iconColor),
      onPressed: onPressed ?? () => appWindow.close(),
    );
  }
}

/// Base window button widget
class WindowButton extends StatefulWidget {
  final WindowButtonColors colors;
  final Widget Function(WindowButtonContext) iconBuilder;
  final VoidCallback? onPressed;

  const WindowButton({
    super.key,
    required this.colors,
    required this.iconBuilder,
    this.onPressed,
  });

  @override
  State<WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<WindowButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 46,
          height: double.infinity,
          color: _isHovering ? widget.colors.mouseOver : widget.colors.normal,
          child: widget.iconBuilder(
            WindowButtonContext(
              backgroundColor: _isHovering
                  ? widget.colors.mouseOver
                  : widget.colors.normal,
              iconColor: _isHovering
                  ? widget.colors.iconMouseOver
                  : widget.colors.iconNormal,
            ),
          ),
        ),
      ),
    );
  }
}

/// Window button colors configuration
class WindowButtonColors {
  final Color normal;
  final Color mouseOver;
  final Color mouseDown;
  final Color iconNormal;
  final Color iconMouseOver;
  final Color iconMouseDown;

  WindowButtonColors({
    this.normal = Colors.transparent,
    required this.mouseOver,
    Color? mouseDown,
    required this.iconNormal,
    required this.iconMouseOver,
    Color? iconMouseDown,
  }) : mouseDown = mouseDown ?? mouseOver,
       iconMouseDown = iconMouseDown ?? iconMouseOver;
}

/// Context for window button icon builders
class WindowButtonContext {
  final Color backgroundColor;
  final Color iconColor;

  WindowButtonContext({required this.backgroundColor, required this.iconColor});
}

/// Minimize icon
class MinimizeIcon extends StatelessWidget {
  final Color color;

  const MinimizeIcon({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(child: Container(width: 10, height: 1, color: color));
  }
}

/// Maximize icon
class MaximizeIcon extends StatelessWidget {
  final Color color;

  const MaximizeIcon({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(border: Border.all(color: color, width: 1)),
      ),
    );
  }
}

/// Close icon
class CloseIcon extends StatelessWidget {
  final Color color;

  const CloseIcon({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 10,
        height: 10,
        child: CustomPaint(painter: _CloseIconPainter(color: color)),
      ),
    );
  }
}

/// Custom painter for close icon (X)
class _CloseIconPainter extends CustomPainter {
  final Color color;

  _CloseIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
