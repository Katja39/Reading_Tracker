part of 'book_page.dart';

extension _BookPageHomeSection on _BookPageState {
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
                  final coverWidth = cardWidth - 8;
                  final coverHeight = coverWidth * 1.42;
                  final listHeight = coverHeight + 58;

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

  double _homeBookCardWidth(double availableWidth) {
    if (availableWidth >= 900) {
      return 156;
    }
    if (availableWidth >= 600) {
      return 140;
    }
    return 124;
  }

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
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBookCover(
                book,
                width: coverWidth,
                height: coverHeight,
                borderRadius: 8,
              ),
              const SizedBox(height: 8),
              Text(
                book.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
