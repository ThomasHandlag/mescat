import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController? controller;

  final InputDecoration? decoration;
  final int? maxLines;
  final double radius;

  const InputField({
    super.key,
    this.controller,
    this.decoration,
    this.maxLines = 1,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(45),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        labelText: decoration?.labelText,
        hintText: decoration?.hintText,
        prefixIcon: decoration?.prefixIcon,
        suffixIcon: decoration?.suffixIcon,
        counter: decoration?.counter,
        counterStyle: decoration?.counterStyle,
      ),
    ),
  );
}
