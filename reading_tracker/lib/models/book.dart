class Book {
  const Book({
    required this.id,
    required this.userId,
    required this.title,
    required this.author,
    required this.status,
    this.rating,
  });

  final String id;
  final String userId;
  final String title;
  final String author;
  final String status;
  final double? rating;

  factory Book.fromJson(Map<String, dynamic> json) {
    final ratingValue = json['rating'];
    return Book(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      status: json['status'] as String,
      rating: ratingValue is num ? ratingValue.toDouble() : null,
    );
  }
}
