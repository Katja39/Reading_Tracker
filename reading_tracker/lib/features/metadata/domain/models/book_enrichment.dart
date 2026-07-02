class BookEnrichment {
  const BookEnrichment({
    required this.isbn,
    this.title,
    this.author,
    this.pages,
    this.publisher,
    this.languageCode,
    this.coverUrl,
    this.seriesId,
    this.genreId,
    this.ageCategory,
    this.releaseDate,
    this.format,
    this.description,
  });

  final String isbn;
  final String? title;
  final String? author;
  final int? pages;
  final String? publisher;
  final String? languageCode;
  final String? coverUrl;
  final String? seriesId;
  final String? genreId;
  final String? ageCategory;
  final String? releaseDate;
  final String? format;
  final String? description;

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
      seriesId: json['series_id'] as String?,
      genreId: json['genre_id'] as String?,
      ageCategory: json['age_category'] as String?,
      releaseDate: json['release_date'] as String?,
      format: json['format'] as String?,
      description: json['description'] as String?,
    );
  }
}
