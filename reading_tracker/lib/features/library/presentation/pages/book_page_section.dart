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
                  const SizedBox(height: 8),
                  Text('Home', style: theme.textTheme.headlineSmall),
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
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    final titleFlex = _titleColumnFlex(books);
    final preferredFields = [..._columnOrder];
    final additionalFields = _availableConfigurableFields
        .where((field) => !preferredFields.contains(field))
        .toList();
    final orderedFields = [...preferredFields, ...additionalFields];
    final visibleFieldCount = _maxVariableColumns(context).clamp(
      2,
      _availableConfigurableFields.length,
    ) as int;
    final visibleFields = orderedFields.take(visibleFieldCount).toList();
    final fieldFlexes = visibleFields
        .map((field) => _libraryFieldFlex(books, field))
        .toList();

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLibraryToolbar(theme),
              SizedBox(height: isMobile ? 8 : 4),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                ErrorBanner(message: _errorMessage!),
              ],
              SizedBox(height: isMobile ? 8 : 12),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : isMobile
                        ? _buildMobileLibraryCard(theme, books)
                        : _buildLibraryCard(
                            theme,
                            books,
                            visibleFields,
                            titleFlex,
                            fieldFlexes,
                          ),
              ),
              const SizedBox(height: 8),
              _buildLibraryActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryToolbar(ThemeData theme) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    final searchField = TextField(
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
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchField,
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMobileSortControl(theme),
              _buildLibraryControlButton(
                theme,
                label: 'Filter',
                icon: Icons.filter_list,
                isHighlighted: _hasActiveFilter,
                onPressed: () {
                  _openSortFilterSheet(
                    theme,
                    isMobile: true,
                    panel: _LibraryControlPanel.filter,
                  );
                },
              ),
              _buildLibraryControlButton(
                theme,
                label: 'Display',
                icon: Icons.view_agenda_outlined,
                onPressed: () {
                  _openSortFilterSheet(
                    theme,
                    isMobile: true,
                    panel: _LibraryControlPanel.display,
                  );
                },
              ),
              TextButton(
                onPressed: _resetSortAndFilter,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
          if (_hasActiveFilter) ...[
            const SizedBox(height: 8),
            _buildActiveFilterBanner(theme),
          ],
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: searchField),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          tooltip: 'Sort and filter',
          onSelected: (value) {
            if (value == _BookPageState._menuActionSortFilter) {
              _openSortFilterSheet(
                theme,
                isMobile: false,
                panel: _LibraryControlPanel.sort,
              );
            } else if (value == _BookPageState._menuActionResetFilter) {
              _resetSortAndFilter();
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem<String>(
              value: _BookPageState._menuActionSortFilter,
              child: Text('Sort / Filter / Display'),
            ),
            PopupMenuItem<String>(
              value: _BookPageState._menuActionResetFilter,
              child: Text('Reset'),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  'Sort/Filter/Display',
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

  Widget _buildMobileSortControl(ThemeData theme) {
    return SizedBox(
      height: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: _isSortAscending ? 'Ascending' : 'Descending',
              iconSize: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 40, height: 36),
              onPressed: () {
                setState(() {
                  _isSortAscending = !_isSortAscending;
                });
              },
              icon: AnimatedRotation(
                duration: const Duration(milliseconds: 180),
                turns: _isSortAscending ? 0 : 0.5,
                child: Icon(
                  Icons.arrow_upward,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            Container(
              width: 1,
              height: 18,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            InkWell(
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(12),
              ),
              onTap: () {
                _openSortFilterSheet(
                  theme,
                  isMobile: true,
                  panel: _LibraryControlPanel.sort,
                );
              },
              child: SizedBox(
                height: 36,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    child: Text(
                      'Sort',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildLibraryControlButton(
    ThemeData theme, {
    required String label,
    required IconData icon,
    bool isHighlighted = false,
    required VoidCallback onPressed,
  }) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: FilledButton.styleFrom(
        foregroundColor: isHighlighted
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onPrimaryContainer,
        backgroundColor: isHighlighted
            ? theme.colorScheme.primary
            : theme.colorScheme.primaryContainer,
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildActiveFilterBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt,
            size: 18,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _activeFilterSummary,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLibraryCard(ThemeData theme, List<Book> books) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: books.isEmpty
          ? Center(
              child: Text(
                'No books available yet.',
                style: theme.textTheme.bodyLarge,
              ),
            )
          : ListView.separated(
              itemCount: books.length,
              separatorBuilder: (_, _) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final entry = books[index];
                return _buildMobileLibraryRow(theme, entry);
              },
            ),
    );
  }
  Widget _buildLibraryCard(
    ThemeData theme,
    List<Book> books,
    List<_LibraryField> visibleFields,
    int titleFlex,
    List<int> fieldFlexes,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
                  visibleFields,
                  titleFlex,
                  fieldFlexes,
                ),
                const Divider(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: books.length,
                    separatorBuilder: (_, _) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final entry = books[index];
                      return _buildLibraryRow(
                        theme,
                        entry,
                        visibleFields,
                        titleFlex,
                        fieldFlexes,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
  Widget _buildLibraryHeader(
    ThemeData theme,
    List<_LibraryField> visibleFields,
    int titleFlex,
    List<int> fieldFlexes,
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
          label: _fieldLabel(_LibraryField.title),
          canChange: false,
        ),
      ),
    ];

    for (var index = 0; index < visibleFields.length; index++) {
      final field = visibleFields[index];
      children.add(const SizedBox(width: 16));
      children.add(
        Expanded(
          flex: fieldFlexes[index],
          child: _buildColumnHeader(
            theme,
            label: _fieldLabel(field),
            canChange: true,
            selectedField: field,
            columnOrderIndex: index,
          ),
        ),
      );
    }

    return Row(children: children);
  }

  Widget _buildLibraryRow(
    ThemeData theme,
    Book entry,
    List<_LibraryField> visibleFields,
    int titleFlex,
    List<int> fieldFlexes,
  ) {
    final children = <Widget>[
      _buildBookCover(
        entry,
        width: 64,
        height: 92,
        borderRadius: 6,
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

    for (var index = 0; index < visibleFields.length; index++) {
      children.add(const SizedBox(width: 16));
      children.add(
        Expanded(
          flex: fieldFlexes[index],
          child: _buildLibraryFieldValueWidget(
            theme,
            entry,
            visibleFields[index],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _openBookDetails(entry),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(children: children),
      ),
    );
  }

  Widget _buildMobileLibraryRow(ThemeData theme, Book entry) {
    final selectedInfos = _mobileInfoFields
        .map((field) => (field, _mobileInfoValue(entry, field)))
        .where((info) => !_shouldHideMobileInfoValue(info.$1, info.$2))
        .toList();
    final primaryInfo = selectedInfos.isEmpty ? null : selectedInfos.first;
    final compactInfos = selectedInfos.skip(1).toList();

    return InkWell(
      onTap: () => _openBookDetails(entry),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookCover(
              entry,
              width: 68,
              height: 96,
              borderRadius: 8,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (primaryInfo != null) ...[
                    const SizedBox(height: 6),
                    _buildMobilePrimaryInfo(
                      theme,
                      entry,
                      primaryInfo.$1,
                      primaryInfo.$2,
                    ),
                  ],
                  if (compactInfos.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: compactInfos
                          .map(
                            (info) => _buildMobileInfoChip(
                              theme,
                              book: entry,
                              field: info.$1,
                              value: info.$2,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileInfoChip(
    ThemeData theme, {
    required Book book,
    required _LibraryField field,
    required String value,
  }) {
    final isStatus = field == _LibraryField.status;
    final isRating = field == _LibraryField.rating;
    final label = _fieldLabel(field);
    final chipText = isStatus ? value : '$label: $value';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isStatus
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: isRating
          ? _buildRatingStars(
              theme,
              book.rating,
              size: 14,
              activeColor: theme.colorScheme.onSurfaceVariant,
              inactiveColor: theme.colorScheme.onSurfaceVariant,
            )
          : Text(
              chipText,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isStatus
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
    );
  }

  Widget _buildLibraryFieldValueWidget(
    ThemeData theme,
    Book entry,
    _LibraryField field,
  ) {
    if (field == _LibraryField.rating) {
      return Align(
        alignment: Alignment.centerLeft,
        child: _buildRatingStars(
          theme,
          entry.rating,
          size: 16,
        ),
      );
    }

    return Text(
      _fieldDisplayValue(entry, field),
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }

  Widget _buildMobilePrimaryInfo(
    ThemeData theme,
    Book entry,
    _LibraryField field,
    String value,
  ) {
    if (field == _LibraryField.rating) {
      return _buildRatingStars(
        theme,
        entry.rating,
        size: 16,
        activeColor: theme.colorScheme.primary,
        inactiveColor: theme.colorScheme.outline,
      );
    }

    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildRatingStars(
    ThemeData theme,
    double? rating, {
    required double size,
    Color? activeColor,
    Color? inactiveColor,
  }) {
    final effectiveRating = (rating ?? 0).clamp(0, 5);
    final fullStars = effectiveRating.floor();
    final hasHalfStar = effectiveRating - fullStars >= 0.5;
    final filledColor = activeColor ?? theme.colorScheme.primary;
    final outlinedColor = inactiveColor ?? theme.colorScheme.outline;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final icon = switch (index) {
          _ when index < fullStars => Icons.star,
          _ when index == fullStars && hasHalfStar => Icons.star_half,
          _ => Icons.star_border,
        };

        final color = icon == Icons.star || icon == Icons.star_half
            ? filledColor
            : outlinedColor;

        return Icon(
          icon,
          size: size,
          color: color,
        );
      }),
    );
  }

  Widget _buildBookCover(
    Book entry, {
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: entry.coverUrl != null && entry.coverUrl!.isNotEmpty
            ? Image.network(
                entry.coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildCoverFallback(context),
              )
            : _buildCoverFallback(context),
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











