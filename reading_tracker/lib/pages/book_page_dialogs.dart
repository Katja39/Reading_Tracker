part of 'book_page.dart';

class _AddBookDialogResult {
  const _AddBookDialogResult({
    required this.title,
    required this.author,
    required this.status,
    required this.rating,
    required this.isbn,
    required this.pages,
    required this.publisher,
    required this.languageCode,
  });

  final String title;
  final String author;
  final String status;
  final double? rating;
  final String? isbn;
  final int? pages;
  final String? publisher;
  final String? languageCode;
}

class _AddBookDialog extends StatefulWidget {
  const _AddBookDialog({
    required this.statuses,
  });

  final List<String> statuses;

  @override
  State<_AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<_AddBookDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _isbnController;
  late final TextEditingController _pagesController;
  late final TextEditingController _publisherController;
  late final TextEditingController _languageCodeController;
  late String _selectedStatus;
  double? _selectedRating;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _authorController = TextEditingController();
    _isbnController = TextEditingController();
    _pagesController = TextEditingController();
    _publisherController = TextEditingController();
    _languageCodeController = TextEditingController();
    _selectedStatus = widget.statuses.first;
    _selectedRating = null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _pagesController.dispose();
    _publisherController.dispose();
    _languageCodeController.dispose();
    super.dispose();
  }

  void _submit() {
    final pagesText = _pagesController.text.trim();
    final pages = pagesText.isEmpty ? null : int.tryParse(pagesText);

    Navigator.of(context).pop(
      _AddBookDialogResult(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        status: _selectedStatus,
        rating: _selectedRating,
        isbn: _isbnController.text.trim().isEmpty
            ? null
            : _isbnController.text.trim(),
        pages: pages,
        publisher: _publisherController.text.trim().isEmpty
            ? null
            : _publisherController.text.trim(),
        languageCode: _languageCodeController.text.trim().isEmpty
            ? null
            : _languageCodeController.text.trim().toLowerCase(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Book'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Author',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _isbnController,
              decoration: const InputDecoration(
                labelText: 'ISBN (optional)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pagesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Pages (optional)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _publisherController,
              decoration: const InputDecoration(
                labelText: 'Publisher (optional)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _languageCodeController,
              decoration: const InputDecoration(
                labelText: 'Language code (optional)',
                hintText: 'e.g. en, de',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
              ),
              items: widget.statuses
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<double?>(
              initialValue: _selectedRating,
              decoration: const InputDecoration(
                labelText: 'Rating',
              ),
              items: const [
                DropdownMenuItem<double?>(
                  value: null,
                  child: Text('No rating'),
                ),
                DropdownMenuItem<double?>(value: 1, child: Text('1 star')),
                DropdownMenuItem<double?>(value: 2, child: Text('2 stars')),
                DropdownMenuItem<double?>(value: 3, child: Text('3 stars')),
                DropdownMenuItem<double?>(value: 4, child: Text('4 stars')),
                DropdownMenuItem<double?>(value: 5, child: Text('5 stars')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRating = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
