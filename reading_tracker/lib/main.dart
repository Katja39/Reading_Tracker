import 'package:flutter/material.dart';

import 'app.dart';
import 'repositories/api_book_repository.dart';

void main() {
  runApp(
    MyApp(
      repository: ApiBookRepository(
        baseUrl: const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://localhost:8080',
        ),
      ),
    ),
  );
}
