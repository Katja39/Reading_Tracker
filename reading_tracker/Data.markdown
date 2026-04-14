class Book {
  String id;
  String userId;

  String title;
  String author;

  BookStatus status;

  double? rating;

  DateTime? startDate;
  DateTime? endDate;

  bool highlight;
  bool lowlight;

  String? readingBuddy;

  String? seriesId;
  int? volume;

  int? pages;

  String? genreId;
  AgeCategory? ageCategory;

  DateTime? releaseDate;

  BookFormat? format;

  String? publisher;

  AcquisitionType? howAcquired;
  String? whereAcquired;

  String? authorOriginId;
  AuthorGender? authorGender;

  String? languageId;

  DateTime? acquiredOn;

  int? priceCents;

  String? notes;

  int totalReadingMinutes;

  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;
}

#calculate days

enum AuthorGender {
  female,
  male,
  nonBinary,
  mixed,
  unknown,
}

enum AcquisitionType {
  boughtNew,
  boughtUsed,
  gifted,
  borrowed,
  library
}

enum BookFormat {
  hardcover,
  paperback,
  ebook,
  audiobook,
}

enum AgeCategory {
  children,
  middleGrade,
  youngAdult,
  newAdult,
  adult
}

enum BookStatus {
  unread,
  reading,
  read,
  paused,
  dnf,
}