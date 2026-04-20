import 'package:flutter/material.dart';

import 'app.dart';
import 'repositories/http_book_repository.dart';

void main() {
  runApp(
    MyApp(
      repository: HttpBookRepository(
        baseUrl: const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://localhost:8080',
        ),
      ),
    ),
  );
}
