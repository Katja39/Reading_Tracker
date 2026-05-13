class Book {
  String id;
  String userId;

  String title;
  String author;

  String? isbn;

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

## Implementierungsstand (Phase 1)

Bereits in Datenbank + API umgesetzt:
- `id`
  - DB: `books.id UUID PRIMARY KEY`
  - API: `id: string`
- `userId`
  - DB: `books.user_id UUID` (FK auf `users.id`)
  - API: `user_id: string`
- `title`
  - DB: `books.title TEXT NOT NULL`
  - API: `title: string`
- `author`
  - DB: `books.author TEXT NOT NULL`
  - API: `author: string`
- `status`
  - DB: `books.status TEXT NOT NULL DEFAULT 'unread'`
  - API: `status: string` (`unread|reading|read|paused|dnf`)
- `rating`
  - DB: `books.rating DOUBLE PRECISION`
  - API: `rating: float | null`
- `isbn`
  - DB: `books.isbn TEXT`
  - API: `isbn: string | null`
- `pages`
  - DB: `books.pages INTEGER` mit Check `pages > 0` (wenn gesetzt)
  - API: `pages: int | null`
- `publisher`
  - DB: `books.publisher TEXT`
  - API: `publisher: string | null`
- `languageCode`
  - DB: `books.language_code TEXT`
  - API: `language_code: string | null` (Request/Response)
- `coverUrl`
  - DB: `books.cover_url TEXT`
  - API: `cover_url: string | null` (Request/Response)

Noch nicht umgesetzt (folgt in weiteren Schritten):
- `startDate`, `endDate`
- `highlight`, `lowlight`
- `seriesId`, `volume`
- `genreId`, `ageCategory`
- `releaseDate`, `format`
- `howAcquired`, `whereAcquired`
- `authorOriginId`, `authorGender`
- `acquiredOn`, `priceCents`
- `notes`, `totalReadingMinutes`
- `createdAt`, `updatedAt`, `deletedAt`
