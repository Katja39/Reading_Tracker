import 'package:flutter/material.dart';

import 'pages/book_page.dart';
import 'repositories/book_repository.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.repository,
  });

  final BookRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reading Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F6F4F),
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F2EA),
        useMaterial3: true,
      ),
      home: BookPage(repository: repository),
    );
  }
}
