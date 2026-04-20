import '../models/book.dart';

abstract class BookRepository {
  Future<List<Book>> fetchBooks();

  Future<Book> createBook({
    required String title,
    required String author,
    required String status,
  });

  Future<Book> updateBookAuthor({
    required String id,
    required String author,
  });
}
