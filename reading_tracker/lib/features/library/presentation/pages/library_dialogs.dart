//
// Dialog helpers used by the library page
//


part of 'library_page.dart';

// Wraps the shared book form for creating a new book
class _AddBookDialog extends StatelessWidget {
  const _AddBookDialog({
    required this.statuses,
    required this.repository,
    this.onBooksChanged,
  });

  final List<String> statuses;
  final BookRepository repository;
  final Future<void> Function()? onBooksChanged;

  // Builds the add book form with create defaults
  @override
  Widget build(BuildContext context) {
    return BookFormDialog(
      title: 'New Book',
      submitLabel: 'Create',
      statuses: statuses,
      repository: repository,
      initialStatus: statuses.first,
      initialRating: null,
      enableInlineRating: true,
      onBooksChanged: onBooksChanged,
    );
  }
}
