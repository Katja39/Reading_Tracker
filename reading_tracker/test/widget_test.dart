import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reading_tracker/app.dart';
import 'package:reading_tracker/features/books/domain/models/book.dart';
import 'package:reading_tracker/features/books/domain/repositories/book_repository.dart';
import 'package:reading_tracker/features/metadata/domain/models/book_enrichment.dart';

void main() {
  Future<void> pumpMobileApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MyApp(
        repository: FakeBookRepository(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders add button and book list', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(
        repository: FakeBookRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Library'), findsOneWidget);
    expect(find.text('New Book'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Author'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('No books available yet.'), findsNothing);
    expect(find.text('Reload'), findsOneWidget);
    expect(find.text('Alpha Book'), findsOneWidget);
    expect(find.text('Author A'), findsOneWidget);
    expect(find.text('reading'), findsOneWidget);
    expect(find.text('Second Book'), findsOneWidget);
    expect(find.text('Second Author'), findsOneWidget);
    expect(find.text('unread'), findsOneWidget);
  });

  testWidgets('switches to home tab and shows home card', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        repository: FakeBookRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
    expect(find.text('New Book'), findsNothing);
  });

  testWidgets('switches to statistics tab and shows placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        repository: FakeBookRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Statistics'));
    await tester.pumpAndSettle();

    expect(find.text('Statistics'), findsWidgets);
    expect(find.text('This page is empty.'), findsOneWidget);
    expect(find.text('Sort/Filter'), findsNothing);
  });

  testWidgets('shows mobile library cards instead of the table header', (
    WidgetTester tester,
  ) async {
    await pumpMobileApp(tester);

    expect(find.text('Sort'), findsOneWidget);
    expect(find.text('Filter'), findsOneWidget);
    expect(find.text('Display'), findsOneWidget);
    expect(find.text('Cover'), findsNothing);
    expect(find.text('Author'), findsNothing);
    expect(find.text('Alpha Book'), findsOneWidget);
    expect(find.text('Author A'), findsOneWidget);
    expect(find.text('Reading'), findsOneWidget);
  });

  testWidgets('customizes mobile library info slots', (
    WidgetTester tester,
  ) async {
    await pumpMobileApp(tester);

    await tester.tap(find.text('Display'));
    await tester.pumpAndSettle();

    expect(
      find.text('Choose up to 6 info fields for mobile cards.'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(CheckboxListTile, 'Author'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Pages'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('Pages: 321'), findsOneWidget);
    expect(find.text('Author A'), findsNothing);
  });

  testWidgets('limits mobile display selection to six info fields', (
    WidgetTester tester,
  ) async {
    await pumpMobileApp(tester);

    await tester.tap(find.text('Display'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(CheckboxListTile, 'Pages'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Publisher'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Language'));
    await tester.pumpAndSettle();

    final isbnTile = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'ISBN'),
    );
    expect(isbnTile.onChanged, isNull);
  });

  testWidgets('disables create until required fields are filled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        repository: FakeBookRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Book'));
    await tester.pumpAndSettle();

    FilledButton createButton() =>
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Create'));

    expect(createButton().onPressed, isNull);

    await tester.enterText(find.byType(TextField).at(0), 'New Title');
    await tester.pumpAndSettle();
    expect(createButton().onPressed, isNull);

    await tester.enterText(find.byType(TextField).at(1), 'New Author');
    await tester.pumpAndSettle();
    expect(createButton().onPressed, isNotNull);
  });

  testWidgets('opens detail page when tapping a book', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        repository: FakeBookRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alpha Book'));
    await tester.pumpAndSettle();

    expect(find.text('Author'), findsOneWidget);
    expect(find.text('Author A'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('reading'), findsOneWidget);
    expect(find.text('Rating'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNWidgets(4));
    expect(find.byIcon(Icons.star_border), findsNWidgets(1));
    expect(find.text('Book ID'), findsNothing);
    expect(find.text('User ID'), findsNothing);
  });

  testWidgets('edits title, author and status from detail page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        repository: FakeBookRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alpha Book'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    final editDialog = find.byType(AlertDialog);
    expect(find.descendant(of: editDialog, matching: find.text('Rating')),
        findsNothing);
    expect(find.descendant(of: editDialog, matching: find.byIcon(Icons.star)),
        findsNothing);

    await tester.enterText(find.byType(TextField).at(0), 'Edited Book');
    await tester.enterText(find.byType(TextField).at(1), 'Edited Author');
    await tester.tap(find.text('reading'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('read').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Edited Book'), findsOneWidget);
    expect(find.text('Edited Author'), findsOneWidget);
    expect(find.text('read'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Edited Book'), findsOneWidget);
    expect(find.text('Edited Author'), findsOneWidget);
    expect(find.text('read'), findsOneWidget);
    expect(find.text('Alpha Book'), findsNothing);
    expect(find.text('Author A'), findsNothing);
    expect(find.text('reading'), findsNothing);
  });

  testWidgets('edits only rating when tapping rating section', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        repository: FakeBookRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alpha Book'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tap to edit'));
    await tester.pumpAndSettle();

    final ratingDialog = find.byType(AlertDialog);
    expect(find.descendant(of: ratingDialog, matching: find.text('Edit Rating')),
        findsOneWidget);
    expect(find.descendant(of: ratingDialog, matching: find.byType(TextField)),
        findsNothing);
    expect(find.descendant(of: ratingDialog, matching: find.text('Title')),
        findsNothing);
    expect(find.descendant(of: ratingDialog, matching: find.text('Author')),
        findsNothing);
    expect(find.descendant(of: ratingDialog, matching: find.text('Status')),
        findsNothing);

    final starButtons = find.descendant(
      of: ratingDialog,
      matching: find.byType(IconButton),
    );

    await tester.tap(starButtons.at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.star), findsNWidgets(2));
    expect(find.byIcon(Icons.star_border), findsNWidgets(3));
  });

  testWidgets('deletes a book from detail page', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(
        repository: FakeBookRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alpha Book'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Alpha Book'), findsNothing);
    expect(find.text('Second Book'), findsOneWidget);
  });

  testWidgets('sorts library entries ascending and descending', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        repository: FakeBookRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sort/Filter/Display'), findsOneWidget);

    final alphaBefore = tester.getTopLeft(find.text('Alpha Book')).dy;
    final secondBefore = tester.getTopLeft(find.text('Second Book')).dy;
    expect(alphaBefore < secondBefore, isTrue);

    await tester.tap(find.text('Sort/Filter/Display'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sort / Filter / Display'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    final alphaAfter = tester.getTopLeft(find.text('Alpha Book')).dy;
    final secondAfter = tester.getTopLeft(find.text('Second Book')).dy;
    expect(alphaAfter > secondAfter, isTrue);
  });

  testWidgets('filters library entries by multiple categories', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        repository: FakeBookRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sort/Filter/Display'), findsOneWidget);
    expect(find.text('Alpha Book'), findsOneWidget);
    expect(find.text('Second Book'), findsOneWidget);
    expect(find.text('Read Book'), findsOneWidget);

    await tester.tap(find.text('Sort/Filter/Display'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sort / Filter / Display'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Author').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Author A').last);
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('Alpha Book'), findsOneWidget);
    expect(find.text('Second Book'), findsNothing);
    expect(find.text('Read Book'), findsNothing);
  });

  testWidgets('filters library entries by pages range', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        repository: FakeBookRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sort/Filter/Display'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sort / Filter / Display'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pages').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Min pages'), '300');
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Max pages'), '330');
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('Alpha Book'), findsOneWidget);
    expect(find.text('Second Book'), findsNothing);
    expect(find.text('Read Book'), findsNothing);
  });

  testWidgets('shows active filter summary below mobile buttons', (
    WidgetTester tester,
  ) async {
    await pumpMobileApp(tester);

    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pages').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Min pages'), '300');
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('Filter active: Pages: from 300'), findsOneWidget);
  });

  testWidgets('searches library entries via text field', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        repository: FakeBookRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alpha Book'), findsOneWidget);
    expect(find.text('Second Book'), findsOneWidget);
    expect(find.text('Read Book'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'second');
    await tester.pumpAndSettle();

    expect(find.text('Alpha Book'), findsNothing);
    expect(find.text('Second Book'), findsOneWidget);
    expect(find.text('Read Book'), findsNothing);
  });

  testWidgets('searches library entries across extended fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        repository: FakeBookRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '321');
    await tester.pumpAndSettle();

    expect(find.text('Alpha Book'), findsOneWidget);
    expect(find.text('Second Book'), findsNothing);
    expect(find.text('Read Book'), findsNothing);
  });

  testWidgets('changes configurable library columns from status to rating', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        repository: FakeBookRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Author'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('reading'), findsOneWidget);
    expect(find.text('4/5'), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_drop_down).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rating').last);
    await tester.pumpAndSettle();

    expect(find.text('Rating'), findsOneWidget);
    expect(find.text('4/5'), findsNothing);
    expect(find.text('No rating'), findsNothing);
    expect(find.text('5/5'), findsNothing);
    expect(find.byIcon(Icons.star), findsNWidgets(9));
    expect(find.byIcon(Icons.star_border), findsNWidgets(6));
  });

  testWidgets(
    'opens rating dialog automatically when status changes to read and rating is missing',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(
          repository: FakeBookRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Second Book'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      await tester.tap(find.text('unread'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('read').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Rating'), findsOneWidget);
    },
  );
}

