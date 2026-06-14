# Exams Feature — Test Documentation

## Overview

The exams feature provides admin-level CRUD for ETS exam sessions.  
It uses a direct datasource BLoC (no repository layer) and a rich `ExamListItemModel` with nested JSON.

All tests live under `test/features/exams/`.

---

## Test Files

| File | Type | Status | Tests |
|------|------|--------|-------|
| `bloc/exams_bloc_test.dart` | BLoC unit | ✅ 5/5 pass | Pre-existing, full rewrite to fix null-safety |
| `model/exam_admin_model_test.dart` | Model unit | ✅ 18/18 pass | New |

**Total: 23 tests, 23 pass**

---

## Test Cases

### `exams_bloc_test.dart`

| # | Test name | Expected outcome |
|---|-----------|-----------------|
| 1 | initial state | `ExamsInitial` |
| 2 | ExamsStarted → success | `[ExamsLoading, ExamsSuccess(exams.length == 2)]` |
| 3 | ExamsStarted → datasource throws | `[ExamsLoading, ExamsFailure('Error al cargar exámenes.')]` |
| 4 | ExamDeleted → reloads list | `ExamsSuccess(exams.length == 1)` after delete+reload |
| 5 | ExamDeleted → delete throws | `ExamsFailure('Error al eliminar el examen.')` |

### `exam_admin_model_test.dart`

**Fixture JSON:**
```json
{
  "id_ets": "ets-001",
  "fechahorainicio": "2026-06-12T09:00:00.000",
  "fechahorafin": "2026-06-12T11:00:00.000",
  "turno": "Matutino",
  "estado": "activo",
  "id_periodoets": "P1-2026",
  "id_salon": "salon-1",
  "id_carrera_materia": "cm-1",
  "id_jefeacademia": "jefe-1",
  "salon": { "codigo": "A1", "edificio": { "numero": "3" } },
  "carrera_materia": {
    "id_carrera": "car-1",
    "id_plan": "plan-1",
    "semestre": 4,
    "materia": { "nombre": "Cálculo Diferencial" },
    "carrera": { "acronimo": "ISC" }
  },
  "jefeacademia": {
    "usuario": {
      "nombre": "Juan",
      "apellidopaterno": "López",
      "apellidomaterno": "Pérez"
    }
  }
}
```

| # | Test name | Expected outcome |
|---|-----------|-----------------|
| 1 | fromJson — id | `'ets-001'` |
| 2 | fromJson — fechaInicio | `DateTime(2026, 6, 12, 9)` |
| 3 | fromJson — fechaFin | `DateTime(2026, 6, 12, 11)` |
| 4 | fromJson — turno | `'Matutino'` |
| 5 | fromJson — estado | `'activo'` |
| 6 | fromJson — periodo (id_periodoets) | `'P1-2026'` |
| 7 | fromJson — salon codigo | `'A1'` |
| 8 | fromJson — edificio numero | `'3'` |
| 9 | fromJson — materia nombre | `'Cálculo Diferencial'` |
| 10 | fromJson — carrera acronimo | `'ISC'` |
| 11 | fromJson — semestre | `4` |
| 12 | fromJson — jefeNombre (full name) | `'Juan López Pérez'` |
| 13 | fromJson — id_carrera | `'car-1'` |
| 14 | fromJson — id_plan | `'plan-1'` |
| 15 | fromJson — id_salon | `'salon-1'` |
| 16 | fromJson — id_jefeacademia | `'jefe-1'` |
| 17 | toJson — round-trip id | `'ets-001'` |
| 18 | toJson — round-trip fechahorainicio | ISO string preserved |

---

## Mock Strategy

`ExamsBloc` depends directly on `ExamsRemoteDataSource` (no repository wrapper). The mock overrides all five datasource methods:

```dart
class MockExamsRemoteDataSource extends Mock implements ExamsRemoteDataSource {
  @override
  Future<List<ExamListItem>> getExams() =>
      super.noSuchMethod(
        Invocation.method(#getExams, []),
        returnValue: Future.value(<ExamListItem>[]),
      ) as Future<List<ExamListItem>>;

  // + deleteExam, createExam, updateExam, getFormData
}
```

`Future<void>` methods (`deleteExam`, `createExam`, `updateExam`) do **not** require `noSuchMethod` overrides — Dart special-cases `Future<void>` and Mockito handles it correctly.

---

## Gaps and Recommendations

| Gap | Recommendation |
|-----|---------------|
| No tests for `createExam` or `updateExam` BLoC events | Add tests for `ExamCreated` and `ExamUpdated` events |
| No repository layer — BLoC calls datasource directly | Consider introducing `ExamsRepository` to enable unit testing without network coupling |
| `ExamsRemoteDataSource` implementation untested | Add HTTP/mock-http tests for JSON parsing and endpoint calls |
| `ExamFormData` (dropdown options) not tested in BLoC | Add test for form-data loading flow |
