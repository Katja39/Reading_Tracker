import 'package:flutter/material.dart';

import '../../../books/domain/models/book.dart';
import '../../../books/domain/repositories/book_repository.dart';
import '../../../books/presentation/pages/book_detail_page.dart';
import '../../../books/presentation/widgets/book_form_dialog.dart';
import '../../../../shared/widgets/error_banner.dart';

part 'book_page_dialog.dart';
part 'book_page_section.dart';

enum _LibraryField {
  title,
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

enum _LibraryControlPanel {
  sort,
  filter,
  display,
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
  static const _maxMobileInfoColumns = 6;
  static const _bookStatuses = [
    'unread',
    'reading',
    'read',
    'paused',
    'dnf',
  ];
  static const _configurableFields = [
    _LibraryField.author,
    _LibraryField.status,
    _LibraryField.rating,
    _LibraryField.isbn,
    _LibraryField.pages,
    _LibraryField.publisher,
    _LibraryField.languageCode,
    _LibraryField.seriesId,
    _LibraryField.volume,
    _LibraryField.genreId,
    _LibraryField.ageCategory,
    _LibraryField.releaseDate,
    _LibraryField.format,
  ];
  static const _defaultDesktopFields = [
    _LibraryField.author,
    _LibraryField.status,
    _LibraryField.rating,
    _LibraryField.isbn,
    _LibraryField.pages,
    _LibraryField.publisher,
    _LibraryField.languageCode,
    _LibraryField.seriesId,
    _LibraryField.volume,
    _LibraryField.genreId,
    _LibraryField.ageCategory,
    _LibraryField.releaseDate,
    _LibraryField.format,
  ];
  static const _defaultMobileInfoFields = [
    _LibraryField.author,
    _LibraryField.status,
    _LibraryField.rating,
  ];