class FakeBookRepository implements BookRepository {
  @override
  Future<Book> createBook({
    required String title,
    required String author,
    required String status,
    double? rating,
    String? isbn,
    int? pages,
    String? publisher,
    String? languageCode,
    String? coverUrl,
    String? seriesId,
    int? volume,
    String? genreId,
    String? ageCategory,
    String? releaseDate,
    String? format,
  }) async {
    return Book(
      id: 'book-1',
      userId: 'user-1',
      title: title,
      author: author,
      status: status,
      rating: rating,
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
    );
  }

  @override
  Future<List<Book>> fetchBooks() async {
    return const [
      Book(
        id: 'book-1',
        userId: 'user-1',
        title: 'Alpha Book',
        author: 'Author A',
        status: 'reading',
        rating: 4,
        pages: 321,
      ),
      Book(
        id: 'book-2',
        userId: 'user-1',
        title: 'Second Book',
        author: 'Second Author',
        status: 'unread',
        rating: null,
      ),
      Book(
        id: 'book-3',
        userId: 'user-1',
        title: 'Read Book',
        author: 'Reader Author',
        status: 'read',
        rating: 5,
      ),
    ];
  }

  @override
  Future<Book> updateBook({
    required String id,
    required String userId,
    required String title,
    required String author,
    required String status,
    double? rating,
    String? isbn,
    int? pages,
    String? publisher,
    String? languageCode,
    String? coverUrl,
    String? seriesId,
    int? volume,
    String? genreId,
    String? ageCategory,
    String? releaseDate,
    String? format,
  }) async {
    return Book(
      id: id,
      userId: userId,
      title: title,
      author: author,
      status: status,
      rating: rating,
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
    );
  }

  @override
  Future<void> deleteBook({required String id}) async {}

  @override
  Future<BookEnrichment?> fetchBookEnrichmentByIsbn({
    required String isbn,
  }) async {
    if (isbn.trim() == '9780140328721') {
      return const BookEnrichment(
        isbn: '9780140328721',
        title: 'Fantastic Mr. Fox',
        author: 'Roald Dahl',
        pages: 96,
        publisher: 'Puffin',
        languageCode: 'eng',
        coverUrl:
            'https://covers.openlibrary.org/b/isbn/9780140328721-L.jpg?default=false',
      );
    }
    return null;
  }

  @override
  Future<void> createSeries({
    required String name,
  }) async {}

  @override
  Future<void> deleteSeries({
    required String name,
  }) async {}

  @override
  Future<List<String>> fetchSeriesNames() async {
    return const [
      'Harry Potter',
      'The Lord of the Rings',
    ];
  }

  @override
  Future<void> createGenre({
    required String name,
  }) async {}

  @override
  Future<void> deleteGenre({
    required String name,
  }) async {}

  @override
  Future<List<String>> fetchGenreNames() async {
    return const [
      'fantasy',
      'science_fiction',
      'romance',
    ];
  }
}
