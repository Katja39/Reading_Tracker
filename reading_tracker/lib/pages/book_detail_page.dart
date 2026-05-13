import 'package:flutter/material.dart';

import '../models/book.dart';
import '../repositories/book_repository.dart';
import '../widgets/error_banner.dart';

class BookDetailResult {
  const BookDetailResult._({
    this.updatedBook,
    this.deletedBookId,
  });

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
    final submitted = await showDialog<_EditBookDialogResult>(
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
    final shouldPromptForRating =
        _book.status != 'read' && status == 'read' && _book.rating == null;

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
      rating: _book.rating,
      isbn: isbn,
      pages: pages,
      publisher: publisher,
      languageCode: languageCode,
      coverUrl: coverUrl,
    );
    var openRatingDialogAfterSave = false;

    try {
      await widget.repository.updateBook(
        id: _book.id,
        userId: _book.userId,
        title: title,
        author: author,
        status: status,
        rating: _book.rating,
        isbn: isbn,
        pages: pages,
        publisher: publisher,
        languageCode: languageCode,
        coverUrl: coverUrl,
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

    if (rating == _book.rating) {
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
      status: _book.status,
      rating: rating,
      isbn: _book.isbn,
      pages: _book.pages,
      publisher: _book.publisher,
      languageCode: _book.languageCode,
      coverUrl: _book.coverUrl,
    );

    try {
      await widget.repository.updateBook(
        id: _book.id,
        userId: _book.userId,
        title: _book.title,
        author: _book.author,
        status: _book.status,
        rating: rating,
        isbn: _book.isbn,
        pages: _book.pages,
        publisher: _book.publisher,
        languageCode: _book.languageCode,
        coverUrl: _book.coverUrl,
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _book.title,
                        style: theme.textTheme.headlineSmall,
                      ),
                      if (_book.coverUrl != null && _book.coverUrl!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _book.coverUrl!,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _BookDetailRow(label: 'Author', value: _book.author),
                      const SizedBox(height: 12),
                      _BookDetailRow(label: 'Status', value: _book.status),
                      const SizedBox(height: 12),
                      _BookDetailRow(
                        label: 'ISBN',
                        value: _book.isbn ?? '-',
                      ),
                      const SizedBox(height: 12),
                      _BookDetailRow(
                        label: 'Pages',
                        value: _book.pages?.toString() ?? '-',
                      ),
                      const SizedBox(height: 12),
                      _BookDetailRow(
                        label: 'Publisher',
                        value: _book.publisher ?? '-',
                      ),
                      const SizedBox(height: 12),
                      _BookDetailRow(
                        label: 'Language',
                        value: _book.languageCode ?? '-',
                      ),
                      const SizedBox(height: 12),
                      _BookRatingRow(
                        rating: _book.rating,
                        onTap: _isSaving ? null : _showEditRatingDialog,
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
  });

  final String title;
  final String author;
  final String status;
  final String? isbn;
  final int? pages;
  final String? publisher;
  final String? languageCode;
  final String? coverUrl;
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
  String? _coverUrl;
  late String _selectedStatus;
  bool _isAutoFilling = false;
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
    _coverUrl = widget.book.coverUrl;
    _selectedStatus = widget.statuses.contains(widget.book.status)
        ? widget.book.status
        : widget.statuses.first;
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
      title: const Text('Edit Book'),
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
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _EditRatingDialogResult {
  const _EditRatingDialogResult({
    required this.rating,
  });

  final double? rating;
}

class _EditRatingDialog extends StatefulWidget {
  const _EditRatingDialog({
    required this.initialRating,
  });

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
    Navigator.of(context).pop(
      _EditRatingDialogResult(rating: _selectedRating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Rating'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rating',
            style: Theme.of(context).textTheme.labelLarge,
          ),
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _BookDetailRow extends StatelessWidget {
  const _BookDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _BookRatingRow extends StatelessWidget {
  const _BookRatingRow({
    required this.rating,
    required this.onTap,
  });

  final double? rating;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveRating = (rating ?? 0).clamp(0, 5);
    final fullStars = effectiveRating.floor();
    final hasHalfStar = effectiveRating - fullStars >= 0.5;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rating',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                ...List.generate(5, (index) {
                  final icon = switch (index) {
                    _ when index < fullStars => Icons.star,
                    _ when index == fullStars && hasHalfStar =>
                      Icons.star_half,
                    _ => Icons.star_border,
                  };

                  return Icon(
                    icon,
                    color: theme.colorScheme.primary,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  'Tap to edit',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
