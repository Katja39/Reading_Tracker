import '../models/book.dart';

abstract class BookRepository {
  Future<List<Book>> fetchBooks();

  Future<Book> createBook({
    required String title,
    required String author,
    required String status,
    double? rating,
  });

  Future<Book> updateBook({
    required String id,
    required String userId,
    required String title,
    required String author,
    required String status,
    double? rating,
  });

  Future<void> deleteBook({
    required String id,
  });
}
