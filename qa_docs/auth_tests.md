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
| `presentation/login_page_test.dart` | Widget | ❌ 0/3 pass | Pre-existing, source issue |

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

### `login_page_test.dart` (FAILING — source issue)

| # | Test name | Status | Root cause |
|---|-----------|--------|-----------|
| 1 | renders email field | ❌ | `flutter_animate` pending Timer after widget disposal |
| 2 | renders password field | ❌ | same |
| 3 | submits on button press | ❌ | same |

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
| `LoginPage` widget tests fail due to `flutter_animate` timers | Guard animations with a test-mode flag or use `pumpAndSettle` + `fakeAsync` |
| No widget tests for `RegisterPage`, `ForgotPasswordPage`, `ResetPasswordPage` | Add widget tests once the `flutter_animate` source issue is resolved |
| `AuthRepository` implementation (`AuthRepositoryImpl`) has no tests | Add data-layer unit tests for HTTP response mapping |
