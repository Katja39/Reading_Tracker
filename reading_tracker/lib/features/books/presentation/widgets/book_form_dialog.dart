//
// Shared book form dialog for creating and editing book metadata
//


import 'package:flutter/material.dart';

import '../../domain/models/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../../../metadata/domain/models/book_enrichment.dart';

// Return value containing normalized form input
class BookFormResult {
  const BookFormResult({
    required this.title,
    required this.author,
    required this.status,
    required this.rating,
    required this.isbn,
    required this.pages,
    required this.publisher,
    required this.languageCode,
    required this.coverUrl,
    required this.seriesId,
    required this.volume,
    required this.genreId,
    required this.ageCategory,
    required this.releaseDate,
    required this.format,
    required this.description,
    required this.currentPage,
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
  final String? seriesId;
  final int? volume;
  final String? genreId;
  final String? ageCategory;
  final String? releaseDate;
  final String? format;
  final String? description;
  final int? currentPage;
}

// Dialog that captures book metadata, optional rating, series, and genre data
class BookFormDialog extends StatefulWidget {
  const BookFormDialog({
    super.key,
    required this.title,
    required this.submitLabel,
    required this.statuses,
    required this.repository,
    this.initialBook,
    this.initialStatus,
    this.initialRating,
    this.enableInlineRating = false,
    this.onBooksChanged,
  });

  final String title;
  final String submitLabel;
  final List<String> statuses;
  final BookRepository repository;
  final Book? initialBook;
  final String? initialStatus;
  final double? initialRating;
  final bool enableInlineRating;
  final Future<void> Function()? onBooksChanged;

  @override
  State<BookFormDialog> createState() => _BookFormDialogState();
}

// Owns form controllers, selected options, async loading state, and submit handling
class _BookFormDialogState extends State<BookFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _isbnController;
  late final TextEditingController _pagesController;
  late final TextEditingController _publisherController;
  late final TextEditingController _languageCodeController;
  late final TextEditingController _newSeriesController;
  late final TextEditingController _volumeController;
  late final TextEditingController _genreIdController;
  late final TextEditingController _releaseDateController;
  late final TextEditingController _currentPageController;
  late final TextEditingController _descriptionController;
  late final MenuController _genreMenuController;
  late final MenuController _seriesMenuController;
  late final String _defaultStatus;
  late String _selectedStatus;
  late List<String> _genreOptions;
  late bool _isSeriesEnabled;
  String? _selectedAgeCategory;
  String? _selectedFormat;
  String? _coverUrl;
  double? _selectedRating;
  bool _isAutoFilling = false;
  bool _isLoadingSeries = false;
  bool _isCreatingSeries = false;
  bool _showCustomGenreInput = false;
  List<String> _seriesOptions = const [];
  String? _selectedSeries;
  String? _selectedGenre;
  String? _autoFillMessage;

  // Whether the dialog is editing an existing book
  bool get _isEditing => widget.initialBook != null;

  // Initializes controllers from the existing book or empty add-book defaults
  @override
  void initState() {
    super.initState();
    final initialBook = widget.initialBook;
    _titleController = TextEditingController(text: initialBook?.title ?? '');
    _authorController = TextEditingController(text: initialBook?.author ?? '');
    _isbnController = TextEditingController(text: initialBook?.isbn ?? '');
    _pagesController = TextEditingController(
      text: initialBook?.pages?.toString() ?? '',
    );
    _publisherController = TextEditingController(
      text: initialBook?.publisher ?? '',
    );
    _languageCodeController = TextEditingController(
      text: initialBook?.languageCode ?? '',
    );
    _newSeriesController = TextEditingController();
    _volumeController = TextEditingController(
      text: initialBook?.volume?.toString() ?? '',
    );
    _genreIdController = TextEditingController(text: initialBook?.genreId ?? '');
    _releaseDateController = TextEditingController(
      text: initialBook?.releaseDate ?? '',
    );
    _currentPageController = TextEditingController(
      text: initialBook?.currentPage?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: initialBook?.description ?? '',
    );
    _genreMenuController = MenuController();
    _seriesMenuController = MenuController();
    _defaultStatus = widget.statuses.first;
    _selectedStatus = _resolveInitialStatus(initialBook);
    _selectedAgeCategory = initialBook?.ageCategory;
    _selectedFormat = initialBook?.format;
    _coverUrl = initialBook?.coverUrl;
    _selectedRating = widget.enableInlineRating ? widget.initialRating : null;
    _isSeriesEnabled =
        initialBook?.seriesId != null && initialBook!.seriesId!.isNotEmpty;
    _selectedSeries = initialBook?.seriesId;
    _selectedGenre = initialBook?.genreId;
    _genreOptions = [
      if (initialBook?.genreId != null && initialBook!.genreId!.isNotEmpty)
        initialBook.genreId!,
    ];
    _titleController.addListener(_handleRequiredFieldChanged);
    _authorController.addListener(_handleRequiredFieldChanged);

    _loadGenreOptions();
    _loadSeriesOptions();
  }

  // Cleans up every controller created for the form
  @override
  void dispose() {
    _titleController.removeListener(_handleRequiredFieldChanged);
    _authorController.removeListener(_handleRequiredFieldChanged);
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _pagesController.dispose();
    _publisherController.dispose();
    _languageCodeController.dispose();
    _newSeriesController.dispose();
    _volumeController.dispose();
    _genreIdController.dispose();
    _releaseDateController.dispose();
    _currentPageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Enables submit only after required text fields are filled
  bool get _isSubmitEnabled {
    return _titleController.text.trim().isNotEmpty &&
        _authorController.text.trim().isNotEmpty;
  }

  // Refreshes button state when required fields change
  void _handleRequiredFieldChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  // Chooses a valid initial status from the book, caller, or default list
  String _resolveInitialStatus(Book? initialBook) {
    final candidate = initialBook?.status ?? widget.initialStatus;
    if (candidate != null && widget.statuses.contains(candidate)) {
      return candidate;
    }
    return _defaultStatus;
  }

  // Normalizes form values and returns them to the caller
  void _submit() {
    final pagesText = _pagesController.text.trim();
    final pages = pagesText.isEmpty ? null : int.tryParse(pagesText);
    final currentPageText = _currentPageController.text.trim();
    final currentPage = currentPageText.isEmpty
        ? null
        : int.tryParse(currentPageText);
    final volumeText = _volumeController.text.trim();
    final volume = volumeText.isEmpty ? null : int.tryParse(volumeText);

    final selectedSeries = _isSeriesEnabled
        ? (_selectedSeries ?? _newSeriesController.text.trim())
        : '';
    final normalizedSeries = selectedSeries.trim();

    Navigator.of(context).pop(
      BookFormResult(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        status: _selectedStatus,
        rating: widget.enableInlineRating && _selectedStatus == 'read'
            ? _selectedRating
            : null,
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
        seriesId: normalizedSeries.isEmpty ? null : normalizedSeries,
        volume: _isSeriesEnabled ? volume : null,
        genreId: _genreIdController.text.trim().isEmpty
            ? null
            : _genreIdController.text.trim(),
        ageCategory: _selectedAgeCategory,
        releaseDate: _releaseDateController.text.trim().isEmpty
            ? null
            : _releaseDateController.text.trim(),
        format: _selectedFormat,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        currentPage: _selectedStatus == 'reading' ? currentPage : null,
      ),
    );
  }

  // Creates a new genre option from the custom input
  void _addCustomGenre() {
    final value = _genreIdController.text.trim();
    if (value.isEmpty) {
      return;
    }
    widget.repository.createGenre(name: value).then((_) => _loadGenreOptions());
    setState(() {
      _selectedGenre = value;
      _showCustomGenreInput = false;
    });
  }

  // Clears the selected genre from the current form state
  void _removeSelectedGenre() {
    final selected = _selectedGenre;
    if (selected == null) {
      return;
    }
    setState(() {
      _genreOptions = _genreOptions.where((genre) => genre != selected).toList();
      _selectedGenre = null;
      _genreIdController.clear();
    });
  }

  // Confirms genre deletion when existing books reference it
  Future<void> _confirmAndRemoveGenre(String genre) async {
    final books = await widget.repository.fetchBooks();
    final linkedBooks = books.where((book) => book.genreId == genre).toList();

    var shouldDelete = true;
    if (linkedBooks.isNotEmpty && mounted) {
      shouldDelete =
          await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Delete genre?'),
                content: Text(
                  'The genre "$genre" is linked to ${linkedBooks.length} book(s). '
                  'These books will keep all data, but genre will be cleared. Continue?',
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
          ) ??
          false;
    }

    if (!shouldDelete) {
      return;
    }

    await widget.repository.deleteGenre(name: genre);

    if (!mounted) {
      return;
    }

    setState(() {
      _genreOptions = _genreOptions.where((item) => item != genre).toList();
      if (_selectedGenre == genre) {
        _selectedGenre = null;
        _genreIdController.clear();
      }
    });
    await widget.onBooksChanged?.call();
  }

  // Loads available series names for the series picker
  Future<void> _loadSeriesOptions() async {
    setState(() {
      _isLoadingSeries = true;
    });
    try {
      final options = await widget.repository.fetchSeriesNames();
      if (!mounted) {
        return;
      }
      setState(() {
        _seriesOptions = options;
        if (_selectedSeries != null && !_seriesOptions.contains(_selectedSeries)) {
          _newSeriesController.text = _selectedSeries!;
          _selectedSeries = null;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _autoFillMessage = 'Could not load series list right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSeries = false;
        });
      }
    }
  }

  // Loads available genre names for the genre picker
  Future<void> _loadGenreOptions() async {
    try {
      final options = await widget.repository.fetchGenreNames();
      if (!mounted) {
        return;
      }
      setState(() {
        _genreOptions = {
          ..._genreOptions,
          ...options,
        }.toList();
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _autoFillMessage = 'Could not load genre list right now.';
      });
    }
  }

  // Creates a new series and selects it after the list refreshes
  Future<void> _createSeries() async {
    final name = _newSeriesController.text.trim();
    if (name.isEmpty) {
      return;
    }
    setState(() {
      _isCreatingSeries = true;
      _autoFillMessage = null;
    });
    try {
      await widget.repository.createSeries(name: name);
      if (!mounted) {
        return;
      }
      await _loadSeriesOptions();
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedSeries = name;
        _newSeriesController.clear();
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _autoFillMessage = 'Could not create series: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingSeries = false;
        });
      }
    }
  }

  // Confirms series deletion when existing books reference it
  Future<void> _confirmAndRemoveSeries(String series) async {
    final books = await widget.repository.fetchBooks();
    final linkedBooks = books.where((book) => book.seriesId == series).toList();

    var shouldDelete = true;
    if (linkedBooks.isNotEmpty && mounted) {
      shouldDelete =
          await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Delete series?'),
                content: Text(
                  'The series "$series" is linked to ${linkedBooks.length} book(s). '
                  'These books will keep all data, but series and volume will be cleared. Continue?',
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
          ) ??
          false;
    }

    if (!shouldDelete) {
      return;
    }

    await widget.repository.deleteSeries(name: series);
    if (!mounted) {
      return;
    }
    setState(() {
      _seriesOptions = _seriesOptions.where((item) => item != series).toList();
      if (_selectedSeries == series) {
        _selectedSeries = null;
        _newSeriesController.clear();
        _volumeController.clear();
      }
    });
    await widget.onBooksChanged?.call();
  }

  // Fetches metadata for the entered ISBN and applies it to the form
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

      _applyEnrichment(enrichment);
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

  // Applies fetched book metadata without overwriting fields with empty values
  void _applyEnrichment(BookEnrichment enrichment) {
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
      if (enrichment.languageCode != null && enrichment.languageCode!.isNotEmpty) {
        _languageCodeController.text = enrichment.languageCode!;
      }
      if (enrichment.seriesId != null && enrichment.seriesId!.isNotEmpty) {
        _isSeriesEnabled = true;
        if (_seriesOptions.contains(enrichment.seriesId)) {
          _selectedSeries = enrichment.seriesId;
          _newSeriesController.clear();
        } else {
          _selectedSeries = null;
          _newSeriesController.text = enrichment.seriesId!;
        }
      }
      if (enrichment.genreId != null && enrichment.genreId!.isNotEmpty) {
        if (!_genreOptions.contains(enrichment.genreId!)) {
          _genreOptions = [..._genreOptions, enrichment.genreId!];
        }
        _selectedGenre = enrichment.genreId!;
        _genreIdController.text = enrichment.genreId!;
      }
      if (enrichment.ageCategory != null && enrichment.ageCategory!.isNotEmpty) {
        _selectedAgeCategory = enrichment.ageCategory;
      }
      if (enrichment.releaseDate != null && enrichment.releaseDate!.isNotEmpty) {
        _releaseDateController.text = enrichment.releaseDate!;
      }
      if (enrichment.format != null && enrichment.format!.isNotEmpty) {
        _selectedFormat = enrichment.format;
      }
      if (enrichment.description != null && enrichment.description!.isNotEmpty) {
        _descriptionController.text = enrichment.description!;
      }
      _coverUrl = enrichment.coverUrl;
      _autoFillMessage = 'Fields updated from Open Library.';
    });
  }

  // Switches field groups between stacked and two-column layouts
  Widget _buildResponsiveFields(Widget left, Widget right, bool useTwoColumns) {
    if (!useTwoColumns) {
      return Column(
        children: [
          left,
          const SizedBox(height: 16),
          right,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  // Builds the add or edit dialog form
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = screenWidth >= 1200
        ? 760.0
        : screenWidth >= 800
            ? 620.0
            : screenWidth * 0.92;
    final useTwoColumns = dialogWidth >= 620;

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildResponsiveFields(
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: _authorController,
                  decoration: const InputDecoration(labelText: 'Author'),
                ),
                useTwoColumns,
              ),
              const SizedBox(height: 16),
              _buildResponsiveFields(
                TextField(
                  controller: _isbnController,
                  decoration: const InputDecoration(labelText: 'ISBN (optional)'),
                ),
                TextField(
                  controller: _pagesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Pages (optional)'),
                ),
                useTwoColumns,
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
              _buildResponsiveFields(
                TextField(
                  controller: _publisherController,
                  decoration: const InputDecoration(
                    labelText: 'Publisher (optional)',
                  ),
                ),
                TextField(
                  controller: _languageCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Language (optional)',
                    hintText: 'e.g. en, de',
                  ),
                ),
                useTwoColumns,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _isSeriesEnabled,
                contentPadding: EdgeInsets.zero,
                title: const Text('Part of a series'),
                onChanged: (value) {
                  setState(() {
                    _isSeriesEnabled = value ?? false;
                    if (!_isSeriesEnabled) {
                      _selectedSeries = null;
                      _newSeriesController.clear();
                      _volumeController.clear();
                    }
                  });
                },
              ),
              if (_isSeriesEnabled) ...[
                const SizedBox(height: 8),
                MenuAnchor(
                  controller: _seriesMenuController,
                  menuChildren: [
                    MenuItemButton(
                      onPressed: () {
                        setState(() {
                          _selectedSeries = null;
                          _volumeController.clear();
                        });
                        _seriesMenuController.close();
                      },
                      child: const Text('Select existing series'),
                    ),
                    ..._seriesOptions.map(
                      (series) => MenuItemButton(
                        closeOnActivate: false,
                        onPressed: () {
                          setState(() {
                            _selectedSeries = series;
                          });
                          _seriesMenuController.close();
                        },
                        trailingIcon: IconButton(
                          tooltip: 'Delete series',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            _confirmAndRemoveSeries(series);
                          },
                        ),
                        child: Text(series),
                      ),
                    ),
                  ],
                  builder: (context, controller, child) {
                    return OutlinedButton(
                      onPressed: _isLoadingSeries
                          ? null
                          : () {
                              if (controller.isOpen) {
                                controller.close();
                              } else {
                                controller.open();
                              }
                            },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _selectedSeries ??
                              (_isLoadingSeries
                                  ? 'Series (loading...)'
                                  : 'Series (existing)'),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newSeriesController,
                        decoration: const InputDecoration(
                          labelText: 'New series name',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _isCreatingSeries ? null : _createSeries,
                      child: Text(_isCreatingSeries ? 'Adding...' : 'Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _volumeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Volume'),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: MenuAnchor(
                      controller: _genreMenuController,
                      menuChildren: [
                        MenuItemButton(
                          onPressed: () {
                            setState(() {
                              _selectedGenre = null;
                              _genreIdController.clear();
                            });
                            _genreMenuController.close();
                          },
                          child: const Text('No selection'),
                        ),
                        ..._genreOptions.map(
                          (genre) => MenuItemButton(
                            closeOnActivate: false,
                            onPressed: () {
                              setState(() {
                                _selectedGenre = genre;
                                _genreIdController.text = genre;
                                _showCustomGenreInput = false;
                              });
                              _genreMenuController.close();
                            },
                            trailingIcon: IconButton(
                              tooltip: 'Delete genre',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                _confirmAndRemoveGenre(genre);
                              },
                            ),
                            child: Text(genre),
                          ),
                        ),
                      ],
                      builder: (context, controller, child) {
                        return OutlinedButton(
                          onPressed: () {
                            if (controller.isOpen) {
                              controller.close();
                            } else {
                              controller.open();
                            }
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(_selectedGenre ?? 'Genre'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _showCustomGenreInput = !_showCustomGenreInput;
                      });
                    },
                    child: Text(_showCustomGenreInput ? 'Hide' : 'Custom'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _selectedGenre == null ? null : _removeSelectedGenre,
                    tooltip: 'Delete genre',
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              if (_showCustomGenreInput) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _genreIdController,
                        decoration: InputDecoration(
                          labelText: _isEditing
                              ? 'Custom genre (optional)'
                              : 'Custom genre (optional)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _addCustomGenre,
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              _buildResponsiveFields(
                DropdownButtonFormField<String?>(
                  initialValue: _selectedAgeCategory,
                  decoration: const InputDecoration(
                    labelText: 'Age category (optional)',
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Not set')),
                    DropdownMenuItem(value: 'children', child: Text('Children')),
                    DropdownMenuItem(
                      value: 'middle_grade',
                      child: Text('Middle Grade'),
                    ),
                    DropdownMenuItem(
                      value: 'young_adult',
                      child: Text('Young Adult'),
                    ),
                    DropdownMenuItem(
                      value: 'new_adult',
                      child: Text('New Adult'),
                    ),
                    DropdownMenuItem(value: 'adult', child: Text('Adult')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedAgeCategory = value;
                    });
                  },
                ),
                DropdownButtonFormField<String?>(
                  initialValue: _selectedFormat,
                  decoration: const InputDecoration(
                    labelText: 'Format (optional)',
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Not set')),
                    DropdownMenuItem(
                      value: 'hardcover',
                      child: Text('Hardcover'),
                    ),
                    DropdownMenuItem(
                      value: 'paperback',
                      child: Text('Paperback'),
                    ),
                    DropdownMenuItem(value: 'ebook', child: Text('Ebook')),
                    DropdownMenuItem(
                      value: 'audiobook',
                      child: Text('Audiobook'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedFormat = value;
                    });
                  },
                ),
                useTwoColumns,
              ),
              const SizedBox(height: 16),
              _buildResponsiveFields(
                TextField(
                  controller: _releaseDateController,
                  decoration: const InputDecoration(
                    labelText: 'Release date (optional)',
                    hintText: 'YYYY-MM-DD',
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
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
                      if (_selectedStatus != 'read') {
                        _selectedRating = null;
                      }
                    });
                  },
                ),
                useTwoColumns,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
              ),
              if (widget.enableInlineRating && _selectedStatus == 'read') ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rating',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...List.generate(5, (index) {
                      final starValue = index + 1;
                      final isSelected = _selectedRating != null &&
                          _selectedRating! >= starValue;
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedRating = starValue.toDouble();
                          });
                        },
                        icon: Icon(
                          isSelected ? Icons.star : Icons.star_border,
                        ),
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitEnabled ? _submit : null,
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}


