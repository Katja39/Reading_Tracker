//
// Shared progress summary with a bar, label, and update button
//


import 'package:flutter/material.dart';

import '../../../../shared/theme/app_tokens.dart';

// Renders reading progress consistently across detail and home screens
class ReadingProgressSummary extends StatelessWidget {
  const ReadingProgressSummary({
    super.key,
    required this.currentPage,
    required this.pages,
    required this.onUpdatePressed,
    this.compact = false,
    this.fillWidth = false,
    this.minBarWidth = AppSizes.progressMinWidth,
    this.maxBarWidth = AppSizes.progressMaxWidth,
  });

  final int? currentPage;
  final int? pages;
  final VoidCallback? onUpdatePressed;
  final bool compact;
  final bool fillWidth;
  final double minBarWidth;
  final double maxBarWidth;

  // Whether a determinate percentage can be calculated
  bool get _hasTotalPages {
    return pages != null && pages! > 0;
  }

  // Converts page progress into a clamped progress-bar value
  double get _progressValue {
    final current = currentPage;
    final total = pages;
    if (current == null || total == null || total <= 0) {
      return 0.0;
    }

    return (current / total).clamp(0.0, 1.0).toDouble();
  }

  // Builds the percentage label or missing-pages fallback
  String get _progressText {
    if (!_hasTotalPages) {
      return 'Pages missing';
    }

    return '${(_progressValue * 100).round()}%';
  }

  // Uses shared button dimensions for compact and regular variants
  ButtonStyle _buttonStyle() {
    return FilledButton.styleFrom(
      minimumSize: Size(
        0,
        compact ? AppSizes.compactButtonHeight : AppSizes.buttonHeight,
      ),
      padding: compact ? AppInsets.compactButton : AppInsets.button,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
    );
  }

  // Applies either full-width or constrained sizing to each row
  Widget _widthBox({required Widget child}) {
    if (fillWidth) {
      return SizedBox(width: double.infinity, child: child);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minBarWidth,
        maxWidth: maxBarWidth,
      ),
      child: child,
    );
  }

  // Builds the progress bar, page label, and update action
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pageText = 'Page ${currentPage?.toString() ?? '-'}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: fillWidth
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.start,
      children: [
        _widthBox(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: _hasTotalPages ? _progressValue : 0.0,
              minHeight: compact ? 5 : 7,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        SizedBox(height: compact ? AppSpacing.xs : 6),
        _widthBox(
          child: Text(
            '$pageText | $_progressText',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (compact
                    ? theme.textTheme.labelSmall
                    : theme.textTheme.labelMedium)
                ?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(height: compact ? 6 : AppSpacing.sm),
        _widthBox(
          child: FilledButton.tonal(
            onPressed: onUpdatePressed,
            style: _buttonStyle(),
            child: const Text('Update'),
          ),
        ),
      ],
    );
  }
}