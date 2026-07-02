import 'package:flutter/material.dart';

import '../../domain/models/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../widgets/book_form_dialog.dart';
import '../../../../shared/widgets/error_banner.dart';

part 'book_detail_dialogs.dart';
part 'book_detail_widgets.dart';

class BookDetailResult {
  const BookDetailResult._({this.updatedBook, this.deletedBookId});

  final Book? updatedBook;
  final String? deletedBookId;

  bool get isDeleted => deletedBookId != null;

  factory BookDetailResult.updated(Book book) {
    return BookDetailResult._(updatedBook: book);
  }

  factory BookDetailResult.deleted(String bookId) {
    return BookDetailResult._(deletedBookId: bookId);
  }
}

class BookDetailPage extends StatefulWidget {
  const BookDetailPage({
    super.key,
    required this.book,
    required this.repository,
    required this.statuses,
  });

  final Book book;
  final BookRepository repository;
  final List<String> statuses;

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late Book _book;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
  }

  Future<void> _showEditDialog() async {
    final submitted = await showDialog<BookFormResult>(
      context: context,
      builder: (context) {
        return _EditBookDialog(
          book: _book,
          statuses: widget.statuses,
          repository: widget.repository,
        );
      },
    );

    if (submitted == null) {
      return;
    }

    final title = submitted.title;
    final author = submitted.author;
    final status = submitted.status;
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
    final description = submitted.description;
    final ratingForStatus = status == 'read' ? _book.rating : null;
    final shouldPromptForRating =
        _book.status != 'read' && status == 'read' && ratingForStatus == null;

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

    final localUpdatedBook = Book(
      id: _book.id,
      userId: _book.userId,
      title: title,
      author: author,
      status: status,
      rating: ratingForStatus,
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
      description: description,
      readingStartDate: _book.readingStartDate,
      readingEndDate: _book.readingEndDate,
      createdAt: _book.createdAt,
      updatedAt: _book.updatedAt,
    );
    var openRatingDialogAfterSave = false;

    try {
      await widget.repository.updateBook(
        id: _book.id,
        userId: _book.userId,
        title: title,
        author: author,
        status: status,
        rating: ratingForStatus,
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
        description: description,
        readingStartDate: _book.readingStartDate,
        readingEndDate: _book.readingEndDate,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _book = localUpdatedBook;
      });
      openRatingDialogAfterSave = shouldPromptForRating;
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

    if (openRatingDialogAfterSave && mounted) {
      await _showEditRatingDialog();
    }
  }

  Future<void> _showEditRatingDialog() async {
    final submitted = await showDialog<_EditRatingDialogResult>(
      context: context,
      builder: (context) {
        return _EditRatingDialog(initialRating: _book.rating);
      },
    );

    if (submitted == null) {
      return;
    }

    final rating = submitted.rating;

    final updatedStatus = rating == null ? _book.status : 'read';

    if (rating == _book.rating && updatedStatus == _book.status) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final localUpdatedBook = Book(
      id: _book.id,
      userId: _book.userId,
      title: _book.title,
      author: _book.author,
      status: updatedStatus,
      rating: rating,
      isbn: _book.isbn,
      pages: _book.pages,
      publisher: _book.publisher,
      languageCode: _book.languageCode,
      coverUrl: _book.coverUrl,
      seriesId: _book.seriesId,
      volume: _book.volume,
      genreId: _book.genreId,
      ageCategory: _book.ageCategory,
      releaseDate: _book.releaseDate,
      format: _book.format,
      description: _book.description,
      readingStartDate: _book.readingStartDate,
      readingEndDate: _book.readingEndDate,
      createdAt: _book.createdAt,
      updatedAt: _book.updatedAt,
    );

    try {
      await widget.repository.updateBook(
        id: _book.id,
        userId: _book.userId,
        title: _book.title,
        author: _book.author,
        status: updatedStatus,
        rating: rating,
        isbn: _book.isbn,
        pages: _book.pages,
        publisher: _book.publisher,
        languageCode: _book.languageCode,
        coverUrl: _book.coverUrl,
        seriesId: _book.seriesId,
        volume: _book.volume,
        genreId: _book.genreId,
        ageCategory: _book.ageCategory,
        releaseDate: _book.releaseDate,
        format: _book.format,
        description: _book.description,
        readingStartDate: _book.readingStartDate,
        readingEndDate: _book.readingEndDate,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _book = localUpdatedBook;
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

  Future<void> _showEditStatusDialog() async {
    var selectedStatus = _book.status;
    final submitted = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.statuses.map((status) {
                  return RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_formatReadableLabel(status)),
                    value: status,
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setDialogState(() {
                        selectedStatus = value;
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(selectedStatus),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (submitted == null || submitted == _book.status) {
      return;
    }

    final updatedRating = submitted == 'read' ? _book.rating : null;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final localUpdatedBook = Book(
      id: _book.id,
      userId: _book.userId,
      title: _book.title,
      author: _book.author,
      status: submitted,
      rating: updatedRating,
      isbn: _book.isbn,
      pages: _book.pages,
      publisher: _book.publisher,
      languageCode: _book.languageCode,
      coverUrl: _book.coverUrl,
      seriesId: _book.seriesId,
      volume: _book.volume,
      genreId: _book.genreId,
      ageCategory: _book.ageCategory,
      releaseDate: _book.releaseDate,
      format: _book.format,
      description: _book.description,
      readingStartDate: _book.readingStartDate,
      readingEndDate: _book.readingEndDate,
      createdAt: _book.createdAt,
      updatedAt: _book.updatedAt,
    );

    try {
      await widget.repository.updateBook(
        id: _book.id,
        userId: _book.userId,
        title: _book.title,
        author: _book.author,
        status: submitted,
        rating: updatedRating,
        isbn: _book.isbn,
        pages: _book.pages,
        publisher: _book.publisher,
        languageCode: _book.languageCode,
        coverUrl: _book.coverUrl,
        seriesId: _book.seriesId,
        volume: _book.volume,
        genreId: _book.genreId,
        ageCategory: _book.ageCategory,
        releaseDate: _book.releaseDate,
        format: _book.format,
        description: _book.description,
        readingStartDate: _book.readingStartDate,
        readingEndDate: _book.readingEndDate,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _book = localUpdatedBook;
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

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Book'),
          content: Text('Delete "${_book.title}"?'),
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
      _errorMessage = null;
    });

    try {
      await widget.repository.deleteBook(id: _book.id);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(BookDetailResult.deleted(_book.id));
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

  void _closePage() {
    Navigator.of(context).pop(BookDetailResult.updated(_book));
  }

  String _formatReadableLabel(String? value) {
    if (value == null || value.isEmpty) {
      return '-';
    }
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  bool get _hasDescription {
    return _book.description != null && _book.description!.trim().isNotEmpty;
  }

  String get _descriptionDisplayValue {
    return _book.description?.trim() ?? '';
  }

  bool get _hasSeries {
    return _book.seriesId != null && _book.seriesId!.isNotEmpty;
  }

  String get _seriesDisplayValue {
    if (!_hasSeries) {
      return '';
    }
    if (_book.volume == null) {
      return _book.seriesId!;
    }
    return '${_book.seriesId!} · Vol. ${_book.volume}';
  }
  double _responsiveContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    if (screenWidth >= 1600) {
      return 1100;
    }
    if (screenWidth >= 1200) {
      return 920;
    }
    if (screenWidth >= 900) {
      return 760;
    }
    return screenWidth;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxWidth = _responsiveContentWidth(context);

    return WillPopScope(
      onWillPop: () async {
        _closePage();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _closePage,
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(_book.title),
          backgroundColor: theme.colorScheme.surface,
          actions: [
            IconButton(
              onPressed: _isSaving ? null : _showEditDialog,
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
            ),
            IconButton(
              onPressed: _isSaving ? null : _confirmDelete,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_book.coverUrl != null &&
                                _book.coverUrl!.isNotEmpty) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _book.coverUrl!,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      const SizedBox.shrink(),
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                            Text(
                              _book.title,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall,
                            ),
                            if (_hasSeries) ...[
                              const SizedBox(height: 6),
                              Text(
                                _seriesDisplayValue,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              'by ${_book.author}',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 10),
                            _BookHeaderRating(
                              rating: _book.rating,
                              onTap: _isSaving ? null : _showEditRatingDialog,
                            ),
                            const SizedBox(height: 10),
                            _BookStatusButton(
                              status: _formatReadableLabel(_book.status),
                              onPressed: _isSaving ? null : _showEditStatusDialog,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 20),
                      _BookDetailSection(
                        title: 'Book info',
                        children: [
                          if (_hasDescription)
                            _BookDetailRow(
                              label: 'Description',
                              value: _descriptionDisplayValue,
                            ),
                          _BookDetailRow(
                            label: 'Genre',
                            value: _book.genreId ?? '-',
                          ),
                          _BookDetailRow(
                            label: 'Age category',
                            value: _formatReadableLabel(_book.ageCategory),
                          ),
                          _BookDetailRow(
                            label: 'Format',
                            value: _formatReadableLabel(_book.format),
                          ),
                          _BookDetailRow(
                            label: 'Pages',
                            value: _book.pages?.toString() ?? '-',
                          ),
                        ],
                      ),
                      if (_hasSeries) ...[
                        const SizedBox(height: 20),
                        _BookDetailSection(
                          title: 'Series',
                          children: [
                            _BookDetailRow(
                              label: 'Series',
                              value: _book.seriesId!,
                            ),
                            if (_book.volume != null)
                              _BookDetailRow(
                                label: 'Volume',
                                value: _book.volume.toString(),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),
                      _BookDetailSection(
                        title: 'Publication',
                        children: [
                          _BookDetailRow(label: 'ISBN', value: _book.isbn ?? '-'),
                          _BookDetailRow(
                            label: 'Publisher',
                            value: _book.publisher ?? '-',
                          ),
                          _BookDetailRow(
                            label: 'Language',
                            value: _book.languageCode ?? '-',
                          ),
                          _BookDetailRow(
                            label: 'Release date',
                            value: _book.releaseDate ?? '-',
                          ),
                        ],
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 20),
                        ErrorBanner(message: _errorMessage!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

















