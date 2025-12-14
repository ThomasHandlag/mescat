import 'dart:io';

import 'package:flutter/material.dart';
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

Future<T?> showAdaptiveDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool useRootNavigator = true,
}) {
  return showDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      return builder(context);
    },
  );
}
