# Jefe de Academia Feature — Test Documentation

## Overview

The *jefe de academia* feature handles authentication, viewing assigned ETS sessions, loading enrolled students per session, and saving student grades.  
The BLoC depends directly on `JefeRemoteDataSource` (no repository wrapper).

All tests live under `test/features/jefe/`.

---

## Test Files

| File | Type | Status | Tests |
|------|------|--------|-------|
| `bloc/jefe_bloc_test.dart` | BLoC unit | ✅ 10/10 pass | New |

**Total: 10 tests, 10 pass**

---

## Test Cases

### `jefe_bloc_test.dart`

| # | Test name | Expected outcome |
|---|-----------|-----------------|
| 1 | initial state | `JefeInitial` |
| 2 | JefeLoginSubmitted → success | `[JefeLoading, JefeAuthenticated(perfil)]` |
| 3 | JefeLoginSubmitted → datasource throws | `[JefeLoading, JefeAuthFailure(message)]` |
| 4 | JefeLogoutRequested → success | `JefeInitial` emitted after logout |
| 5 | JefeEtsRequested → success | `[JefeEtsCargando, JefeEtsCargada(etsList)]` |
| 6 | JefeEtsRequested → datasource throws | `[JefeEtsCargando, JefeEtsError(message)]` |
| 7 | JefeAlumnosRequested → success | `[JefeAlumnosCargando, JefeAlumnosCargados(alumnosList)]` |
| 8 | JefeAlumnosRequested → datasource throws | `[JefeAlumnosCargando, JefeAlumnosError(message)]` |
| 9 | JefeCalificacionGuardada → success | `[JefeGuardando, JefeCalificacionGuardadaExito]` |
| 10 | JefeCalificacionGuardada → datasource throws | `[JefeGuardando, JefeCalificacionError(message)]` |

---

## Mock Strategy

`JefeBloc` depends on `JefeRemoteDataSource` which has 5 methods. All are overridden:

```dart
class MockJefeRemoteDataSource extends Mock implements JefeRemoteDataSource {
  static const _defaultPerfil = JefeProfile(
    idJefe: '', nombre: '', apellidoPaterno: '',
    apellidoMaterno: '', correo: '',
  );

  @override
  Future<JefeProfile> login({required String correo, required String password}) =>
      super.noSuchMethod(
        Invocation.method(#login, [], {#correo: correo, #password: password}),
        returnValue: Future.value(_defaultPerfil),
      ) as Future<JefeProfile>;

  @override
  Future<void> logout() =>
      super.noSuchMethod(
        Invocation.method(#logout, []),
        returnValue: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<List<EtsDeJefeItem>> getEtsDeJefe(String idJefe) =>
      super.noSuchMethod(
        Invocation.method(#getEtsDeJefe, [idJefe]),
        returnValue: Future.value(<EtsDeJefeItem>[]),
      ) as Future<List<EtsDeJefeItem>>;

  @override
  Future<List<AlumnoInscritoItem>> getAlumnosInscritos(String idEts) =>
      super.noSuchMethod(
        Invocation.method(#getAlumnosInscritos, [idEts]),
        returnValue: Future.value(<AlumnoInscritoItem>[]),
      ) as Future<List<AlumnoInscritoItem>>;

  @override
  Future<void> guardarCalificacion({
    required String idInscripcion,
    required double calificacion,
  }) =>
      super.noSuchMethod(
        Invocation.method(#guardarCalificacion, [], {
          #idInscripcion: idInscripcion,
          #calificacion: calificacion,
        }),
        returnValue: Future<void>.value(),
      ) as Future<void>;
}
```

**Key points:**
- `Future<void>` returns (`logout`, `guardarCalificacion`) technically don't need `noSuchMethod` overrides, but are included for explicitness and to avoid Mockito interaction-tracking issues.
- Concrete argument values are used in `when()` stubs (e.g., `correo: 'jefe@ipn.mx'`) — not `anyNamed()`, which fails in Dart 3.x with `Null` type inference.

---

## Gaps and Recommendations

| Gap | Recommendation |
|-----|---------------|
| No widget tests for `JefeShellPage` | Add widget tests with mocked `JefeBloc` for ETS list and grade entry UI |
| `guardarCalificacion` — boundary values (0.0, 10.0, negative) | Add edge-case tests for grade validation |
| No test for multiple concurrent grade saves | Add test verifying BLoC handles sequential `JefeCalificacionGuardada` events |
| Architecture: BLoC → datasource directly (no repository) | Consider `JefeRepository` to enable unit testing without HTTP coupling |
| `JefeRemoteDataSource` implementation untested | Add HTTP/mock-http tests for JSON response mapping |
