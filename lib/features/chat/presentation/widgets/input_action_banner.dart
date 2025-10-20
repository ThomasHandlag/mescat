import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/chat/presentation/blocs/chat_bloc.dart';
import 'package:flutter/material.dart';

class InputActionBanner extends StatelessWidget {
  final InputActionData inputAction;
  final VoidCallback? onCancel;
  const InputActionBanner({
    super.key,
    required this.inputAction,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    String actionText = '';
    switch (inputAction.action) {
      case InputAction.reply:
        actionText = 'Replying to message: ${inputAction.initialContent ?? ''}';
        break;
      case InputAction.edit:
        actionText = 'Editing message: ${inputAction.initialContent ?? ''}';
        break;
      default:
        actionText = '';
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              actionText,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              context.read<ChatBloc>().add(
                const SetInputAction(action: InputAction.none),
              );
              onCancel?.call();
            },
            child: Icon(
              Icons.close,
              size: 16,
              color: colorScheme.onSurface.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }
}
