import '../models/book.dart';
import '../models/book_enrichment.dart';

abstract class BookRepository {
  Future<List<Book>> fetchBooks();

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
  });

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
  });

  Future<void> deleteBook({
    required String id,
  });

  Future<BookEnrichment?> fetchBookEnrichmentByIsbn({
    required String isbn,
  });
}
