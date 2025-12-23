import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController? controller;

  final InputDecoration? decoration;
  final int? maxLines;
  final double radius;
  final int? maxLength;
  final String? Function(String value)? validator;
  final bool enabled;
  final EdgeInsetsGeometry? padding;
  final TextAlign? textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool expands;
  final int? minLines;

  const InputField({
    super.key,
    this.controller,
    this.decoration,
    this.maxLines = 1,
    this.radius = 8,
    this.maxLength,
    this.validator,
    this.enabled = true,
    this.padding,
    this.textAlign,
    this.textAlignVertical,
    this.expands = false,
    this.minLines,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: padding ?? const EdgeInsets.symmetric(vertical: 4),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(90),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      expands: expands,
      minLines: minLines,
      enabled: enabled,
      textAlign: textAlign ?? TextAlign.start,
      textAlignVertical: textAlignVertical ?? TextAlignVertical.center,
      validator: (value) {
        if (validator != null && value != null) {
          return validator!(value);
        }
        return null;
      },
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        // isCollapsed: true,
        labelText: decoration?.labelText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: decoration?.hintText,
        prefixIcon: decoration?.prefixIcon,
        suffixIcon: decoration?.suffixIcon,
        counter: decoration?.counter,
        counterStyle: decoration?.counterStyle,
        alignLabelWithHint: true
      ),
    ),
  );
}
