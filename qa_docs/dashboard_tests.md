# Dashboard Feature — Test Documentation

## Overview

The dashboard feature displays aggregate statistics for the current ETS period (total exams, breakdown by carrera, next upcoming exam, salones in use).  
It follows full Clean Architecture: `DashboardRepository` → `GetDashboardUseCase` → BLoC, with `DashboardStatsModel` for JSON deserialization.

All tests live under `test/features/dashboard/`.

---

## Test Files

| File | Type | Status | Tests |
|------|------|--------|-------|
| `usecase/get_dashboard_usecase_test.dart` | UseCase unit | ✅ 6/6 pass | New |
| `model/dashboard_stats_model_test.dart` | Model unit | ✅ 14/14 pass | New |

**Total: 20 tests, 20 pass**

---

## Test Cases

### `get_dashboard_usecase_test.dart`

| # | Test name | Expected outcome |
|---|-----------|-----------------|
| 1 | returns `Right(DashboardStats)` when repository succeeds | `Right<Failure, DashboardStats>(tStats)` |
| 2 | returns `Left(ServerFailure)` when repository fails | `Left<Failure, DashboardStats>(ServerFailure())` |
| 3 | delegates entirely to `repository.getStats()` | `verify(repository.getStats()).called(1)` + `verifyNoMoreInteractions(repository)` |
| 4 | result contains expected `totalExams` | `stats.totalExams == 10` |
| 5 | result contains expected `periodoNombre` | `stats.periodoNombre == 'ETS Enero 2026'` |
| 6 | handles null `proximoExamen` gracefully | `stats.proximoExamen == null` |

### `dashboard_stats_model_test.dart`

**Fixture JSON:**
```json
{
  "totalExams": 12,
  "periodoNombre": "ETS Enero 2026",
  "examsByCarrera": { "ISC": 5, "IIA": 3, "LCD": 4 },
  "proximoExamen": "2026-06-12T09:00:00.000",
  "salonesEnUso": 6
}
```

| # | Test name | Expected outcome |
|---|-----------|-----------------|
| 1 | fromJson — `totalExams` | `12` |
| 2 | fromJson — `periodoNombre` | `'ETS Enero 2026'` |
| 3 | fromJson — `examsByCarrera` keys | `['ISC', 'IIA', 'LCD']` |
| 4 | fromJson — `examsByCarrera` values | `[5, 3, 4]` |
| 5 | fromJson — `proximoExamen` is a DateTime | `isA<DateTime>()` |
| 6 | fromJson — `proximoExamen` year | `2026` |
| 7 | fromJson — `salonesEnUso` | `6` |
| 8 | fromJson — null `proximoExamen` | `stats.proximoExamen == null` |
| 9 | is a `DashboardStats` | `isA<DashboardStats>()` |
| 10 | toJson — `totalExams` round-trip | `12` |
| 11 | toJson — `periodoNombre` round-trip | `'ETS Enero 2026'` |
| 12 | toJson — `salonesEnUso` round-trip | `6` |
| 13 | toJson — `examsByCarrera` round-trip | same map |
| 14 | toJson — null `proximoExamen` round-trip | `null` in JSON |

---

## Mock Strategy

`MockDashboardRepository` uses the `noSuchMethod` pattern for `getStats()`:

```dart
class MockDashboardRepository extends Mock implements DashboardRepository {
  @override
  Future<Either<Failure, DashboardStats>> getStats() =>
      super.noSuchMethod(
        Invocation.method(#getStats, []),
        returnValue: Future.value(
          Left<Failure, DashboardStats>(const ServerFailure()),
        ),
      ) as Future<Either<Failure, DashboardStats>>;
}
```

Note: `verifyNoMoreInteractions(repository)` requires that `verify(repository.getStats()).called(1)` is called **first**. Skipping the `verify` step causes `verifyNoMoreInteractions` to throw even when no unexpected calls occurred.

---

## Gaps and Recommendations

| Gap | Recommendation |
|-----|---------------|
| No BLoC tests for `DashboardBloc` (if it exists) | Add BLoC tests once dashboard BLoC is implemented |
| `DashboardRepositoryImpl` untested | Add data-layer tests for HTTP response → `DashboardStatsModel` mapping |
| No tests for empty `examsByCarrera` map | Add edge-case test for empty carrera map |
| Widget tests for `DashboardPage` | Add widget tests to verify stat cards render with mocked BLoC |
