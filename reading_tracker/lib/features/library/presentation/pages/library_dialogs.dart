part of 'library_page.dart';

class _AddBookDialog extends StatelessWidget {
  const _AddBookDialog({
    required this.statuses,
    required this.repository,
    this.onBooksChanged,
  });

  final List<String> statuses;
  final BookRepository repository;
  final Future<void> Function()? onBooksChanged;

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
