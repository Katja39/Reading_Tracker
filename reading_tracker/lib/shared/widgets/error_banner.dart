// Shared error banner for error messages



import 'package:flutter/material.dart';

// Displays an error message using the active error color scheme
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
  });

  final String message;

  // Builds a themed error container around the message text
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: TextStyle(
            color: theme.colorScheme.onErrorContainer,
          ),
        ),
      ),
    );
  }
}
