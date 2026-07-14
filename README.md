# Reading Tracker App

Reading Tracker is a Flutter app for managing a personal book library. It uses a
REST API backed by PostgreSQL.
Android and browser compatible

## Implemented Functionality

- Book library management with create, edit, delete, and detail views
- Book metadata fields for title, author, status, rating, ISBN, pages,
  publisher, language, cover image, series, volume, genre, age category,
  release date, format, and description
- Daily page tracking for books currently being read
- Reading progress display based on pages read
- Set reading status
- Ratings for read books
- ISBN autofill through the backend using Open Library metadata
- Library overview with cover thumbnails, search, sort, and filters
- Home view showing books that are currently being read
- Series and genre management from the book form, including adding and removing
  entries
- Light and dark theme toggle

## Upcoming Functionality

- Statistics dashboard for yearly reading totals, goals,
  spending, and visual charts
- CSV import and export, including Goodreads import support
- Reading timer with automatic time logging per book
- Notes for individual books, potentially with note/history visualization
- Acquisition tracking, including where and how a book was acquired.
- Budget and price tracking
- Offline support or local caching

## Local Setup

1. Change into the Flutter project directory:

```powershell
cd reading_tracker
```

2. Copy `.env.example` to `.env` and adjust values as required.

3. Start the database and API:

```powershell
docker compose up --build
```

If the database schema has changed, restart the containers with a fresh volume:

```powershell
docker compose down -v
docker compose up --build
```

4. Install Flutter dependencies:

```powershell
flutter pub get
```

5. Optional health check for the API:

```powershell
curl http://localhost:8080/health
```

Expected response:

```json
{"status":"ok"}
```

6. Run the Flutter app against the local API for web:

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

## Android

For local testing on an emulator or device:

```powershell
flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Show available devices:

```powershell
flutter devices
```

For a physical device on the same network, use the host machine IP instead of
`10.0.2.2`, for example:

```powershell
flutter run -d android --dart-define=API_BASE_URL=http://192.168.178.34:8080
```

Build an APK:

```powershell
flutter build apk --dart-define=API_BASE_URL=https://your-api.example.com
```

## Tests

Run Flutter widget/unit tests:

```powershell
flutter test
```

Run static analysis:

```powershell
flutter analyze
```

## Stop Services

Stop API and database containers:

```powershell
docker compose down
```

## Services

- PostgreSQL: `localhost:5432`
- REST API: `http://localhost:8080`
- Open Library API: `https://openlibrary.org`
