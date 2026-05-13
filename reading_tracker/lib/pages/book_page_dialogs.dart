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
    required this.coverUrl,
  });

  final String title;
  final String author;
  final String status;
  final double? rating;
  final String? isbn;
  final int? pages;
  final String? publisher;
  final String? languageCode;
  final String? coverUrl;
}

class _AddBookDialog extends StatefulWidget {
  const _AddBookDialog({
    required this.statuses,
    required this.repository,
  });

  final List<String> statuses;
  final BookRepository repository;

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
  String? _coverUrl;
  late String _selectedStatus;
  double? _selectedRating;
  bool _isAutoFilling = false;
  String? _autoFillMessage;

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
    _coverUrl = null;
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
        coverUrl: _coverUrl,
      ),
    );
  }

  Future<void> _autoFillFromIsbn() async {
    final isbn = _isbnController.text.trim();
    if (isbn.isEmpty) {
      setState(() {
        _autoFillMessage = 'Please enter an ISBN first.';
      });
      return;
    }

    setState(() {
      _isAutoFilling = true;
      _autoFillMessage = null;
    });

    try {
      final enrichment = await widget.repository.fetchBookEnrichmentByIsbn(
        isbn: isbn,
      );
      if (!mounted) {
        return;
      }

      if (enrichment == null) {
        setState(() {
          _autoFillMessage = 'No metadata found for this ISBN.';
        });
        return;
      }

      setState(() {
        if (enrichment.title != null && enrichment.title!.isNotEmpty) {
          _titleController.text = enrichment.title!;
        }
        if (enrichment.author != null && enrichment.author!.isNotEmpty) {
          _authorController.text = enrichment.author!;
        }
        if (enrichment.pages != null) {
          _pagesController.text = enrichment.pages!.toString();
        }
        if (enrichment.publisher != null && enrichment.publisher!.isNotEmpty) {
          _publisherController.text = enrichment.publisher!;
        }
        if (enrichment.languageCode != null &&
            enrichment.languageCode!.isNotEmpty) {
          _languageCodeController.text = enrichment.languageCode!;
        }
        _coverUrl = enrichment.coverUrl;
        _autoFillMessage = 'Fields updated from Open Library.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _autoFillMessage = 'Auto fill failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAutoFilling = false;
        });
      }
    }
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
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _isAutoFilling ? null : _autoFillFromIsbn,
                icon: const Icon(Icons.auto_awesome_outlined),
                label: Text(_isAutoFilling ? 'Loading...' : 'Auto'),
              ),
            ),
            if (_autoFillMessage != null) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(_autoFillMessage!),
              ),
            ],
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
