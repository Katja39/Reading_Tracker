part of 'book_detail_page.dart';

class _EditBookDialogResult {
  const _EditBookDialogResult({
    required this.title,
    required this.author,
    required this.status,
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
  });

  final String title;
  final String author;
  final String status;
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
}

class _EditBookDialog extends StatefulWidget {
  const _EditBookDialog({
    required this.book,
    required this.statuses,
    required this.repository,
  });

  final Book book;
  final List<String> statuses;
  final BookRepository repository;

  @override
  State<_EditBookDialog> createState() => _EditBookDialogState();
}

class _EditBookDialogState extends State<_EditBookDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _isbnController;
  late final TextEditingController _pagesController;
  late final TextEditingController _publisherController;
  late final TextEditingController _languageCodeController;
  late final TextEditingController _newSeriesController;
  late final TextEditingController _volumeController;
  late final TextEditingController _genreIdController;
  String? _selectedAgeCategory;
  late final TextEditingController _releaseDateController;
  String? _selectedFormat;
  String? _coverUrl;
  late String _selectedStatus;
  bool _isAutoFilling = false;
  bool _showCustomGenreInput = false;
  bool _isSeriesEnabled = false;
  bool _isLoadingSeries = false;
  bool _isCreatingSeries = false;
  late List<String> _genreOptions;
  String? _selectedGenre;
  late final MenuController _genreMenuController;
  late final MenuController _seriesMenuController;
  List<String> _seriesOptions = const [];
  String? _selectedSeries;
  String? _autoFillMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _isbnController = TextEditingController(text: widget.book.isbn ?? '');
    _pagesController = TextEditingController(
      text: widget.book.pages?.toString() ?? '',
    );
    _publisherController = TextEditingController(
      text: widget.book.publisher ?? '',
    );
    _languageCodeController = TextEditingController(
      text: widget.book.languageCode ?? '',
    );
    _newSeriesController = TextEditingController();
    _volumeController = TextEditingController(
      text: widget.book.volume?.toString() ?? '',
    );
    _genreIdController = TextEditingController(text: widget.book.genreId ?? '');
    _genreOptions = const [];
    if (widget.book.genreId != null &&
        widget.book.genreId!.isNotEmpty &&
        !_genreOptions.contains(widget.book.genreId)) {
      _genreOptions = [..._genreOptions, widget.book.genreId!];
    }
    _selectedGenre = widget.book.genreId;
    _genreMenuController = MenuController();
    _seriesMenuController = MenuController();
    _selectedAgeCategory = widget.book.ageCategory;
    _releaseDateController = TextEditingController(
      text: widget.book.releaseDate ?? '',
    );
    _selectedFormat = widget.book.format;
    _coverUrl = widget.book.coverUrl;
    _isSeriesEnabled =
        widget.book.seriesId != null && widget.book.seriesId!.isNotEmpty;
    _selectedSeries = widget.book.seriesId;
    _selectedStatus = widget.statuses.contains(widget.book.status)
        ? widget.book.status
        : widget.statuses.first;
    _loadGenreOptions();
    _loadSeriesOptions();
  }

  @override
  void dispose() {
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
    super.dispose();
  }

  void _submit() {
    final pagesText = _pagesController.text.trim();
    final pages = pagesText.isEmpty ? null : int.tryParse(pagesText);
    final volumeText = _volumeController.text.trim();
    final volume = volumeText.isEmpty ? null : int.tryParse(volumeText);

    final selectedSeries = _isSeriesEnabled
        ? (_selectedSeries ?? _newSeriesController.text.trim())
        : '';
    final normalizedSeries = selectedSeries.trim();
    final normalizedVolume = _isSeriesEnabled ? volume : null;

    Navigator.of(context).pop(
      _EditBookDialogResult(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        status: _selectedStatus,
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
        volume: normalizedVolume,
        genreId: _genreIdController.text.trim().isEmpty
            ? null
            : _genreIdController.text.trim(),
        ageCategory: _selectedAgeCategory,
        releaseDate: _releaseDateController.text.trim().isEmpty
            ? null
            : _releaseDateController.text.trim(),
        format: _selectedFormat,
      ),
    );
  }

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

  void _removeSelectedGenre() {
    final selected = _selectedGenre;
    if (selected == null) {
      return;
    }
    setState(() {
      _genreOptions = _genreOptions
          .where((genre) => genre != selected)
          .toList();
      _selectedGenre = null;
      _genreIdController.clear();
    });
  }

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
  }

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
        if (_selectedSeries != null &&
            !_seriesOptions.contains(_selectedSeries)) {
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

  Future<void> _loadGenreOptions() async {
    try {
      final options = await widget.repository.fetchGenreNames();
      if (!mounted) {
        return;
      }
      setState(() {
        _genreOptions = options;
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
        if (enrichment.ageCategory != null &&
            enrichment.ageCategory!.isNotEmpty) {
          _selectedAgeCategory = enrichment.ageCategory;
        }
        if (enrichment.releaseDate != null &&
            enrichment.releaseDate!.isNotEmpty) {
          _releaseDateController.text = enrichment.releaseDate!;
        }
        if (enrichment.format != null && enrichment.format!.isNotEmpty) {
          _selectedFormat = enrichment.format;
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
      title: const Text('Edit Book'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(labelText: 'Author'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _isbnController,
              decoration: const InputDecoration(labelText: 'ISBN (optional)'),
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
              decoration: const InputDecoration(labelText: 'Pages (optional)'),
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
            MenuAnchor(
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
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showCustomGenreInput = !_showCustomGenreInput;
                    });
                  },
                  child: Text(_showCustomGenreInput ? 'Hide custom' : 'Custom'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _selectedGenre == null
                      ? null
                      : _removeSelectedGenre,
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
                      decoration: const InputDecoration(
                        labelText: 'Genre (custom, optional)',
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
                DropdownMenuItem(value: 'new_adult', child: Text('New Adult')),
                DropdownMenuItem(value: 'adult', child: Text('Adult')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedAgeCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _releaseDateController,
              decoration: const InputDecoration(
                labelText: 'Release date (optional)',
                hintText: 'YYYY-MM-DD',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              initialValue: _selectedFormat,
              decoration: const InputDecoration(labelText: 'Format (optional)'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Not set')),
                DropdownMenuItem(value: 'hardcover', child: Text('Hardcover')),
                DropdownMenuItem(value: 'paperback', child: Text('Paperback')),
                DropdownMenuItem(value: 'ebook', child: Text('Ebook')),
                DropdownMenuItem(value: 'audiobook', child: Text('Audiobook')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFormat = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: widget.statuses
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
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
          ],
        ),
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

class _EditRatingDialogResult {
  const _EditRatingDialogResult({required this.rating});

  final double? rating;
}

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
