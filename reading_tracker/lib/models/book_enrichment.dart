class BookEnrichment {
  const BookEnrichment({
    required this.isbn,
    this.title,
    this.author,
    this.pages,
    this.publisher,
    this.languageCode,
    this.coverUrl,
  });

  final String isbn;
  final String? title;
  final String? author;
  final int? pages;
  final String? publisher;
  final String? languageCode;
  final String? coverUrl;

  factory BookEnrichment.fromJson(Map<String, dynamic> json) {
    final pagesValue = json['pages'];
    return BookEnrichment(
      isbn: json['isbn'] as String,
      title: json['title'] as String?,
      author: json['author'] as String?,
      pages: pagesValue is num ? pagesValue.toInt() : null,
      publisher: json['publisher'] as String?,
      languageCode: json['language_code'] as String?,
      coverUrl: json['cover_url'] as String?,
    );
  }
}
