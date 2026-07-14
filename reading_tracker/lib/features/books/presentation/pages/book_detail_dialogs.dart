//
// Dialog helpers used by BookDetailPage for editing book metadata and ratings
//


part of 'book_detail_page.dart';

// Wraps the shared book form with the current book as initial data
class _EditBookDialog extends StatelessWidget {
  const _EditBookDialog({
    required this.book,
    required this.statuses,
    required this.repository,
  });

  final Book book;
  final List<String> statuses;
  final BookRepository repository;

  @override
  Widget build(BuildContext context) {
    return BookFormDialog(
      title: 'Edit Book',
      submitLabel: 'Save',
      statuses: statuses,
      repository: repository,
      initialBook: book,
    );
  }
}

// Return value for the rating dialog
class _EditRatingDialogResult {
  const _EditRatingDialogResult({required this.rating});

  final double? rating;
}

// Star rating or clear the existing rating
class _EditRatingDialog extends StatefulWidget {
  const _EditRatingDialog({required this.initialRating});

  final double? initialRating;

  @override
  State<_EditRatingDialog> createState() => _EditRatingDialogState();
}

class _EditRatingDialogState extends State<_EditRatingDialog> {
  late double? _selectedRating;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.initialRating;
  }

  // Closes dialog with the currently selected rating value
  void _submit() {
    Navigator.of(context).pop(_EditRatingDialogResult(rating: _selectedRating));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Rating'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rating', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...List.generate(5, (index) {
                final starValue = index + 1;
                final isSelected =
                    _selectedRating != null && _selectedRating! >= starValue;
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedRating = starValue.toDouble();
                    });
                  },
                  icon: Icon(isSelected ? Icons.star : Icons.star_border),
                );
              }),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedRating = null;
                  });
                },
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
