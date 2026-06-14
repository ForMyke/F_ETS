# Alumno Feature — Test Documentation

## Overview

The alumno feature handles student authentication, registration, exam enrollment (inscripción), and viewing enrolled exams with grades.  
The BLoC depends directly on `AlumnoRemoteDataSource` (no repository layer).

All tests live under `test/features/alumno/`.

---

## Test Files

| File | Type | Status | Tests |
|------|------|--------|-------|
| `bloc/alumno_bloc_test.dart` | BLoC unit | ✅ 4/4 pass | Pre-existing, full rewrite to fix null-safety |

**Total: 4 tests, 4 pass**

---

## Test Cases

### `alumno_bloc_test.dart`

| # | Test name | Expected outcome |
|---|-----------|-----------------|
| 1 | initial state | `AlumnoInitial` |
| 2 | AlumnoLoginSubmitted → success | `[AlumnoLoading, AlumnoAuthenticated(perfil.idAlumno == 'al-1')]` |
| 3 | AlumnoLoginSubmitted → datasource throws | `[AlumnoLoading, AlumnoAuthFailure('Credenciales incorrectas.')]` |
| 4 | AlumnoInscribirseRequested → already enrolled | `[AlumnoInscribiendose, AlumnoInscripcionFailure('Ya estás inscrito a este examen.')]`, verifies `inscribirse` is NOT called |

---

## Mock Strategy

`AlumnoBloc` depends on `AlumnoRemoteDataSource` which has 9 methods returning non-nullable Futures.  
All are overridden with the `noSuchMethod` pattern:

```dart
class MockAlumnoRemoteDataSource extends Mock implements AlumnoRemoteDataSource {
  @override
  Future<AlumnoProfile> login({required String correo, required String password}) =>
      super.noSuchMethod(
        Invocation.method(#login, [], {#correo: correo, #password: password}),
        returnValue: Future.value(_defaultProfile),
      ) as Future<AlumnoProfile>;

  @override
  Future<bool> yaInscrito({required String idAlumno, required String idEts}) =>
      super.noSuchMethod(
        Invocation.method(#yaInscrito, [], {#idAlumno: idAlumno, #idEts: idEts}),
        returnValue: Future.value(false),
      ) as Future<bool>;
  // + 7 more overrides: logout, getPerfilActual, register,
  //   getExamsDisponibles, inscribirse, getMisInscripciones,
  //   getCarreras, getPlanes
}
```

**Important:** `anyNamed('correo')` causes a compilation error in Dart 3.x because `anyNamed<T>()` infers `Null`, which is not assignable to `required String`. All `when()` stubs use concrete values instead.

---

## Gaps and Recommendations

| Gap | Recommendation |
|-----|---------------|
| `AlumnoInscribirseRequested` — happy path (enrollment succeeds) | Add test verifying `[AlumnoInscribiendose, AlumnoInscripcionExitosa]` |
| `AlumnoLogoutRequested` | Add test for logout flow |
| `AlumnoMisInscripcionesRequested` | Add test for loading enrolled exams list |
| `AlumnoRegistroSubmitted` | Add test for registration flow |
| No widget tests for `AlumnoInscripcionesPage` or `AlumnoShellPage` | These pages use complex state — add widget tests with `BlocProvider` injection |
| Architecture: BLoC → datasource directly (no repository) | Consider `AlumnoRepository` to decouple BLoC from HTTP implementation |
