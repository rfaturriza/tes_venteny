import 'package:flutter/material.dart';
import '/core/utils/extension/context_ext.dart';

class ErrorScreen extends StatelessWidget {
  final String? message;
  final void Function()? onRefresh;

  const ErrorScreen({
    super.key,
    required this.message,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            message ?? '',
            textAlign: TextAlign.center,
            style: context.textTheme.headlineSmall?.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          // icon Refresh
          if (onRefresh != null) ...[
            TextButton.icon(
              label: Text(
                'Try Again',
                style: context.textTheme.labelMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
              onPressed: onRefresh,
              icon: const Icon(
                Icons.refresh,
                color: Colors.grey,
                size: 16,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
