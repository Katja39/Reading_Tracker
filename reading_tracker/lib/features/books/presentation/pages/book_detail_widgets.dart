part of 'book_detail_page.dart';

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
      borderRadius: BorderRadius.circular(8),
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

class _UpdateCurrentPageDialogResult {
  const _UpdateCurrentPageDialogResult({
    required this.pageNumber,
    required this.progressDate,
  });

  final int? pageNumber;
  final String progressDate;
}

class _UpdateCurrentPageDialog extends StatefulWidget {
  const _UpdateCurrentPageDialog({
    required this.initialPage,
    required this.totalPages,
    this.initialProgressDate,
  });

  final int? initialPage;
  final int? totalPages;
  final String? initialProgressDate;

  @override
  State<_UpdateCurrentPageDialog> createState() =>
      _UpdateCurrentPageDialogState();
}

class _UpdateCurrentPageDialogState extends State<_UpdateCurrentPageDialog> {
  late final TextEditingController _controller;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialPage?.toString() ?? '',
    );
    final now = DateTime.now();
    final parsedDate = widget.initialProgressDate == null
        ? null
        : DateTime.tryParse(widget.initialProgressDate!);
    _selectedDate = parsedDate == null
        ? DateTime(now.year, now.month, now.day)
        : DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _dateIsoString(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    return '$day.$month.$year';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1970),
      lastDate: today,
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
      );
    });
  }

  void _submit() {
    final page = int.tryParse(_controller.text.trim());
    Navigator.of(context).pop(
      _UpdateCurrentPageDialogResult(
        pageNumber: page,
        progressDate: _dateIsoString(_selectedDate),
      ),
    );
  }

//TODO: move to update widget

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update progress'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Current page',
              helperText: widget.totalPages == null
                  ? null
                  : 'Total pages: ${widget.totalPages}',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_outlined, size: 16),
              label: Text('Date: ${_formatDate(_selectedDate)}'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

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

  double _progressValueFor(int? effectiveCurrentPage) {
    final total = pages;
    if (effectiveCurrentPage == null || total == null || total <= 0) {
      return 0.0;
    }

    return (effectiveCurrentPage / total).clamp(0.0, 1.0).toDouble();
  }

  String _progressTextFor(double progressValue) {
    return '${(progressValue * 100).round()}%';
  }

  int _compareProgressDates(String a, String b) {
    final dateA = DateTime.tryParse(a);
    final dateB = DateTime.tryParse(b);
    if (dateA != null && dateB != null) {
      return dateA.compareTo(dateB);
    }
    return a.compareTo(b);
  }

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

  String _formatDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) {
      return value;
    }
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }

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

  ButtonStyle _compactTonalButtonStyle(ThemeData theme) {
    return FilledButton.styleFrom(
      minimumSize: const Size(0, 36),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  ButtonStyle _historyButtonStyle(ThemeData theme) {
    return FilledButton.styleFrom(
      foregroundColor: theme.colorScheme.onPrimaryContainer,
      backgroundColor: theme.colorScheme.primaryContainer,
      minimumSize: const Size(0, 36),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
      final effectiveCurrentPage = latestEntry?.pageNumber ?? currentPage;
      final progressValue = _progressValueFor(effectiveCurrentPage);
      final progressText = _progressTextFor(progressValue);
      final pageText = 'Page ${effectiveCurrentPage?.toString() ?? '-'}';

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 180,
                        maxWidth: 240,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          minHeight: 7,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: onUpdatePressed,
                      style: _compactTonalButtonStyle(theme),
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 180,
                    maxWidth: 240,
                  ),
                  child: Text(
                    '$pageText | $progressText',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
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
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(status),
    );
  }
}
