//
// Detail page widgets for rows, sections, header rating, status, and reading progress
//


part of 'book_detail_page.dart';

// Displays a simple label/value pair inside a detail section
class _BookDetailRow extends StatelessWidget {
  const _BookDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

// Displays long text in a trimmed form
class _ExpandableBookDetailRow extends StatefulWidget {
  const _ExpandableBookDetailRow({
    required this.label,
    required this.value,
    this.trimLength = 180,
  });

  final String label;
  final String value;
  final int trimLength;

  @override
  State<_ExpandableBookDetailRow> createState() =>
      _ExpandableBookDetailRowState();
}

class _ExpandableBookDetailRowState extends State<_ExpandableBookDetailRow> {
  bool _isExpanded = false;


  String get _trimmedValue {
    return widget.value.trim();
  }


  bool get _canToggle {
    return _trimmedValue.length > widget.trimLength;
  }


  String get _visibleValue {
    if (_isExpanded || !_canToggle) {
      return _trimmedValue;
    }

    return '${_trimmedValue.substring(0, widget.trimLength).trimRight()}...';
  }

  // Switch between trimmed and expanded description text
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(_visibleValue, style: theme.textTheme.bodyLarge),
        if (_canToggle) ...[
          const SizedBox(height: 4),
          TextButton(
            onPressed: _toggleExpanded,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(_isExpanded ? 'less' : 'more'),
          ),
        ],
      ],
    );
  }
}

// Groups related detail rows and adapts them into one or two columns
class _BookDetailSection extends StatelessWidget {
  const _BookDetailSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 16.0;
            final useColumns = constraints.maxWidth >= 640;
            final itemWidth = useColumns
                ? (constraints.maxWidth - spacing) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: spacing,
              runSpacing: 12,
              children: children
                  .map(
                    (child) => SizedBox(
                      width: itemWidth,
                      child: child,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

// Renders the tappable star rating shown in the book header
class _BookHeaderRating extends StatelessWidget {
  const _BookHeaderRating({required this.rating, required this.onTap});

  final double? rating;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveRating = (rating ?? 0).clamp(0, 5);
    final fullStars = effectiveRating.floor();
    final hasHalfStar = effectiveRating - fullStars >= 0.5;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final icon = switch (index) {
              _ when index < fullStars => Icons.star,
              _ when index == fullStars && hasHalfStar => Icons.star_half,
              _ => Icons.star_border,
            };

            return Icon(icon, color: theme.colorScheme.primary, size: 22);
          }),
        ),
      ),
    );
  }
}

// Combines the shared progress summary with the 'latest update history' button
class _BookReadingProgress extends StatelessWidget {
  const _BookReadingProgress({
    required this.currentPage,
    required this.pages,
    required this.progressFuture,
    required this.onUpdatePressed,
    required this.onHistoryPressed,
  });

  final int? currentPage;
  final int? pages;
  final Future<List<ReadingProgressEntry>> progressFuture;
  final VoidCallback? onUpdatePressed;
  final VoidCallback? onHistoryPressed;

  // Compares progress dates with a string fallback
  int _compareProgressDates(String a, String b) {
    final dateA = DateTime.tryParse(a);
    final dateB = DateTime.tryParse(b);
    if (dateA != null && dateB != null) {
      return dateA.compareTo(dateB);
    }
    return a.compareTo(b);
  }

  // Finds the chronologically latest progress entry regardless of list order
  ReadingProgressEntry? _latestProgressEntry(
    List<ReadingProgressEntry> entries,
  ) {
    ReadingProgressEntry? latest;
    for (final entry in entries) {
      if (latest == null ||
          _compareProgressDates(entry.progressDate, latest.progressDate) > 0) {
        latest = entry;
      }
    }
    return latest;
  }

  // Formats backend dates for display
  String _formatDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) {
      return value;
    }
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }

  // Builds the history button label from loading, error, empty, or latest states
  String _latestUpdateText(
    AsyncSnapshot<List<ReadingProgressEntry>> snapshot,
    ReadingProgressEntry? latestEntry,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
      return 'Last update: Loading...';
    }
    if (snapshot.hasError) {
      return 'Last update: Error';
    }
    if (latestEntry == null) {
      return 'Last update: Empty';
    }

    return 'Last update: ${_formatDate(latestEntry.progressDate)}';
  }

  // Style history button
  ButtonStyle _historyButtonStyle(ThemeData theme) {
    return FilledButton.styleFrom(
      foregroundColor: theme.colorScheme.onPrimaryContainer,
      backgroundColor: theme.colorScheme.primaryContainer,
      minimumSize: const Size(0, AppSizes.buttonHeight),
      padding: AppInsets.button,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<ReadingProgressEntry>>(
      future: progressFuture,
      builder: (context, snapshot) {
        final entries = snapshot.data;
        final latestEntry = entries == null ? null : _latestProgressEntry(entries);
        final effectiveCurrentPage = currentPage ?? latestEntry?.pageNumber;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: AppSizes.detailProgressWidth,
              child: ReadingProgressSummary(
                currentPage: effectiveCurrentPage,
                pages: pages,
                onUpdatePressed: onUpdatePressed,
                fillWidth: true,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: AppSizes.detailProgressWidth,
              child: FilledButton.tonalIcon(
                onPressed: onHistoryPressed,
                icon: const Icon(Icons.history, size: 16),
                label: Text(
                  _latestUpdateText(snapshot, latestEntry),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                style: _historyButtonStyle(theme),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Shows the current reading status as a tappable tonal button
class _BookStatusButton extends StatelessWidget {
  const _BookStatusButton({
    required this.status,
    required this.onPressed,
  });

  final String status;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        backgroundColor: theme.colorScheme.primaryContainer,
        minimumSize: const Size(0, AppSizes.buttonHeight),
        padding: AppInsets.button,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      child: Text(status),
    );
  }
}
