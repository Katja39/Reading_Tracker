class ReadingProgressEntry {
  const ReadingProgressEntry({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.progressDate,
    required this.pageNumber,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String bookId;
  final String userId;
  final String progressDate;
  final int pageNumber;
  final String? createdAt;
  final String? updatedAt;

  factory ReadingProgressEntry.fromJson(Map<String, dynamic> json) {
    final pageNumberValue = json['page_number'];
    return ReadingProgressEntry(
      id: json['id'] as String,
      bookId: json['book_id'] as String,
      userId: json['user_id'] as String,
      progressDate: json['progress_date'] as String,
      pageNumber: pageNumberValue is num ? pageNumberValue.toInt() : 0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}