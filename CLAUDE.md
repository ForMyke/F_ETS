# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

All development runs inside Docker — Flutter is not required locally.

```bash
# First-time setup or after changing pubspec.yaml
make dev-build

# Start dev server with hot-reload (http://localhost:5000)
make dev
make dev-logs     # tail logs

# Production build and serve (http://localhost:8080)
make build-prod
make up

# Run tests (inside dev container)
docker exec -it f_ets_dev flutter test

# Analyze (lint)
docker exec -it f_ets_dev flutter analyze

# Run a single test file
docker exec -it f_ets_dev flutter test test/widget_test.dart
```

Rebuild the image only when `pubspec.yaml` changes; code changes in `lib/` are hot-reloaded via the volume mount.

## Architecture

This is a Flutter web app following **Clean Architecture**, organized by feature under `lib/features/`. Each feature has three layers:

```
features/<name>/
  data/
    datasources/   # Supabase queries (remote) or SharedPreferences (local)
    models/        # JSON ↔ entity mapping
    repositories/  # implements domain repository interface
  domain/
    entities/      # Plain Dart classes (immutable data)
    repositories/  # Abstract interfaces
    usecases/      # Single-responsibility use cases returning Either<Failure, T>
  presentation/
    bloc/          # event / state / bloc files
    pages/
    widgets/
```

### User roles and entry points

The app has three distinct user experiences, each entering through a different shell page:

| Role | Email domain | Entry point |
|---|---|---|
| Public | (none) | `PublicShellPage` → Search, Favorites, Map tabs |
| Alumno | `@alumno.ipn.mx` | `AlumnoShellPage` → Exams + Inscripciones tabs |
| Jefe de Academia | `@ipn.mx` | `JefeShellPage` → ETS list + grade entry |
| Admin | `@ipn.mx` (admin flag) | `AdminShellPage` → Dashboard, Exams, Inscripciones, Catalogs, Jefes tabs |

Role detection happens in `UnifiedLoginPage` by inspecting the email domain at login time.

### Routing

`AppRoutes.onGenerateRoute` (`lib/core/routes/app_routes.dart`) handles all navigation. Routes: `/` (PublicShell), `/login` (UnifiedLogin), `/admin` (AdminShell), `/forgot-password`, `/reset-password`. Dependencies are constructed inline in the route builder — there is no DI container.

### State management

Every feature uses `flutter_bloc`. The pattern is: UI dispatches `Event` → `Bloc` calls datasource/usecase → emits `State`. States carry all data needed to render (including the authenticated profile object when applicable).

**Note:** `AlumnoBloc` calls `AlumnoRemoteDataSource` directly (skipping the repository layer) — this is intentional for that feature.

### Backend

Supabase (PostgreSQL). All table names, column names, and enum values are centralized in `lib/core/constants/api_endpoints.dart` as `Tables`, `Cols`, and `ColValues` constants. Always use these instead of raw strings in datasources.

### Error handling

Domain layer uses `dartz` `Either<Failure, T>`. Concrete `Failure` subtypes are in `lib/core/error/failures.dart`. Datasource errors are typically thrown as exceptions and caught in the bloc; repository impls map exceptions to `Left(Failure)`.

### Local persistence

Only the `favorites` feature uses local storage (`SharedPreferences`). Everything else is fetched from Supabase on demand.

### Theme

`AppColors` and `AppTextStyles` in `lib/core/theme/` are the single source of truth for colors and typography. Both light and dark tokens are defined there. The app respects the system theme (`ThemeMode.system`).
