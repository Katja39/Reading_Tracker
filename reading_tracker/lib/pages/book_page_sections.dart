part of 'book_page.dart';

extension _BookPageSections on _BookPageState {
  bool _showAllLibraryColumns(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 1000;
  }

  double _responsiveContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    if (screenWidth >= 1600) {
      return 1360;
    }
    if (screenWidth >= 1300) {
      return 1120;
    }
    if (screenWidth >= 1000) {
      return 920;
    }
    if (screenWidth >= 800) {
      return 760;
    }
    return screenWidth;
  }

  Widget _buildStartTab(ThemeData theme) {
    final maxWidth = _responsiveContentWidth(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
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
    final maxWidth = _responsiveContentWidth(context);
    final showAllColumns = _showAllLibraryColumns(context);
    final titleFlex = _titleColumnFlex(books);
    final secondaryColumn = showAllColumns
        ? _LibraryColumn.author
        : _secondaryColumn;
    final tertiaryColumn = showAllColumns
        ? _LibraryColumn.status
        : _tertiaryColumn;
    final quaternaryColumn = showAllColumns ? _LibraryColumn.rating : null;
    final secondaryFlex = _libraryColumnFlex(books, secondaryColumn);
    final tertiaryFlex = _libraryColumnFlex(books, tertiaryColumn);
    final quaternaryFlex = quaternaryColumn == null
        ? 0
        : _libraryColumnFlex(books, quaternaryColumn);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLibraryToolbar(theme),
              const SizedBox(height: 4),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                ErrorBanner(message: _errorMessage!),
              ],
              const SizedBox(height: 24),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildLibraryCard(
                        theme,
                        books,
                        showAllColumns,
                        secondaryColumn,
                        tertiaryColumn,
                        quaternaryColumn,
                        titleFlex,
                        secondaryFlex,
                        tertiaryFlex,
                        quaternaryFlex,
                      ),
              ),
              const SizedBox(height: 16),
              _buildLibraryActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryToolbar(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search books',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          tooltip: 'Sort and filter',
          onSelected: (value) {
            if (value == _BookPageState._menuActionSortFilter) {
              _openSortFilterSheet(theme);
            } else if (value == _BookPageState._menuActionResetFilter) {
              _resetSortAndFilter();
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem<String>(
              value: _BookPageState._menuActionSortFilter,
              child: Text('Sort & filter'),
            ),
            PopupMenuItem<String>(
              value: _BookPageState._menuActionResetFilter,
              child: Text('Reset'),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.tune,
                  size: 18,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  'Sort/Filter',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLibraryCard(
    ThemeData theme,
    List<Book> books,
    bool showAllColumns,
    _LibraryColumn secondaryColumn,
    _LibraryColumn tertiaryColumn,
    _LibraryColumn? quaternaryColumn,
    int titleFlex,
    int secondaryFlex,
    int tertiaryFlex,
    int quaternaryFlex,
  ) {
    return Card(
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLibraryHeader(
                    theme,
                    showAllColumns,
                    secondaryColumn,
                    tertiaryColumn,
                    quaternaryColumn,
                    titleFlex,
                    secondaryFlex,
                    tertiaryFlex,
                    quaternaryFlex,
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: ListView.separated(
                      itemCount: books.length,
                      separatorBuilder: (_, _) => const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final entry = books[index];
                        return _buildLibraryRow(
                          entry,
                          showAllColumns,
                          secondaryColumn,
                          tertiaryColumn,
                          quaternaryColumn,
                          titleFlex,
                          secondaryFlex,
                          tertiaryFlex,
                          quaternaryFlex,
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLibraryHeader(
    ThemeData theme,
    bool showAllColumns,
    _LibraryColumn secondaryColumn,
    _LibraryColumn tertiaryColumn,
    _LibraryColumn? quaternaryColumn,
    int titleFlex,
    int secondaryFlex,
    int tertiaryFlex,
    int quaternaryFlex,
  ) {
    return Row(
      children: [
        Expanded(
          flex: titleFlex,
          child: _buildColumnHeader(
            theme,
            label: 'Title',
            canChange: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: secondaryFlex,
          child: _buildColumnHeader(
            theme,
            label: _libraryColumnLabel(secondaryColumn),
            canChange: !showAllColumns,
            selectedColumn: showAllColumns ? null : secondaryColumn,
            isSecondaryColumn: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: tertiaryFlex,
          child: _buildColumnHeader(
            theme,
            label: _libraryColumnLabel(tertiaryColumn),
            canChange: !showAllColumns,
            selectedColumn: showAllColumns ? null : tertiaryColumn,
            isSecondaryColumn: false,
          ),
        ),
        if (showAllColumns && quaternaryColumn != null) ...[
          const SizedBox(width: 16),
          Expanded(
            flex: quaternaryFlex,
            child: _buildColumnHeader(
              theme,
              label: _libraryColumnLabel(quaternaryColumn),
              canChange: false,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLibraryRow(
    Book entry,
    bool showAllColumns,
    _LibraryColumn secondaryColumn,
    _LibraryColumn tertiaryColumn,
    _LibraryColumn? quaternaryColumn,
    int titleFlex,
    int secondaryFlex,
    int tertiaryFlex,
    int quaternaryFlex,
  ) {
    return InkWell(
      onTap: () => _openBookDetails(entry),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ),
        child: Row(
          children: [
            Expanded(
              flex: titleFlex,
              child: Text(
                _truncateLibraryText(entry.title),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: secondaryFlex,
              child: Text(
                _libraryColumnValue(entry, secondaryColumn),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: tertiaryFlex,
              child: Text(
                _libraryColumnValue(entry, tertiaryColumn),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
            if (showAllColumns && quaternaryColumn != null) ...[
              const SizedBox(width: 16),
              Expanded(
                flex: quaternaryFlex,
                child: Text(
                  _libraryColumnValue(entry, quaternaryColumn),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryActions() {
    return Row(
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
          label: Text(_isSaving ? 'Saving...' : 'New Book'),
        ),
      ],
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
}
