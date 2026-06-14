# Search Feature — Test Documentation

## Overview

The search feature lets users filter and browse ETS exam sessions by carrera, semestre, plan, and materia.  
It follows Clean Architecture: `SearchRepository` → `GetExamsUseCase` → BLoC/presentation.

All tests live under `test/features/search/`.

---

## Test Files

| File | Type | Status | Tests |
|------|------|--------|-------|
| `domain/get_exams_usecase_test.dart` | UseCase unit | ✅ 2/2 pass | Pre-existing, fixed |

**Total: 2 tests, 2 pass**

---

## Test Cases

### `get_exams_usecase_test.dart`

| # | Test name | Expected outcome |
|---|-----------|-----------------|
| 1 | returns `Right(list)` when repository succeeds | `result.isRight() == true`, `list.length == 1`, `list.first == tExam` |
| 2 | returns `Left(failure)` when repository fails | `Left<Failure, List<Exam>>(ServerFailure())` |

**Note:** Test #1 does **not** use `expect(result, Right([tExam]))` directly. `dartz`'s `Right.==` compares list values using `List.==`, which in Dart uses identity equality not content equality — so two equal `List<Exam>` instances are not `==`. The fix is:

```dart
expect(result.isRight(), isTrue);
result.fold(
  (f) => fail('Expected Right but got Left: $f'),
  (list) {
    expect(list.length, 1);
    expect(list.first, tExam);  // Exam uses Equatable, so this works
  },
);
```

---

## Mock Strategy

`MockSearchRepository` overrides `getExams()` and `getCarreras()`:

```dart
class MockSearchRepository extends Mock implements SearchRepository {
  @override
  Future<Either<Failure, List<Exam>>> getExams({
    String? carrera,
    int? semestre,
    String? plan,
    String? materia,
  }) =>
      super.noSuchMethod(
        Invocation.method(#getExams, [], {
          #carrera: carrera, #semestre: semestre,
          #plan: plan, #materia: materia,
        }),
        returnValue: Future.value(const Left<Failure, List<Exam>>(ServerFailure())),
      ) as Future<Either<Failure, List<Exam>>>;

  @override
  Future<Either<Failure, List<String>>> getCarreras() =>
      super.noSuchMethod(
        Invocation.method(#getCarreras, []),
        returnValue: Future.value(const Left<Failure, List<String>>(ServerFailure())),
      ) as Future<Either<Failure, List<String>>>;
}
```

`when()` stubs use concrete named-argument values (`carrera: 'ISC'`, `semestre: 1`, `plan: null`, `materia: null`) rather than `anyNamed()` matchers, which would cause a `Null` type inference error in Dart 3.x.

---

## Gaps and Recommendations

| Gap | Recommendation |
|-----|---------------|
| No BLoC tests for `SearchBloc` | Add tests for filter-change events and exam-load success/failure |
| `getCarreras()` usecase not tested | Add use case test for carrera list fetch |
| No widget tests for `SearchPage` | Add widget tests verifying filter UI + results list rendering |
| `SearchRepositoryImpl` untested | Add data-layer tests for HTTP response → `ExamModel` mapping |
| Only 2 test cases — happy path + failure | Add edge cases: empty result list, partial params (null carrera), network failure |
