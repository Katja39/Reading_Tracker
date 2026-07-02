import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'features/books/data/repositories/api_book_repository.dart';

const _configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');

String _apiBaseUrl() {
  if (_configuredApiBaseUrl.isNotEmpty) {
    return _configuredApiBaseUrl;
  }

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8080';
  }

  return 'http://localhost:8080';
}

void main() {
  runApp(
    MyApp(
      repository: ApiBookRepository(
        baseUrl: _apiBaseUrl(),
      ),
    ),
  );
}