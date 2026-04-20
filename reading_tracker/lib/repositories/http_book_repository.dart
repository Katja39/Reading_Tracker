import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/book.dart';
import 'book_repository.dart';

class HttpBookRepository implements BookRepository {
  HttpBookRepository({
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
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/books'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'author': author,
        'status': status,
      }),
    );
    _throwIfError(response);

    return Book.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<Book> updateBookAuthor({
    required String id,
    required String author,
  }) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/books/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'author': author,
      }),
    );
    _throwIfError(response);

    return Book.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  void _throwIfError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(
      'API request failed (${response.statusCode}): ${response.body}',
    );
  }
}
