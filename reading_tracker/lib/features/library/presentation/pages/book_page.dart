import 'package:flutter/material.dart';

import '../../../books/domain/models/book.dart';
import '../../../books/domain/repositories/book_repository.dart';
import '../../../books/presentation/pages/book_detail_page.dart';
import '../../../books/presentation/widgets/book_form_dialog.dart';
import '../../../../shared/widgets/error_banner.dart';

part 'book_page_dialog.dart';
part 'book_page_section.dart';

enum _BookSortField {
  title,
  author,
  status,
  rating,
}

enum _BookFilterField {
  title,
  author,
  status,
  rating,
}

enum _LibraryColumn {
  author,
  status,
  rating,
  isbn,
  pages,
  publisher,
  languageCode,
  seriesId,
  volume,
  genreId,
  ageCategory,
  releaseDate,
  format,
}

class BookPage extends StatefulWidget {
  const BookPage({
    super.key,
    required this.repository,
    required this.themeMode,
    required this.onToggleThemeMode,
  });

  final BookRepository repository;
  final ThemeMode themeMode;
  final VoidCallback onToggleThemeMode;

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  static const _menuActionSortFilter = 'sort_filter';
  static const _menuActionResetFilter = 'reset_filter';
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
  _BookFilterField _filterField = _BookFilterField.status;
  String _filterValue = 'all';
  List<_LibraryColumn> _columnOrder = const [
    _LibraryColumn.author,
    _LibraryColumn.status,
    _LibraryColumn.rating,
    _LibraryColumn.isbn,
    _LibraryColumn.pages,
    _LibraryColumn.publisher,
    _LibraryColumn.languageCode,
    _LibraryColumn.seriesId,
    _LibraryColumn.volume,
    _LibraryColumn.genreId,
    _LibraryColumn.ageCategory,
    _LibraryColumn.releaseDate,
    _LibraryColumn.format,
  ];
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        _books = books;
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
    final submitted = await showDialog<BookFormResult>(
      context: context,
      builder: (context) {
        return _AddBookDialog(
          statuses: _bookStatuses,
          repository: widget.repository,
          onBooksChanged: _loadBooks,
        );
      },
    );

    if (submitted == null) {
      return;
    }

