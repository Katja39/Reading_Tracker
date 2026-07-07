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
    this.seriesId,
    this.volume,
    this.genreId,
    this.ageCategory,
    this.releaseDate,
    this.format,
    this.description,
    this.currentPage,
    this.readingStartDate,
    this.readingEndDate,
    this.createdAt,
    this.updatedAt,
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
  final String? seriesId;
  final int? volume;
  final String? genreId;
  final String? ageCategory;
  final String? releaseDate;
  final String? format;
  final String? description;
  final int? currentPage;
  final String? readingStartDate;
  final String? readingEndDate;
  final String? createdAt;
  final String? updatedAt;

  factory Book.fromJson(Map<String, dynamic> json) {
    final ratingValue = json['rating'];
    final pagesValue = json['pages'];
    final volumeValue = json['volume'];
    final currentPageValue = json['currentPage'];
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
      seriesId: json['series_id'] as String?,
      volume: volumeValue is num ? volumeValue.toInt() : null,
      genreId: json['genre_id'] as String?,
      ageCategory: json['age_category'] as String?,
      releaseDate: json['release_date'] as String?,
      format: json['format'] as String?,
      description: json['description'] as String?,
      currentPage: currentPageValue is num ? currentPageValue.toInt() : null,
      readingStartDate: json['reading_start_date'] as String?,
      readingEndDate: json['reading_end_date'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

