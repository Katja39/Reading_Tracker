import 'package:flutter_test/flutter_test.dart';
import 'package:reading_tracker/app.dart';
import 'package:reading_tracker/models/book.dart';
import 'package:reading_tracker/repositories/book_repository.dart';

void main() {
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
}

class FakeBookRepository implements BookRepository {
  @override
  Future<Book> createBook({
    required String title,
    required String author,
    required String status,
  }) async {
    return Book(
      id: 'book-1',
      userId: 'user-1',
      title: title,
      author: author,
      status: status,
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
      ),
      Book(
        id: 'book-2',
        userId: 'user-1',
        title: 'Second Book',
        author: 'Second Author',
        status: 'unread',
      ),
    ];
  }

  @override
  Future<Book> updateBookAuthor({
    required String id,
    required String author,
  }) async {
    return Book(
      id: id,
      userId: 'user-1',
      title: 'Sample Book',
      author: author,
      status: 'reading',
    );
  }
}
