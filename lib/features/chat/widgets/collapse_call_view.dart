import 'package:flutter/material.dart';

class CollapseCallView extends StatelessWidget {
  const CollapseCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(8.0),
    );
  }
}
