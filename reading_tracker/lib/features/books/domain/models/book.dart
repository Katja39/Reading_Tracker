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
    this.howAcquired,
    this.whereAcquired,
    this.authorOriginId,
    this.authorGender,
    this.acquiredOn,
    this.price,
    this.notes,
    this.totalReadingMinutes,
    this.firstPublishYear,
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
  final String? howAcquired;
  final String? whereAcquired;
  final String? authorOriginId;
  final String? authorGender;
  final String? acquiredOn;
  final double? price;
  final String? notes;
  final int? totalReadingMinutes;
  final int? firstPublishYear;
  final String? createdAt;
  final String? updatedAt;

  factory Book.fromJson(Map<String, dynamic> json) {
    final ratingValue = json['rating'];
    final pagesValue = json['pages'];
    final volumeValue = json['volume'];
    final currentPageValue = json['currentPage'];
    final priceValue = json['price'];
    final totalReadingMinutesValue = json['total_reading_minutes'];
    final firstPublishYearValue = json['first_publish_year'];
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
      howAcquired: json['how_acquired'] as String?,
      whereAcquired: json['where_acquired'] as String?,
      authorOriginId: json['author_origin_id'] as String?,
      authorGender: json['author_gender'] as String?,
      acquiredOn: json['acquired_on'] as String?,
      price: priceValue is num ? priceValue.toDouble() : null,
      notes: json['notes'] as String?,
      totalReadingMinutes: totalReadingMinutesValue is num
          ? totalReadingMinutesValue.toInt()
          : null,
      firstPublishYear: firstPublishYearValue is num
          ? firstPublishYearValue.toInt()
          : null,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

