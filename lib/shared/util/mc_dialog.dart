import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mescat/core/constants/app_constants.dart';
import 'package:mescat/window_scaffold.dart';

void showImageDialog(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    fullscreenDialog: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(child: Image.file(File(imageUrl))),
        ),
      );
    },
  );
}

void showFullscreenDialog(BuildContext context, Widget child) {
  showDialog(
    context: context,
    fullscreenDialog: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Platform.isAndroid || Platform.isIOS
            ? child
            : WindowScaffold(child: child),
      );
    },
  );
}

enum OkCancelResult { ok, cancel }

Future<OkCancelResult?> showOkAlertDialog({
  required BuildContext context,
  required String title,
  String? message,
  String? okLabel,
  bool useRootNavigator = true,
}) => showAdaptiveDialog<OkCancelResult>(
  context: context,
  useRootNavigator: useRootNavigator,
  builder: (context) => AlertDialog.adaptive(
    title: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 256),
      child: Text(title),
    ),
    content: message != null
        ? ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 256),
            child: Text(message),
          )
        : null,
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(OkCancelResult.ok),
        child: Text(okLabel ?? 'OK'),
      ),
    ],
  ),
);

Future<T?> showMCAdaptiveDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool useRootNavigator = true,
  Widget? title,
  List<Widget>? actions,
}) {
  final screenSize = MediaQuery.of(context).size;
  final isMobile = Platform.isAndroid || Platform.isIOS;
  final isSmallScreen = screenSize.width < 600;

  final computeSize = isMobile || isSmallScreen
      ? Size(screenSize.width * 0.9, screenSize.height * 0.4)
      : Size(screenSize.width * 0.5, screenSize.height * 0.5);

  return showDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      return Dialog(
        constraints: BoxConstraints.tight(computeSize),
        child: Container(
          padding: const EdgeInsets.all(UIConstraints.mDefaultPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(0x33),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            borderRadius: BorderRadius.circular(UIConstraints.mDefaultPadding),
          ),
          child: Scaffold(
            appBar: title != null
                ? AppBar(automaticallyImplyLeading: false, title: title)
                : null,
            body: Column(
              children: [
                Expanded(child: builder(context)),
                if (actions != null) Row(children: actions),
              ],
            ),
          ),
        ),
      );
    },
  );
}
