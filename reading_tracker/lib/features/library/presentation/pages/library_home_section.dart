//
// Home tab section for currently reading books
//


part of 'library_page.dart';

// Adds home tab builders to the library page state
extension _LibraryPageHomeSection on _LibraryPageState {
  // Builds the currently reading horizontal list
  Widget _buildStartTab(ThemeData theme) {
    final maxWidth = _responsiveContentWidth(context);
    final readingBooks = _books
        .where((book) => book.status.toLowerCase() == 'reading')
        .toList();

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Currently reading',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = _homeBookCardWidth(constraints.maxWidth);
                  final coverWidth = _homeBookCoverWidth(constraints.maxWidth);
                  final coverHeight = coverWidth * 1.42;
                  final listHeight = coverHeight + 8;

                  return SizedBox(
                    height: listHeight,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : readingBooks.isEmpty
                            ? Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'No books currently in progress.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: readingBooks.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 14),
                                itemBuilder: (context, index) {
                                  return _buildCurrentlyReadingCard(
                                    theme,
                                    readingBooks[index],
                                    width: cardWidth,
                                    coverWidth: coverWidth,
                                    coverHeight: coverHeight,
                                  );
                                },
                              ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Opens the compact progress update dialog from the home tab
  Future<void> _showHomeUpdateCurrentPageDialog(Book book) async {
    final submitted = await showDialog<ReadingProgressUpdateResult>(
      context: context,
      builder: (context) {
        return ReadingProgressUpdateDialog(
          initialPage: book.currentPage,
          totalPages: book.pages,
        );
      },
    );
    if (submitted == null) {
      return;
    }

    final submittedPage = submitted.pageNumber;
    if (submittedPage == null) {
      setState(() {
        _errorMessage = 'Current page must be a number.';
      });
      return;
    }

    if (submittedPage < 0) {
      setState(() {
        _errorMessage = 'Current page must not be negative.';
      });
      return;
    }

    final totalPages = book.pages;
    if (totalPages != null && submittedPage > totalPages) {
      setState(() {
        _errorMessage = 'Current page must not exceed total pages.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final updatedBook = await widget.repository.recordReadingProgress(
        bookId: book.id,
        pageNumber: submittedPage,
        progressDate: submitted.progressDate,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _books = _books
            .map((entry) => entry.id == updatedBook.id ? updatedBook : entry)
            .toList();
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
  // Chooses a responsive card width for the home carousel
  double _homeBookCardWidth(double availableWidth) {
    if (availableWidth >= 900) {
      return AppSizes.homeReadingCardWidthLarge;
    }
    if (availableWidth >= 600) {
      return AppSizes.homeReadingCardWidthMedium;
    }
    return AppSizes.homeReadingCardWidthSmall;
  }

  // Chooses a responsive cover width for the home carousel
  double _homeBookCoverWidth(double availableWidth) {
    if (availableWidth >= 900) {
      return AppSizes.homeReadingCoverWidthLarge;
    }
    if (availableWidth >= 600) {
      return AppSizes.homeReadingCoverWidthMedium;
    }
    return AppSizes.homeReadingCoverWidthSmall;
  }

  // Builds one currently reading card with cover and compact progress
  Widget _buildCurrentlyReadingCard(
    ThemeData theme,
    Book book, {
    required double width,
    required double coverWidth,
    required double coverHeight,
  }) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: () => _openBookDetails(book),
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBookCover(
                book,
                width: coverWidth,
                height: coverHeight,
                borderRadius: AppRadii.sm,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    ReadingProgressSummary(
                      currentPage: book.currentPage,
                      pages: book.pages,
                      onUpdatePressed: _isSaving
                          ? null
                          : () => _showHomeUpdateCurrentPageDialog(book),
                      compact: true,
                      minBarWidth: AppSizes.compactProgressMinWidth,
                      maxBarWidth: AppSizes.compactProgressMaxWidth,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
