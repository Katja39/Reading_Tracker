import 'package:flutter/material.dart';

import '../models/book.dart';
import 'book_detail_page.dart';
import '../repositories/book_repository.dart';

enum _BookSortField {
  title,
  author,
  status,
}

class BookPage extends StatefulWidget {
  const BookPage({
    super.key,
    required this.repository,
  });

  final BookRepository repository;

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  static const _bookStatuses = [
    'unread',
    'reading',
    'read',
    'paused',
    'dnf',
  ];

  List<Book> _books = const [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  int _selectedTabIndex = 1;
  _BookSortField _sortField = _BookSortField.title;
  bool _isSortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final books = await widget.repository.fetchBooks();

      if (!mounted) {
        return;
      }

      setState(() {
        _books = _sortBooks(books);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showAddBookDialog() async {
    final submitted = await showDialog<_AddBookDialogResult>(
      context: context,
      builder: (context) {
        return _AddBookDialog(statuses: _bookStatuses);
      },
    );

    if (submitted == null) {
      return;
    }

    final title = submitted.title;
    final author = submitted.author;
    final status = submitted.status;
    final rating = submitted.rating;

    if (title.isEmpty) {
      setState(() {
        _errorMessage = 'Title must not be empty.';
      });
      return;
    }

    if (author.isEmpty) {
      setState(() {
        _errorMessage = 'Author must not be empty.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final savedBook = await widget.repository.createBook(
        title: title,
        author: author,
        status: status,
        rating: rating,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _books = _sortBooks([..._books, savedBook]);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  List<Book> _sortBooks(List<Book> books) {
    final sortedBooks = [...books];
    String valueForSort(Book book) {
      switch (_sortField) {
        case _BookSortField.title:
          return book.title.toLowerCase();
        case _BookSortField.author:
          return book.author.toLowerCase();
        case _BookSortField.status:
          return book.status.toLowerCase();
      }
    }

    sortedBooks.sort((left, right) {
      final compare = valueForSort(left).compareTo(valueForSort(right));
      return _isSortAscending ? compare : -compare;
    });
    return sortedBooks;
  }

  Future<void> _openBookDetails(Book book) async {
    final result = await Navigator.of(context).push<BookDetailResult>(
      MaterialPageRoute<BookDetailResult>(
        builder: (_) => BookDetailPage(
          book: book,
          repository: widget.repository,
          statuses: _bookStatuses,
        ),
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      if (result.isDeleted) {
        _books = _books
            .where((entry) => entry.id != result.deletedBookId)
            .toList();
        return;
      }

      final updatedBook = result.updatedBook!;
      final updatedBooks = _books
          .map((entry) => entry.id == updatedBook.id ? updatedBook : entry)
          .toList();
      _books = _sortBooks(updatedBooks);
    });
  }

  Widget _buildStartTab(ThemeData theme) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Home',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryTab(ThemeData theme, List<Book> books) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Sort by:',
                              style: theme.textTheme.labelMedium,
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<_BookSortField>(
                              value: _sortField,
                              isDense: true,
                              underline: const SizedBox.shrink(),
                              items: const [
                                DropdownMenuItem(
                                  value: _BookSortField.title,
                                  child: Text('Title'),
                                ),
                                DropdownMenuItem(
                                  value: _BookSortField.author,
                                  child: Text('Author'),
                                ),
                                DropdownMenuItem(
                                  value: _BookSortField.status,
                                  child: Text('Status'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }

                                setState(() {
                                  _sortField = value;
                                  _books = _sortBooks(_books);
                                });
                              },
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _isSortAscending = !_isSortAscending;
                                  _books = _sortBooks(_books);
                                });
                              },
                              tooltip: _isSortAscending
                                  ? 'Ascending'
                                  : 'Descending',
                              visualDensity: VisualDensity.compact,
                              iconSize: 18,
                              padding: const EdgeInsets.all(8),
                              icon: AnimatedRotation(
                                duration: const Duration(milliseconds: 180),
                                turns: _isSortAscending ? 0 : 0.5,
                                child: const Icon(Icons.arrow_upward),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Material(
                  color: const Color(0xFFF8D7DA),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFF7A1F28),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: books.isEmpty
                              ? Center(
                                  child: Text(
                                    'No books available yet.',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Title',
                                            style: theme.textTheme.labelLarge,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Author',
                                            style: theme.textTheme.labelLarge,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            'Status',
                                            style: theme.textTheme.labelLarge,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    Expanded(
                                      child: ListView.separated(
                                        itemCount: books.length,
                                        separatorBuilder: (_, _) =>
                                            const Divider(height: 24),
                                        itemBuilder: (context, index) {
                                          final entry = books[index];
                                          return InkWell(
                                            onTap: () =>
                                                _openBookDetails(entry),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 10,
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(entry.title),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(entry.author),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Text(entry.status),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _loadBooks,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reload'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _showAddBookDialog,
                    icon: const Icon(Icons.add),
                    label: Text(
                      _isSaving ? 'Saving...' : 'New Book',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTab(ThemeData theme) {
    return Center(
      child: Text(
        'This page is empty.',
        style: theme.textTheme.bodyLarge,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final books = _books;
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    final tabIndex = isMobile ? _selectedTabIndex : 1;
    final (title, content) = switch (tabIndex) {
      0 => ('Home', _buildStartTab(theme)),
      1 => ('Library', _buildLibraryTab(theme, books)),
      _ => ('Empty', _buildEmptyTab(theme)),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: content,
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: _selectedTabIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Start',
                ),
                NavigationDestination(
                  icon: Icon(Icons.library_books_outlined),
                  selectedIcon: Icon(Icons.library_books),
                  label: 'Library',
                ),
                NavigationDestination(
                  icon: Icon(Icons.more_horiz),
                  selectedIcon: Icon(Icons.more_horiz),
                  label: 'Empty',
                ),
              ],
            )
          : null,
    );
  }
}

class _AddBookDialogResult {
  const _AddBookDialogResult({
    required this.title,
    required this.author,
    required this.status,
    required this.rating,
  });

  final String title;
  final String author;
  final String status;
  final double? rating;
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
  late String _selectedStatus;
  double? _selectedRating;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _authorController = TextEditingController();
    _selectedStatus = widget.statuses.first;
    _selectedRating = null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(
      _AddBookDialogResult(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        status: _selectedStatus,
        rating: _selectedRating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Book'),
      content: Column(
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
