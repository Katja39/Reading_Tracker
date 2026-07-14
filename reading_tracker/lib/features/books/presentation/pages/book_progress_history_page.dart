// Progress history page for viewing, editing, and deleting dated reading entries



part of 'book_detail_page.dart';

// Screen used from the detail page to manage individual progress entries
class _BookProgressHistoryPage extends StatefulWidget {
  const _BookProgressHistoryPage({
    required this.book,
    required this.repository,
    required this.onBookChanged,
  });

  final Book book;
  final BookRepository repository;
  final ValueChanged<Book> onBookChanged;

  @override
  State<_BookProgressHistoryPage> createState() =>
      _BookProgressHistoryPageState();
}

// Owns the loaded progress list, save state, and latest updated book result
class _BookProgressHistoryPageState extends State<_BookProgressHistoryPage> {
  late Future<List<ReadingProgressEntry>> _progressFuture;
  Book? _updatedBook;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _progressFuture = _loadProgress();
  }

  // Loads all progress entries for the selected book
  Future<List<ReadingProgressEntry>> _loadProgress() {
    return widget.repository.fetchReadingProgress(bookId: widget.book.id);
  }

  // Replaces the progress future to trigger a list refresh
  void _reload() {
    setState(() {
      _progressFuture = _loadProgress();
    });
  }

  // Formats backend dates for list subtitles and delete confirmation
  String _formatDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) {
      return value;
    }
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }

  // Reports repository errors without leaving the history screen
  void _showError(Object error) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
  }

  // Validates the page number
  String? _validateProgressPage(int? pageNumber) {
    if (pageNumber == null) {
      return 'Current page must be a number.';
    }
    if (pageNumber < 0) {
      return 'Current page must not be negative.';
    }

    final totalPages = widget.book.pages;
    if (totalPages != null && pageNumber > totalPages) {
      return 'Current page must not exceed total pages.';
    }

    return null;
  }

  // Opens the progress dialog for one entry and persists edited page/date data
  Future<void> _editEntry(ReadingProgressEntry entry) async {
    final submitted = await showDialog<ReadingProgressUpdateResult>(
      context: context,
      builder: (context) {
        return ReadingProgressUpdateDialog(
          initialPage: entry.pageNumber,
          totalPages: widget.book.pages,
          initialProgressDate: entry.progressDate,
        );
      },
    );
    if (submitted == null) {
      return;
    }

    final validationMessage = _validateProgressPage(submitted.pageNumber);
    if (validationMessage != null) {
      _showError(validationMessage);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedBook = await widget.repository.updateReadingProgress(
        bookId: widget.book.id,
        progressId: entry.id,
        pageNumber: submitted.pageNumber!,
        progressDate: submitted.progressDate,
      );

      if (!mounted) {
        return;
      }

      _updatedBook = updatedBook;
      widget.onBookChanged(updatedBook);
      _reload();
    } catch (error) {
      if (mounted) {
        _showError(error);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // Confirms and deletes one progress entry, then refreshes parent book state
  Future<void> _deleteEntry(ReadingProgressEntry entry) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete progress entry'),
          content: Text(
            'Delete progress for ${_formatDate(entry.progressDate)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (shouldDelete != true) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedBook = await widget.repository.deleteReadingProgress(
        bookId: widget.book.id,
        progressId: entry.id,
      );

      if (!mounted) {
        return;
      }

      _updatedBook = updatedBook;
      widget.onBookChanged(updatedBook);
      _reload();
    } catch (error) {
      if (mounted) {
        _showError(error);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _isSaving
              ? null
              : () => Navigator.of(context).pop(_updatedBook),
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Progress history'),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _reload,
            tooltip: 'Reload',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<ReadingProgressEntry>>(
        future: _progressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ErrorBanner(message: snapshot.error.toString()),
            );
          }

          final entries = snapshot.data ?? const [];
          if (entries.isEmpty) {
            return const Center(child: Text('No progress updates yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.event_note_outlined),
                  title: Text('Page ${entry.pageNumber}'),
                  subtitle: Text(_formatDate(entry.progressDate)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _isSaving ? null : () => _editEntry(entry),
                        tooltip: 'Edit',
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: _isSaving ? null : () => _deleteEntry(entry),
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}