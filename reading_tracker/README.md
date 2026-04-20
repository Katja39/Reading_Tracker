# reading_tracker

Reading Tracker is a Flutter web application with a REST backend and PostgreSQL.

## Local Setup

1. Copy `.env.example` to `.env` and adjust values as required.

```powershell
docker compose up --build
```

If the database schema has changed, restart the containers with a fresh volume:

```powershell
docker compose down -v
docker compose up --build
```

3. Install Flutter dependencies:

```powershell
flutter pub get
```

4. Run the web app against the local API:

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

## Android

For local testing on an emulator or device:

```powershell
flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

For a physical device on the same network, use the host machine IP instead of `10.0.2.2`, for example:

```powershell
flutter run -d android --dart-define=API_BASE_URL=http://192.168.178.34:8080
```

Build APK:

```powershell
flutter build apk --dart-define=API_BASE_URL=https://your-api.example.com
```

## Services

- PostgreSQL: `localhost:5432`
- REST API: `http://localhost:8080`
