import '../models/book.dart';
import '../../../metadata/domain/models/book_enrichment.dart';

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
    String? seriesId,
    int? volume,
    String? genreId,
    String? ageCategory,
    String? releaseDate,
    String? format,
    String? description,
    int? currentPage,
    String? readingStartDate,
    String? readingEndDate,
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
    String? seriesId,
    int? volume,
    String? genreId,
    String? ageCategory,
    String? releaseDate,
    String? format,
    String? description,
    int? currentPage,
    String? readingStartDate,
    String? readingEndDate,
  });

  Future<void> deleteBook({
    required String id,
  });

  Future<BookEnrichment?> fetchBookEnrichmentByIsbn({
    required String isbn,
  });

  Future<List<String>> fetchSeriesNames();

  Future<void> createSeries({
    required String name,
  });

  Future<void> deleteSeries({
    required String name,
  });

  Future<List<String>> fetchGenreNames();

  Future<void> createGenre({
    required String name,
  });

  Future<void> deleteGenre({
    required String name,
  });
}

