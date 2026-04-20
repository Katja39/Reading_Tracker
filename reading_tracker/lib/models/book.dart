class Book {
  const Book({
    required this.id,
    required this.userId,
    required this.title,
    required this.author,
    required this.status,
  });

  final String id;
  final String userId;
  final String title;
  final String author;
  final String status;

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      status: json['status'] as String,
    );
  }
}
