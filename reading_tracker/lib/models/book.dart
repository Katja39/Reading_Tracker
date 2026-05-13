class Book {
  const Book({
    required this.id,
    required this.userId,
    required this.title,
    required this.author,
    required this.status,
    this.rating,
    this.isbn,
    this.pages,
    this.publisher,
    this.languageCode,
    this.coverUrl,
  });

  final String id;
  final String userId;
  final String title;
  final String author;
  final String status;
  final double? rating;
  final String? isbn;
  final int? pages;
  final String? publisher;
  final String? languageCode;
  final String? coverUrl;

  factory Book.fromJson(Map<String, dynamic> json) {
    final ratingValue = json['rating'];
    final pagesValue = json['pages'];
    return Book(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      status: json['status'] as String,
      rating: ratingValue is num ? ratingValue.toDouble() : null,
      isbn: json['isbn'] as String?,
      pages: pagesValue is num ? pagesValue.toInt() : null,
      publisher: json['publisher'] as String?,
      languageCode: json['language_code'] as String?,
      coverUrl: json['cover_url'] as String?,
    );
  }
}
