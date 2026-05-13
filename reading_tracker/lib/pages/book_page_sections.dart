part of 'book_page.dart';

extension _BookPageSections on _BookPageState {
  Widget _buildStartTab(ThemeData theme) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
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
    final titleFlex = _titleColumnFlex(books);
    final secondaryFlex = _libraryColumnFlex(books, _secondaryColumn);
    final tertiaryFlex = _libraryColumnFlex(books, _tertiaryColumn);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
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
                        titleFlex,
                        secondaryFlex,
                        tertiaryFlex,
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
    int titleFlex,
    int secondaryFlex,
    int tertiaryFlex,
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
                    titleFlex,
                    secondaryFlex,
                    tertiaryFlex,
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
                          titleFlex,
                          secondaryFlex,
                          tertiaryFlex,
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
    int titleFlex,
    int secondaryFlex,
    int tertiaryFlex,
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
            label: _libraryColumnLabel(_secondaryColumn),
            canChange: true,
            selectedColumn: _secondaryColumn,
            isSecondaryColumn: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: tertiaryFlex,
          child: _buildColumnHeader(
            theme,
            label: _libraryColumnLabel(_tertiaryColumn),
            canChange: true,
            selectedColumn: _tertiaryColumn,
            isSecondaryColumn: false,
          ),
        ),
      ],
    );
  }

  Widget _buildLibraryRow(
    Book entry,
    int titleFlex,
    int secondaryFlex,
    int tertiaryFlex,
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
                _libraryColumnValue(entry, _secondaryColumn),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: tertiaryFlex,
              child: Text(
                _libraryColumnValue(entry, _tertiaryColumn),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
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
