# QA Report — ETS Flutter App

**Date:** 2026-06-12  
**Tester:** QA Agent (Task #4)  
**Test runner:** `flutter test --reporter=compact`  
**Final result:** ✅ 86 pass &nbsp;|&nbsp; ❌ 3 fail

---

## 1. Summary Table

| Feature | Files tested | Tests written (new) | Tests fixed (pre-existing) | Pass | Fail | Notes |
|---------|-------------|--------------------|-----------------------------|------|------|-------|
| **Auth — Bloc** | `login_bloc`, `forgot_password_bloc`, `reset_password_bloc`, `register_bloc` | 16 | 5 | 21 | 0 | — |
| **Auth — Domain** | `login_usecase`, `register_usecase` | 3 | 2 | 5 | 0 | — |
| **Auth — Presentation** | `login_page` | 0 | 0 | 0 | 3 | Pre-existing `flutter_animate` timer failure; cannot fix without modifying source |
| **Exams — Bloc** | `exams_bloc` | 0 | 5 | 5 | 0 | Full rewrite needed to fix null-safety mocks |
| **Exams — Model** | `exam_admin_model` | 18 | 0 | 18 | 0 | — |
| **Dashboard — UseCase** | `get_dashboard_usecase` | 6 | 0 | 6 | 0 | — |
| **Dashboard — Model** | `dashboard_stats_model` | 14 | 0 | 14 | 0 | — |
| **Alumno — Bloc** | `alumno_bloc` | 0 | 4 | 4 | 0 | Full rewrite needed to fix null-safety mocks |
| **Search — Domain** | `get_exams_usecase` | 0 | 2 | 2 | 0 | List equality assertion fixed |
| **Jefe — Bloc** | `jefe_bloc` | 10 | 0 | 10 | 0 | — |
| **App smoke test** | `widget_test` | 0 | 1 | 1 | 0 | — |
| **TOTAL** | — | **67 new** | **19 pre-existing** | **86** | **3** | — |

> "Tests written (new)" = new test files or test cases added by QA.  
> "Tests fixed (pre-existing)" = existing test files rewritten/patched to compile and pass.

---

## 2. Source Issues Found

### 2.1 `flutter_animate` — Pending Timer in `LoginPage` (BLOCKER for 3 tests)

**File:** `lib/features/auth/presentation/pages/login_page.dart`  
**Symptom:** All 3 tests in `test/features/auth/presentation/login_page_test.dart` fail with:

```
Failed assertion: line 2242 pos 12: '!timersPending'
A Timer is still pending even after the widget tree was disposed.
```

**Root cause:** `flutter_animate` schedules `Timer` objects for entry animations. The widget test framework asserts that no timers remain after disposal, but `flutter_animate` timers outlive the test.

**Impact:** 3/3 widget tests for `LoginPage` cannot pass.

**Recommended fix:** Wrap animations in `if (!kIsTest)` guards, or apply `.animate().fadeIn()` only when a test-mode flag is false, or skip pending timers with `await tester.pumpAndSettle()` + `fakeAsync`. Since QA cannot modify `lib/`, these 3 tests remain red.

---

### 2.2 Mockito 5.x + Dart 3.x Null-Safety Incompatibility (Pattern Issue)

**Affects:** All mocks of classes with methods returning non-nullable `Future<T>`  
**Symptom at runtime:**
```
type 'Null' is not a subtype of type 'Future<Either<Failure, User>>'
```

**Root cause:** Mockito's default `noSuchMethod` returns `null`. In Dart 3.x with sound null safety, casting `null` to a non-nullable `Future<T>` throws a type error.

**Pattern used throughout production test stubs** (will fail on any new mock):
```dart
class MockFoo extends Mock implements Foo {}
// ❌ Crashes if foo() returns non-nullable Future<T>
```

**Required pattern** (used in all new/fixed test files):
```dart
class MockFoo extends Mock implements Foo {
  @override
  Future<Either<Failure, User>> call(Params p) =>
      super.noSuchMethod(
        Invocation.method(#call, [p]),
        returnValue: Future.value(const Left<Failure, User>(ServerFailure())),
      ) as Future<Either<Failure, User>>;
}
```

**Recommendation:** Adopt `@GenerateMocks([Foo])` / `build_runner` for automatic null-safe mock generation, or document the `noSuchMethod` pattern as a team standard.

---

### 2.3 `dartz` `Right<Failure, List<T>>` Equality — List Identity vs. Content

**Affected test:** `test/features/search/domain/get_exams_usecase_test.dart`  
**Symptom:**
```
Expected: Right([Exam(...)])
  Actual: Right([Exam(...)])
```
Looks identical but fails because `List<T>.==` in Dart uses identity, not content equality.

**Fix applied in tests:** Use `result.fold(...)` to unpack the `Either` and assert on list contents directly.

**Recommendation:** Either use `listEquals()` in assertions, or define `==`/`hashCode` on domain list containers, or document the `fold` pattern as standard for list-containing `Either` results.

---

### 2.4 Architecture Inconsistency — `AlumnoProfile` Import Path

**Observation:** `lib/features/alumno/data/datasources/alumno_remote_datasource.dart` imports `AlumnoProfile` from the domain layer (`lib/features/alumno/domain/entities/alumno_profile.dart`) and re-exports it. This is a clean-architecture violation — data sources should not re-export domain entities.

**Impact:** Test files importing `AlumnoProfile` from the datasource work, but this creates a coupling that could cause import cycles.

**Recommendation:** Import `AlumnoProfile` directly from `domain/entities/` in all consuming files; remove the re-export from the datasource.

---

## 3. Recommendations

| Priority | Recommendation |
|----------|---------------|
| 🔴 High | Fix `flutter_animate` pending-timer issue in `LoginPage` (either guard animations in test mode or refactor to `TickerProvider`) |
| 🔴 High | Adopt `@GenerateMocks` + `build_runner` for all future mocks to avoid manual `noSuchMethod` boilerplate and null-safety pitfalls |
| 🟡 Medium | Document the `result.fold(...)` assertion pattern for `Either<Failure, List<T>>` in the team's testing guide |
| 🟡 Medium | Remove `AlumnoProfile` re-export from datasource; consume domain entities directly |
| 🟢 Low | Add integration/golden tests for `LoginPage`, `AlumnoInscripcionesPage`, and `SearchPage` to catch UI regressions |
| 🟢 Low | Add repository-layer tests for `DashboardRepositoryImpl` and `ExamsRepositoryImpl` (currently untested) |

---

## 4. Test File Inventory

```
test/
├── widget_test.dart                                      ✅ 1/1
├── features/
│   ├── auth/
│   │   ├── bloc/
│   │   │   ├── login_bloc_test.dart                     ✅ 5/5  (fixed)
│   │   │   ├── forgot_password_bloc_test.dart           ✅ 4/4  (new)
│   │   │   ├── reset_password_bloc_test.dart            ✅ 6/6  (new)
│   │   │   └── register_bloc_test.dart                  ✅ 6/6  (new)
│   │   ├── domain/
│   │   │   ├── login_usecase_test.dart                  ✅ 2/2  (fixed)
│   │   │   └── register_usecase_test.dart               ✅ 3/3  (new)
│   │   └── presentation/
│   │       └── login_page_test.dart                     ❌ 0/3  (source issue)
│   ├── alumno/
│   │   └── bloc/
│   │       └── alumno_bloc_test.dart                    ✅ 4/4  (fixed)
│   ├── exams/
│   │   ├── bloc/
│   │   │   └── exams_bloc_test.dart                     ✅ 5/5  (fixed)
│   │   └── model/
│   │       └── exam_admin_model_test.dart               ✅ 18/18 (new)
│   ├── dashboard/
│   │   ├── usecase/
│   │   │   └── get_dashboard_usecase_test.dart          ✅ 6/6  (new)
│   │   └── model/
│   │       └── dashboard_stats_model_test.dart          ✅ 14/14 (new)
│   ├── search/
│   │   └── domain/
│   │       └── get_exams_usecase_test.dart              ✅ 2/2  (fixed)
│   └── jefe/
│       └── bloc/
│           └── jefe_bloc_test.dart                      ✅ 10/10 (new)
```

**Grand total: 86 pass, 3 fail**