  List<Book> _books = const [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  int _selectedTabIndex = 1;
  _LibraryField _sortField = _LibraryField.title;
  bool _isSortAscending = true;
  _LibraryField _filterField = _LibraryField.status;
  String _filterValue = 'all';
  List<_LibraryField> _columnOrder = _defaultDesktopFields;
  List<_LibraryField> _mobileInfoFields = _defaultMobileInfoFields;
  late final TextEditingController _searchController;
  late final TextEditingController _pagesFilterMinController;
  late final TextEditingController _pagesFilterMaxController;
  String _searchQuery = '';

  List<_LibraryField> get _availableConfigurableFields => _configurableFields;

  bool get _hasPagesRangeFilter {
    return _pagesFilterMinController.text.trim().isNotEmpty ||
        _pagesFilterMaxController.text.trim().isNotEmpty;
  }

  bool get _hasActiveFilter {
    if (_filterField == _LibraryField.pages) {
      return _hasPagesRangeFilter;
    }
    return _filterValue != 'all';
  }

  String get _activeFilterSummary {
    final label = _fieldLabel(_filterField);
    if (_filterField == _LibraryField.pages) {
      final min = _pagesFilterMinController.text.trim();
      final max = _pagesFilterMaxController.text.trim();
      if (min.isNotEmpty && max.isNotEmpty) {
        return '$label: $min-$max';
      }
      if (min.isNotEmpty) {
        return '$label: from $min';
      }
      if (max.isNotEmpty) {
        return '$label: up to $max';
      }
    }

    return '$label: ${_formatFilterOptionLabel(_filterValue)}';
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _pagesFilterMinController = TextEditingController();
    _pagesFilterMaxController = TextEditingController();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pagesFilterMinController.dispose();
    _pagesFilterMaxController.dispose();
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

    if (submitted.title.isEmpty) {
      setState(() {
        _errorMessage = 'Title must not be empty.';
      });
      return;
    }

    if (submitted.author.isEmpty) {
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
        title: submitted.title,
        author: submitted.author,
        status: submitted.status,
        rating: submitted.rating,
        isbn: submitted.isbn,
        pages: submitted.pages,
        publisher: submitted.publisher,
        languageCode: submitted.languageCode,
        coverUrl: submitted.coverUrl,
        seriesId: submitted.seriesId,
        volume: submitted.volume,
        genreId: submitted.genreId,
        ageCategory: submitted.ageCategory,
        releaseDate: submitted.releaseDate,
        format: submitted.format,
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

  int _compareBooksByField(Book left, Book right, _LibraryField field) {
    switch (field) {
      case _LibraryField.rating:
        return (left.rating ?? -1).compareTo(right.rating ?? -1);
      case _LibraryField.pages:
        return (left.pages ?? -1).compareTo(right.pages ?? -1);
      case _LibraryField.volume:
        return (left.volume ?? -1).compareTo(right.volume ?? -1);
      default:
        return _fieldFilterValue(left, field).toLowerCase().compareTo(
              _fieldFilterValue(right, field).toLowerCase(),
            );
    }
  }

  List<Book> _sortBooks(List<Book> books) {
    final sortedBooks = [...books];
    sortedBooks.sort((left, right) {
      final compare = _compareBooksByField(left, right, _sortField);
      return _isSortAscending ? compare : -compare;
    });
    return sortedBooks;
  }

  List<Book> _filterBooks(List<Book> books) {
    if (_filterField == _LibraryField.pages) {
      final minPages = int.tryParse(_pagesFilterMinController.text.trim());
      final maxPages = int.tryParse(_pagesFilterMaxController.text.trim());

      if (minPages == null && maxPages == null) {
        return books;
      }

      return books.where((book) {
        final pages = book.pages;
        if (pages == null) {
          return false;
        }
        if (minPages != null && pages < minPages) {
          return false;
        }
        if (maxPages != null && pages > maxPages) {
          return false;
        }
        return true;
      }).toList();
    }

    if (_filterValue == 'all') {
      return books;
    }

    return books
        .where((book) => _fieldFilterValue(book, _filterField) == _filterValue)
        .toList();
  }

  List<Book> _searchBooks(List<Book> books) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return books;
    }

    return books.where((book) {
      return _LibraryField.values.any(
        (field) => _fieldSearchValue(book, field).contains(query),
      );
    }).toList();
  }

  String _fieldLabel(_LibraryField field) {
    switch (field) {
      case _LibraryField.title:
        return 'Title';
      case _LibraryField.author:
        return 'Author';
      case _LibraryField.status:
        return 'Status';
      case _LibraryField.rating:
        return 'Rating';
      case _LibraryField.isbn:
        return 'ISBN';
      case _LibraryField.pages:
        return 'Pages';
      case _LibraryField.publisher:
        return 'Publisher';
      case _LibraryField.languageCode:
        return 'Language';
      case _LibraryField.seriesId:
        return 'Series';
      case _LibraryField.volume:
        return 'Volume';
      case _LibraryField.genreId:
        return 'Genre';
      case _LibraryField.ageCategory:
        return 'Age';
      case _LibraryField.releaseDate:
        return 'Release';
      case _LibraryField.format:
        return 'Format';
    }
  }

  String _fieldFilterValue(Book book, _LibraryField field) {
    switch (field) {
      case _LibraryField.title:
        return book.title;
      case _LibraryField.author:
        return book.author;
      case _LibraryField.status:
        return book.status;
      case _LibraryField.rating:
        return _formatRating(book.rating);
      case _LibraryField.isbn:
        return book.isbn ?? '-';
      case _LibraryField.pages:
        return book.pages?.toString() ?? '-';
      case _LibraryField.publisher:
        return book.publisher ?? '-';
      case _LibraryField.languageCode:
        return book.languageCode ?? '-';
      case _LibraryField.seriesId:
        return book.seriesId ?? '-';
      case _LibraryField.volume:
        return book.volume?.toString() ?? '-';
      case _LibraryField.genreId:
        return book.genreId ?? '-';
      case _LibraryField.ageCategory:
        return book.ageCategory ?? '-';
      case _LibraryField.releaseDate:
        return book.releaseDate ?? '-';
      case _LibraryField.format:
        return book.format ?? '-';
    }
  }

  String _fieldDisplayValue(Book book, _LibraryField field) {
    switch (field) {
      case _LibraryField.status:
        return _formatReadableLabel(book.status);
      case _LibraryField.ageCategory:
        return _formatReadableLabel(book.ageCategory);
      case _LibraryField.format:
        return _formatReadableLabel(book.format);
      default:
        return _fieldFilterValue(book, field);
    }
  }

  String _fieldSearchValue(Book book, _LibraryField field) {
    final raw = _fieldFilterValue(book, field).toLowerCase();
    final display = _fieldDisplayValue(book, field).toLowerCase();
    return raw == display ? raw : '$raw $display';
  }

  List<String> _filterOptions() {
    if (_filterField == _LibraryField.status) {
      return _bookStatuses;
    }

    final values = _books
        .map((book) => _fieldFilterValue(book, _filterField))
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return values;
  }

  List<DropdownMenuItem<_LibraryField>> _buildFieldItems(
    Iterable<_LibraryField> fields,
  ) {
    return fields
        .map(
          (field) => DropdownMenuItem<_LibraryField>(
            value: field,
            child: Text(_fieldLabel(field)),
          ),
        )
        .toList();
  }

  String _formatRating(double? rating) {
    if (rating == null) {
      return 'No rating';
    }

    final normalizedRating =
        rating % 1 == 0 ? rating.toInt().toString() : rating.toString();
    return '$normalizedRating/5';
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
      _fieldLabel(_LibraryField.title),
      ...books.map((book) => book.title),
    ]);

