part of 'book_page.dart';

extension _BookPageSections on _BookPageState {
  int _maxVariableColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1550) {
      return 6;
    }
    if (width >= 1350) {
      return 5;
    }
    if (width >= 1150) {
      return 4;
    }
    if (width >= 900) {
      return 3;
    }
    return 2;
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
    final titleFlex = _titleColumnFlex(books);
    final preferredColumns = [..._columnOrder];
    final additionalColumns = _LibraryColumn.values
        .where((column) => !preferredColumns.contains(column))
        .toList();
    final orderedColumns = [...preferredColumns, ...additionalColumns];
    final variableColumnCount = _maxVariableColumns(context)
        .clamp(2, _LibraryColumn.values.length);
    final visibleColumns = orderedColumns.take(variableColumnCount).toList();
    final columnFlexes = visibleColumns
        .map((column) => _libraryColumnFlex(books, column))
        .toList();

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
                        visibleColumns,
                        titleFlex,
                        columnFlexes,
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
    List<_LibraryColumn> visibleColumns,
    int titleFlex,
    List<int> columnFlexes,
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
                    visibleColumns,
                    titleFlex,
                    columnFlexes,
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
                          visibleColumns,
                          titleFlex,
                          columnFlexes,
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
    List<_LibraryColumn> visibleColumns,
    int titleFlex,
    List<int> columnFlexes,
  ) {
    final children = <Widget>[
      SizedBox(
        width: 64,
        child: Text(
          'Cover',
          style: theme.textTheme.labelLarge,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: titleFlex,
        child: _buildColumnHeader(
          theme,
          label: 'Title',
          canChange: false,
        ),
      ),
    ];

    for (var index = 0; index < visibleColumns.length; index++) {
      final column = visibleColumns[index];
      children.add(const SizedBox(width: 16));
      children.add(
        Expanded(
          flex: columnFlexes[index],
          child: _buildColumnHeader(
            theme,
            label: _libraryColumnLabel(column),
            canChange: true,
            selectedColumn: column,
            columnOrderIndex: index,
          ),
        ),
      );
    }

    return Row(
      children: children,
    );
  }

  Widget _buildLibraryRow(
    Book entry,
    List<_LibraryColumn> visibleColumns,
    int titleFlex,
    List<int> columnFlexes,
  ) {
    final children = <Widget>[
      SizedBox(
        width: 64,
        height: 92,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: entry.coverUrl != null && entry.coverUrl!.isNotEmpty
              ? Image.network(
                  entry.coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _buildCoverFallback(context),
                )
              : _buildCoverFallback(context),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: titleFlex,
        child: Text(
          entry.title,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ),
    ];

    for (var index = 0; index < visibleColumns.length; index++) {
      children.add(const SizedBox(width: 16));
      children.add(
        Expanded(
          flex: columnFlexes[index],
          child: Text(
            _libraryColumnValue(entry, visibleColumns[index]),
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _openBookDetails(entry),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 14,
        ),
        child: Row(
          children: children,
        ),
      ),
    );
  }

  Widget _buildCoverFallback(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.menu_book_outlined,
        size: 18,
        color: theme.colorScheme.onSurfaceVariant,
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

  Widget _buildStatisticsTab(ThemeData theme) {
    return Center(
      child: Text(
        'This page is empty.',
        style: theme.textTheme.bodyLarge,
      ),
    );
  }
}
