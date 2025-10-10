import 'dart:io';

import 'package:flutter/material.dart';

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