    final reducedFlex = baseFlex > 1 ? baseFlex - 1 : 1;
    return reducedFlex > 2 ? 2 : reducedFlex;
  }

  int _libraryFieldFlex(List<Book> books, _LibraryField field) {
    final baseFlex = _columnFlexForValues([
      _fieldLabel(field),
      ...books.map((book) => _fieldDisplayValue(book, field)),
    ]);

    return baseFlex < 2 ? 2 : baseFlex;
  }

  void _updateLibraryFieldAtIndex({
    required int index,
    required _LibraryField field,
  }) {
    if (index < 0 || index >= _columnOrder.length) {
      return;
    }

    final currentIndex = _columnOrder.indexOf(field);
    if (currentIndex == -1 || currentIndex == index) {
      return;
    }

    setState(() {
      final reordered = [..._columnOrder];
      final currentAtTarget = reordered[index];
      reordered[index] = field;
      reordered[currentIndex] = currentAtTarget;
      _columnOrder = reordered;
    });
  }

  void _toggleMobileInfoField(_LibraryField field, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (_mobileInfoFields.contains(field) ||
            _mobileInfoFields.length >= _maxMobileInfoColumns) {
          return;
        }
        _mobileInfoFields = [..._mobileInfoFields, field];
        return;
      }

      if (!_mobileInfoFields.contains(field) || _mobileInfoFields.length == 1) {
        return;
      }
      _mobileInfoFields = _mobileInfoFields
          .where((selectedField) => selectedField != field)
          .toList();
    });
  }

  List<PopupMenuEntry<_LibraryField>> _libraryFieldMenuItems(
    _LibraryField selectedField,
  ) {
    return _configurableFields
        .map(
          (field) => CheckedPopupMenuItem<_LibraryField>(
            value: field,
            checked: field == selectedField,
            child: Text(_fieldLabel(field)),
          ),
        )
        .toList();
  }

  Widget _buildColumnHeader(
    ThemeData theme, {
    required String label,
    required bool canChange,
    _LibraryField? selectedField,
    int? columnOrderIndex,
  }) {
    if (!canChange || selectedField == null) {
      return Text(
        label,
        style: theme.textTheme.labelLarge,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      );
    }

    return PopupMenuButton<_LibraryField>(
      tooltip: 'Change column',
      onSelected: (value) {
        _updateLibraryFieldAtIndex(
          index: columnOrderIndex ?? 0,
          field: value,
        );
      },
      itemBuilder: (_) => _libraryFieldMenuItems(selectedField),
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
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
    switch (_filterField) {
      case _LibraryField.status:
        return value == '-' ? value : value[0].toUpperCase() + value.substring(1);
      case _LibraryField.ageCategory:
      case _LibraryField.format:
        return _formatReadableLabel(value);
      default:
        return value;
    }
  }

  String _formatReadableLabel(String? value) {
    if (value == null || value.isEmpty || value == '-') {
      return '-';
    }
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _mobileInfoValue(Book book, _LibraryField field) {
    return _fieldDisplayValue(book, field);
  }

  bool _shouldHideMobileInfoValue(_LibraryField field, String value) {
    if (value == '-') {
      return true;
    }
    if (field == _LibraryField.rating && value == 'No rating') {
      return true;
    }
    return false;
  }

  void _resetSortAndFilter() {
    setState(() {
      _filterField = _LibraryField.status;
      _filterValue = 'all';
      _pagesFilterMinController.clear();
      _pagesFilterMaxController.clear();
      _sortField = _LibraryField.title;
      _isSortAscending = true;
      _columnOrder = _defaultDesktopFields;
      _mobileInfoFields = _defaultMobileInfoFields;
    });
  }

  Future<void> _openSortFilterSheet(
    ThemeData theme, {
    required bool isMobile,
    required _LibraryControlPanel panel,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, sheetSetState) {
            void refreshSheet() {
              sheetSetState(() {});
            }

            final showAllSections = !isMobile;
            final showSortSection =
                showAllSections || panel == _LibraryControlPanel.sort;
            final showFilterSection =
                showAllSections || panel == _LibraryControlPanel.filter;
            final showDisplaySection =
                isMobile && (showAllSections || panel == _LibraryControlPanel.display);

            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  16 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showSortSection) ...[
                      Text('Sort by:', style: theme.textTheme.labelMedium),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          FilledButton.tonal(
                            onPressed: () {
                              setState(() {
                                _isSortAscending = !_isSortAscending;
                              });
                              refreshSheet();
                            },
                            style: FilledButton.styleFrom(
                              foregroundColor: theme.colorScheme.onPrimaryContainer,
                              backgroundColor: theme.colorScheme.primaryContainer,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: AnimatedRotation(
                              duration: const Duration(milliseconds: 180),
                              turns: _isSortAscending ? 0 : 0.5,
                              child: const Icon(Icons.arrow_upward),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 4,
                            child: DropdownButtonFormField<_LibraryField>(
                              initialValue: _sortField,
                              items: _buildFieldItems(_LibraryField.values),
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
                        ],
                      ),
                    ],
                    if (showFilterSection) ...[
                      if (showSortSection) const SizedBox(height: 16),
                      Text('Filter by:', style: theme.textTheme.labelMedium),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<_LibraryField>(
                        initialValue: _filterField,
                        items: _buildFieldItems(_LibraryField.values),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _filterField = value;
                            _filterValue = 'all';
                            if (_filterField != _LibraryField.pages) {
                              _pagesFilterMinController.clear();
                              _pagesFilterMaxController.clear();
                            }
                          });
                          refreshSheet();
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_filterField == _LibraryField.pages) ...[
                        Text('Range:', style: theme.textTheme.labelMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _pagesFilterMinController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Min pages',
                                ),
                                onChanged: (_) {
                                  setState(() {});
                                  refreshSheet();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _pagesFilterMaxController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Max pages',
                                ),
                                onChanged: (_) {
                                  setState(() {});
                                  refreshSheet();
                                },
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
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
                                child: Text(_formatFilterOptionLabel(value)),
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
                    ],
                    if (showDisplaySection) ...[
                      if (showSortSection || showFilterSection)
                        const SizedBox(height: 20),
                      Text('Display:', style: theme.textTheme.labelMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Choose up to 6 info fields for mobile cards.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._configurableFields.map((field) {
                        final isChecked = _mobileInfoFields.contains(field);
                        final disableUnchecked =
                            !isChecked &&
                            _mobileInfoFields.length >= _maxMobileInfoColumns;
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          value: isChecked,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(_fieldLabel(field)),
                          onChanged: disableUnchecked
                              ? null
                              : (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  _toggleMobileInfoField(field, value);
                                  refreshSheet();
                                },
                        );
                      }),
                    ],
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
        _books = _books.where((entry) => entry.id != result.deletedBookId).toList();
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
      0 => ('Home', _buildStartTab(theme)),
      1 => ('Library', _buildLibraryTab(theme, books)),
      _ => ('Statistics', _buildStatisticsTab(theme)),
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
                    Text('Schema: ${isDarkMode ? 'Dark' : 'Light'}'),
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





