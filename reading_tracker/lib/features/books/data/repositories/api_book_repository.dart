import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../../../metadata/domain/models/book_enrichment.dart';

class ApiBookRepository implements BookRepository {
  ApiBookRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  @override
  Future<List<Book>> fetchBooks() async {
    final response = await _client.get(Uri.parse('$baseUrl/books'));
    _throwIfError(response);

    final jsonList = jsonDecode(response.body) as List<dynamic>;
    return jsonList
        .map((item) => Book.fromJson(item as Map<String, dynamic>))
        .toList();
  }

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
    final payload = <String, dynamic>{
      'title': title,
      'author': author,
      'status': status,
    };
    if (rating != null) {
      payload['rating'] = rating;
    }
    if (isbn != null) {
      payload['isbn'] = isbn;
    }
    if (pages != null) {
      payload['pages'] = pages;
    }
    if (publisher != null) {
      payload['publisher'] = publisher;
    }
    if (languageCode != null) {
      payload['language_code'] = languageCode;
    }
    if (coverUrl != null) {
      payload['cover_url'] = coverUrl;
    }
    if (seriesId != null) {
      payload['series_id'] = seriesId;
    }
    if (volume != null) {
      payload['volume'] = volume;
    }
    if (genreId != null) {
      payload['genre_id'] = genreId;
    }
    if (ageCategory != null) {
      payload['age_category'] = ageCategory;
    }
    if (releaseDate != null) {
      payload['release_date'] = releaseDate;
    }
    if (format != null) {
      payload['format'] = format;
    }

    final response = await _client.post(
      Uri.parse('$baseUrl/books'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    _throwIfError(response);

    return Book.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
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
    final payload = <String, dynamic>{
      'title': title,
      'author': author,
      'status': status,
    };
    if (rating != null) {
      payload['rating'] = rating;
    }
    if (isbn != null) {
      payload['isbn'] = isbn;
    }
    if (pages != null) {
      payload['pages'] = pages;
    }
    if (publisher != null) {
      payload['publisher'] = publisher;
    }
    if (languageCode != null) {
      payload['language_code'] = languageCode;
    }
    if (coverUrl != null) {
      payload['cover_url'] = coverUrl;
    }
    if (seriesId != null) {
      payload['series_id'] = seriesId;
    }
    if (volume != null) {
      payload['volume'] = volume;
    }
    if (genreId != null) {
      payload['genre_id'] = genreId;
    }
    if (ageCategory != null) {
      payload['age_category'] = ageCategory;
    }
    if (releaseDate != null) {
      payload['release_date'] = releaseDate;
    }
    if (format != null) {
      payload['format'] = format;
    }

    final response = await _client.put(
      Uri.parse('$baseUrl/books/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    _throwIfError(response);

    final trimmedBody = response.body.trim();
    if (trimmedBody.isEmpty) {
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

    try {
      return Book.fromJson(jsonDecode(trimmedBody) as Map<String, dynamic>);
    } on FormatException {
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
  }

  @override
  Future<void> deleteBook({
    required String id,
  }) async {
    final resourceUri = Uri.parse('$baseUrl/books/$id');
    final responses = <http.Response>[];

    final deleteResponse = await _client.delete(resourceUri);
    responses.add(deleteResponse);
    if (_isSuccess(deleteResponse)) {
      return;
    }

    if (deleteResponse.statusCode == 404 || deleteResponse.statusCode == 405) {
      final postDeleteResponse = await _client.post(
        Uri.parse('$baseUrl/books/$id/delete'),
      );
      responses.add(postDeleteResponse);
      if (_isSuccess(postDeleteResponse)) {
        return;
      }

      final postDeleteAltResponse = await _client.post(
        Uri.parse('$baseUrl/books/delete/$id'),
      );
      responses.add(postDeleteAltResponse);
      if (_isSuccess(postDeleteAltResponse)) {
        return;
      }
    }

    final latestResponse = responses.last;
    throw Exception(
      'Delete request failed after fallback attempts '
      '(${latestResponse.statusCode}): ${latestResponse.body}',
    );
  }

  @override
  Future<BookEnrichment?> fetchBookEnrichmentByIsbn({
    required String isbn,
  }) async {
    final trimmedIsbn = isbn.trim();
    if (trimmedIsbn.isEmpty) {
      return null;
    }

    final response = await _client.get(
      Uri.parse(
        '$baseUrl/isbn/enrich?isbn=${Uri.encodeQueryComponent(trimmedIsbn)}',
      ),
    );

    if (response.statusCode == 404) {
      return null;
    }

    _throwIfError(response);
    return BookEnrichment.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  @override
  Future<List<String>> fetchSeriesNames() async {
    final response = await _client.get(Uri.parse('$baseUrl/series'));
    _throwIfError(response);

    final jsonList = jsonDecode(response.body) as List<dynamic>;
    return jsonList
        .map((item) => (item as Map<String, dynamic>)['name'] as String)
        .where((name) => name.trim().isNotEmpty)
        .toList();
  }

  @override
  Future<void> createSeries({
    required String name,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/series'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );
    _throwIfError(response);
  }

  @override
  Future<void> deleteSeries({
    required String name,
  }) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/series/${Uri.encodeComponent(name)}'),
    );
    _throwIfError(response);
  }

  @override
  Future<List<String>> fetchGenreNames() async {
    final response = await _client.get(Uri.parse('$baseUrl/genres'));
    _throwIfError(response);

    final jsonList = jsonDecode(response.body) as List<dynamic>;
    return jsonList
        .map((item) => (item as Map<String, dynamic>)['name'] as String)
        .where((name) => name.trim().isNotEmpty)
        .toList();
  }

  @override
  Future<void> createGenre({
    required String name,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/genres'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );
    _throwIfError(response);
  }

  @override
  Future<void> deleteGenre({
    required String name,
  }) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/genres/${Uri.encodeComponent(name)}'),
    );
    _throwIfError(response);
  }

  void _throwIfError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(
      'API request failed (${response.statusCode}): ${response.body}',
    );
  }

  bool _isSuccess(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
