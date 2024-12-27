import 'package:flutter/material.dart';
import '/core/utils/extension/context_ext.dart';

class PermissionDialog extends StatelessWidget {
  final String? title;
  final String? content;
  final VoidCallback onOk;

  const PermissionDialog({
    super.key,
    this.title,
    this.content,
    required this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.theme.colorScheme.surface,
      title: Text(
        title ?? '',
        style: context.textTheme.titleLarge,
      ),
      content: Text(
        content ?? '',
        style: context.textTheme.titleMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: context.textTheme.titleMedium,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onOk();
            Navigator.pop(context);
          },
          child: Text(
            'OK',
            style: context.textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}
