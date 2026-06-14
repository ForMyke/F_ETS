# Auth Feature — Test Documentation

## Overview

The auth feature covers login, registration, password recovery (forgot + reset), and password-strength UI.  
All tests live under `test/features/auth/`.

---

## Test Files

| File | Type | Status | Tests |
|------|------|--------|-------|
| `bloc/login_bloc_test.dart` | BLoC unit | ✅ 5/5 pass | Pre-existing, fixed |
| `bloc/forgot_password_bloc_test.dart` | BLoC unit | ✅ 4/4 pass | New |
| `bloc/reset_password_bloc_test.dart` | BLoC unit | ✅ 6/6 pass | New |
| `bloc/register_bloc_test.dart` | BLoC unit | ✅ 6/6 pass | New |
| `domain/login_usecase_test.dart` | UseCase unit | ✅ 2/2 pass | Pre-existing, fixed |
| `domain/register_usecase_test.dart` | UseCase unit | ✅ 3/3 pass | New |
| `presentation/login_page_test.dart` | Widget | ❌ 0/3 pass | Mock fixed (2026-06-13); still fails — new `lib/` compile error |

**Total: 26 tests (23 pass, 3 fail)**

---

## Test Cases

### `login_bloc_test.dart`

| # | Test name | Expected outcome |
|---|-----------|-----------------|
| 1 | initial state | `LoginInitial` |
| 2 | LoginSubmitted → success | `[LoginLoading, LoginSuccess(user)]` |
| 3 | LoginSubmitted → failure | `[LoginLoading, LoginFailure(message)]` |
| 4 | calls use case with correct params | `verify(useCase.call(...)).called(1)` |
| 5 | password visibility toggle | `LoginInitial(isPasswordVisible: true)` |

### `forgot_password_bloc_test.dart`

| # | Test name | Expected outcome |
|---|-----------|-----------------|
| 1 | initial state | `ForgotPasswordInitial` |
| 2 | ForgotPasswordSubmitted → success | `[ForgotPasswordLoading, ForgotPasswordSuccess]` |
| 3 | ForgotPasswordSubmitted → failure | `[ForgotPasswordLoading, ForgotPasswordFailure(msg)]` |
| 4 | calls use case with submitted email | `verify(useCase.call(...)).called(1)` |

### `reset_password_bloc_test.dart`

| # | Test name | Expected outcome |
|---|-----------|-----------------|
| 1 | initial state | `ResetPasswordInitial` |
| 2 | ResetPasswordSubmitted → success | `[ResetPasswordLoading, ResetPasswordSuccess]` |
| 3 | ResetPasswordSubmitted → failure | `[ResetPasswordLoading, ResetPasswordFailure(msg)]` |
| 4 | calls use case with correct params | `verify(useCase.call(...)).called(1)` |
| 5 | toggle password visibility | `isPasswordVisible: true` |
| 6 | toggle confirm password visibility | `isConfirmPasswordVisible: true`, preserves other flags |

### `register_bloc_test.dart`

| # | Test name | Expected outcome |
|---|-----------|-----------------|
| 1 | initial state | `RegisterInitial` |
| 2 | RegisterSubmitted → success | `[RegisterLoading, RegisterSuccess(user)]` |
| 3 | RegisterSubmitted → failure | `[RegisterLoading, RegisterFailure(msg)]` |
| 4 | calls use case with submitted params | `verify(useCase.call(...)).called(1)` |
| 5 | toggle password visibility | `isPasswordVisible: true` |
| 6 | toggle confirm password visibility | `isConfirmPasswordVisible: true` |

### `login_usecase_test.dart`

| # | Test name | Expected outcome |
|---|-----------|-----------------|
| 1 | returns Right(user) on success | `Right<Failure, User>(user)` |
| 2 | returns Left(failure) on failure | `Left<Failure, User>(InvalidCredentialsFailure())` |

### `register_usecase_test.dart`

| # | Test name | Expected outcome |
|---|-----------|-----------------|
| 1 | returns Right(user) when repository succeeds | `Right<Failure, User>(user)` |
| 2 | returns Left(failure) when repository fails | `Left<Failure, User>(ServerFailure())` |
| 3 | forwards all params to repository | `verify(repository.register(name:…,email:…,password:…)).called(1)` |

### `login_page_test.dart` (FAILING — updated 2026-06-13)

**Mock fix applied:** `MockLoginUseCase` was a bare `class MockLoginUseCase extends Mock implements LoginUseCase {}`. On 2026-06-13 this was upgraded to the proper `noSuchMethod` override pattern (adds `dartz`, `failures`, and `user` imports; overrides `call(LoginParams)` returning `Future<Either<Failure, User>>`).

The 3 tests still fail, but now for a **new reason** — a compile error introduced by the task #2 frontend-dev fix:

| # | Test name | Status | Root cause |
|---|-----------|--------|-----------|
| 1 | renders without crashing | ❌ | `lib/login_page.dart` compile error: `kIsTest` undefined in Flutter 3.41.1 |
| 2 | shows email and password fields | ❌ | same compile error (file won't load) |
| 3 | shows the submit button | ❌ | same compile error (file won't load) |

**Root cause detail:** `login_page.dart` uses `kIsTest` (lines 241, 251, 261, 273, 283, 294) as a guard around `.animate()` calls. `kIsTest` does **not exist** in Flutter 3.41.1's `flutter/foundation.dart`. The fix should replace `kIsTest` with `const bool.fromEnvironment('flutter.test')` or a project-level constant.

---

## Mock Strategy

All mocks use the **`noSuchMethod` override pattern** required for Dart 3.x + Mockito 5.x null safety:

```dart
class MockLoginUseCase extends Mock implements LoginUseCase {
  @override
  Future<Either<Failure, User>> call(LoginParams params) =>
      super.noSuchMethod(
        Invocation.method(#call, [params]),
        returnValue: Future.value(const Left<Failure, User>(InvalidCredentialsFailure())),
      ) as Future<Either<Failure, User>>;
}
```

`Future<Either<Failure, void>>` (forgot/reset password) requires a concrete `Left<Failure, void>` as the `returnValue` — `void` is not special-cased by Dart like the bare `Future<void>` type.

---

## Gaps and Recommendations

| Gap | Recommendation |
|-----|---------------|
| `LoginPage` widget tests fail — `kIsTest` undefined in Flutter 3.41.1 | Replace all `kIsTest` in `login_page.dart` with `const bool.fromEnvironment('flutter.test')` or a project-level `_kTest` constant |
| No widget tests for `RegisterPage`, `ForgotPasswordPage`, `ResetPasswordPage` | Add widget tests once the `login_page.dart` compile error is resolved |
| `AuthRepository` implementation (`AuthRepositoryImpl`) has no tests | Add data-layer unit tests for HTTP response mapping |
