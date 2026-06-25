# KAI Post Generator

Flutter app to generate movie/series post JSON via TMDB API.

## Features
- Search TMDB (movies & series)
- Auto-fill title, year, poster, overview, genres
- Add download links, watch links
- For series: add seasons and episodes
- Auto-fill from previous post
- Generate clean JSON output (copy to clipboard)
- Exported format matches the user's spec (movies array with movies & series)

## Build
GitHub Actions workflow builds a release APK on every push to `main`.
APK is published as a GitHub Release artifact.

## Local development
```bash
flutter pub get
flutter run
```

## TMDB API Key
Hardcoded in `lib/services/tmdb_service.dart` for simplicity.