    final title = submitted.title;
    final author = submitted.author;
    final status = submitted.status;
    final rating = submitted.rating;
    final isbn = submitted.isbn;
    final pages = submitted.pages;
    final publisher = submitted.publisher;
    final languageCode = submitted.languageCode;
    final coverUrl = submitted.coverUrl;
    final seriesId = submitted.seriesId;
    final volume = submitted.volume;
    final genreId = submitted.genreId;
    final ageCategory = submitted.ageCategory;
    final releaseDate = submitted.releaseDate;
    final format = submitted.format;

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
        isbn: isbn,
        pages: pages,
        publisher: publisher,
        languageCode: languageCode,
        coverUrl: coverUrl,
        seriesId: seriesId,
        volume: volume,
        genreId: genreId,
        ageCategory: ageCategory,
        releaseDate: releaseDate,
        format: format,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _books = [..._books, savedBook];
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
    sortedBooks.sort((left, right) {
      final compare = switch (_sortField) {
        _BookSortField.title =>
          left.title.toLowerCase().compareTo(right.title.toLowerCase()),
        _BookSortField.author =>
          left.author.toLowerCase().compareTo(right.author.toLowerCase()),
        _BookSortField.status =>
          left.status.toLowerCase().compareTo(right.status.toLowerCase()),
        _BookSortField.rating => (left.rating ?? -1).compareTo(right.rating ?? -1),
      };
      return _isSortAscending ? compare : -compare;
    });
    return sortedBooks;
  }

  List<Book> _filterBooks(List<Book> books) {
    if (_filterValue == 'all') {
      return books;
    }

    return books
        .where((book) => _valueForFilterField(book, _filterField) == _filterValue)
        .toList();
  }

  List<Book> _searchBooks(List<Book> books) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return books;
    }

    return books.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.status.toLowerCase().contains(query) ||
          _formatRating(book.rating).toLowerCase().contains(query);
    }).toList();
  }

  String _valueForFilterField(Book book, _BookFilterField field) {
    switch (field) {
      case _BookFilterField.title:
        return book.title;
      case _BookFilterField.author:
        return book.author;
      case _BookFilterField.status:
        return book.status;
      case _BookFilterField.rating:
        return _formatRating(book.rating);
    }
  }

  List<String> _filterOptions() {
    if (_filterField == _BookFilterField.status) {
      return _bookStatuses;
    }

    final values = _books
        .map((book) => _valueForFilterField(book, _filterField))
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return values;
  }

  List<DropdownMenuItem<_BookSortField>> _sortFieldItems() {
    return const [
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
      DropdownMenuItem(
        value: _BookSortField.rating,
        child: Text('Rating'),
      ),
    ];
  }

  List<DropdownMenuItem<_BookFilterField>> _filterFieldItems() {
    return const [
      DropdownMenuItem(
        value: _BookFilterField.title,
        child: Text('Title'),
      ),
      DropdownMenuItem(
        value: _BookFilterField.author,
        child: Text('Author'),
      ),
      DropdownMenuItem(
        value: _BookFilterField.status,
        child: Text('Status'),
      ),
      DropdownMenuItem(
        value: _BookFilterField.rating,
        child: Text('Rating'),
      ),
    ];
  }

  String _formatRating(double? rating) {
    if (rating == null) {
      return 'No rating';
    }

    final normalizedRating = rating % 1 == 0 ? rating.toInt().toString() : rating.toString();
    return '$normalizedRating/5';
  }

  String _libraryColumnLabel(_LibraryColumn column) {
    switch (column) {
      case _LibraryColumn.author:
        return 'Author';
      case _LibraryColumn.status:
        return 'Status';
      case _LibraryColumn.rating:
        return 'Rating';
      case _LibraryColumn.isbn:
        return 'ISBN';
      case _LibraryColumn.pages:
        return 'Pages';
      case _LibraryColumn.publisher:
        return 'Publisher';
      case _LibraryColumn.languageCode:
        return 'Language';
      case _LibraryColumn.seriesId:
        return 'Series';
      case _LibraryColumn.volume:
        return 'Volume';
      case _LibraryColumn.genreId:
        return 'Genre';
      case _LibraryColumn.ageCategory:
        return 'Age';
      case _LibraryColumn.releaseDate:
        return 'Release';
      case _LibraryColumn.format:
        return 'Format';
    }
  }

  String _libraryColumnValue(Book book, _LibraryColumn column) {
    switch (column) {
      case _LibraryColumn.author:
        return book.author;
      case _LibraryColumn.status:
        return book.status;
      case _LibraryColumn.rating:
        return _formatRating(book.rating);
      case _LibraryColumn.isbn:
        return book.isbn ?? '-';
      case _LibraryColumn.pages:
        return book.pages?.toString() ?? '-';
      case _LibraryColumn.publisher:
        return book.publisher ?? '-';
      case _LibraryColumn.languageCode:
        return book.languageCode ?? '-';
      case _LibraryColumn.seriesId:
        return book.seriesId ?? '-';
      case _LibraryColumn.volume:
        return book.volume?.toString() ?? '-';
      case _LibraryColumn.genreId:
        return book.genreId ?? '-';
      case _LibraryColumn.ageCategory:
        return book.ageCategory ?? '-';
      case _LibraryColumn.releaseDate:
        return book.releaseDate ?? '-';
      case _LibraryColumn.format:
        return book.format ?? '-';
    }
  }

  int _columnFlexForValues(Iterable<String> values) {
    final maxLength = values.fold<int>(
      0,
      (currentMax, value) => value.length > currentMax ? value.length : currentMax,
    );

    if (maxLength <= 8) {
      return 1;
    }
    if (maxLength <= 16) {
      return 2;
    }
    if (maxLength <= 24) {
      return 3;
    }
    return 4;
  }

  int _titleColumnFlex(List<Book> books) {
    final baseFlex = _columnFlexForValues([
      'Title',
      ...books.map((book) => book.title),
    ]);

    // Keep title readable, but cap it so the trailing columns stay visible.
    final reducedFlex = baseFlex > 1 ? baseFlex - 1 : 1;
    return reducedFlex > 2 ? 2 : reducedFlex;
  }

  int _libraryColumnFlex(List<Book> books, _LibraryColumn column) {
    final baseFlex = _columnFlexForValues([
      _libraryColumnLabel(column),
      ...books.map((book) => _libraryColumnValue(book, column)),
    ]);

    // Ensure configurable columns do not collapse too far.
    return baseFlex < 2 ? 2 : baseFlex;
  }

  void _updateLibraryColumnAtIndex({
    required int index,
    required _LibraryColumn column,
  }) {
    if (index < 0 || index >= _columnOrder.length) {
      return;
    }

    final currentIndex = _columnOrder.indexOf(column);
    if (currentIndex == -1 || currentIndex == index) {
      return;
    }

    setState(() {
      final reordered = [..._columnOrder];
      final currentAtTarget = reordered[index];
      reordered[index] = column;
      reordered[currentIndex] = currentAtTarget;
      _columnOrder = reordered;
    });
  }

  List<PopupMenuEntry<_LibraryColumn>> _libraryColumnMenuItems(
    _LibraryColumn selectedColumn,
  ) {
    return _LibraryColumn.values
        .map(
          (column) => CheckedPopupMenuItem<_LibraryColumn>(
            value: column,
            checked: column == selectedColumn,
            child: Text(_libraryColumnLabel(column)),
          ),
        )
        .toList();
  }

  Widget _buildColumnHeader(
    ThemeData theme, {
    required String label,
    required bool canChange,
    _LibraryColumn? selectedColumn,
    int? columnOrderIndex,
  }) {
    if (!canChange || selectedColumn == null) {
      return Text(
        label,
        style: theme.textTheme.labelLarge,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      );
    }

    return PopupMenuButton<_LibraryColumn>(
      tooltip: 'Change column',
      onSelected: (value) {
        _updateLibraryColumnAtIndex(
          index: columnOrderIndex ?? 0,
          column: value,
        );
      },
      itemBuilder: (_) => _libraryColumnMenuItems(selectedColumn),
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.55,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelLarge,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
            const SizedBox(width: 2),
          ],
        ),
      ),
    );
  }

  String _formatFilterOptionLabel(String value) {
    if (_filterField != _BookFilterField.status) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }

  void _resetSortAndFilter() {
    setState(() {
      _filterField = _BookFilterField.status;
      _filterValue = 'all';
      _sortField = _BookSortField.title;
      _isSortAscending = true;
      _columnOrder = const [
        _LibraryColumn.author,
        _LibraryColumn.status,
        _LibraryColumn.rating,
        _LibraryColumn.isbn,
        _LibraryColumn.pages,
        _LibraryColumn.publisher,
        _LibraryColumn.languageCode,
        _LibraryColumn.seriesId,
        _LibraryColumn.volume,
        _LibraryColumn.genreId,
        _LibraryColumn.ageCategory,
        _LibraryColumn.releaseDate,
        _LibraryColumn.format,
      ];
    });
  }

  Future<void> _openSortFilterSheet(ThemeData theme) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, sheetSetState) {
            void refreshSheet() {
              sheetSetState(() {});
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sort by:', style: theme.textTheme.labelMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<_BookSortField>(
                            initialValue: _sortField,
                            items: _sortFieldItems(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                _sortField = value;
                              });
                              refreshSheet();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isSortAscending = !_isSortAscending;
                            });
                            refreshSheet();
                          },
                          tooltip: _isSortAscending
                              ? 'Ascending'
                              : 'Descending',
                          icon: AnimatedRotation(
                            duration: const Duration(milliseconds: 180),
                            turns: _isSortAscending ? 0 : 0.5,
                            child: const Icon(Icons.arrow_upward),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Filter by:', style: theme.textTheme.labelMedium),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<_BookFilterField>(
                      initialValue: _filterField,
                      items: _filterFieldItems(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _filterField = value;
                          _filterValue = 'all';
                        });
                        refreshSheet();
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Value:', style: theme.textTheme.labelMedium),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _filterValue,
                      items: [
                        const DropdownMenuItem(
                          value: 'all',
                          child: Text('All'),
                        ),
                        ..._filterOptions().map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(
                              _formatFilterOptionLabel(value),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _filterValue = value;
                        });
                        refreshSheet();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
      _books = _books
          .map((entry) => entry.id == updatedBook.id ? updatedBook : entry)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final books = _sortBooks(_searchBooks(_filterBooks(_books)));
    final isDarkMode = widget.themeMode == ThemeMode.dark;
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    final tabIndex = _selectedTabIndex;
    final (title, content) = switch (tabIndex) {
      0 => ('Home', this._buildStartTab(theme)),
      1 => ('Library', this._buildLibraryTab(theme, books)),
      _ => ('Statistics', this._buildStatisticsTab(theme)),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          if (!isMobile) ...[
            _TopNavButton(
              label: 'Home',
              isSelected: tabIndex == 0,
              onPressed: () {
                setState(() {
                  _selectedTabIndex = 0;
                });
              },
            ),
            _TopNavButton(
              label: 'Library',
              isSelected: tabIndex == 1,
              onPressed: () {
                setState(() {
                  _selectedTabIndex = 1;
                });
              },
            ),
            _TopNavButton(
              label: 'Statistics',
              isSelected: tabIndex == 2,
              onPressed: () {
                setState(() {
                  _selectedTabIndex = 2;
                });
              },
            ),
            const SizedBox(width: 8),
          ],
          PopupMenuButton<String>(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onSelected: (value) {
              if (value == 'toggle_theme') {
                widget.onToggleThemeMode();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                value: 'toggle_theme',
                child: Row(
                  children: [
                    const Icon(Icons.palette_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Schema: ${isDarkMode ? 'Dark' : 'Light'}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.library_books_outlined),
                  selectedIcon: Icon(Icons.library_books),
                  label: 'Library',
                ),
                NavigationDestination(
                  icon: Icon(Icons.more_horiz),
                  selectedIcon: Icon(Icons.more_horiz),
                  label: 'Statistics',
                ),
              ],
            )
          : null,
    );
  }
}

class _TopNavButton extends StatelessWidget {
  const _TopNavButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: isSelected
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurface,
          backgroundColor: isSelected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
