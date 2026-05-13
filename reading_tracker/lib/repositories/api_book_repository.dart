import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/book.dart';
import '../models/book_enrichment.dart';
import 'book_repository.dart';

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
