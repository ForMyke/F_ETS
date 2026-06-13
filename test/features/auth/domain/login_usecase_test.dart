import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/auth/domain/entities/user.dart';
import 'package:etsAndroid/features/auth/domain/repositories/auth_repository.dart';
import 'package:etsAndroid/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Null-safe mock: override login() so Mockito has a valid non-null default.
class MockAuthRepository extends Mock implements AuthRepository {
  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) =>
      super.noSuchMethod(
        Invocation.method(#login, [], {#email: email, #password: password}),
        returnValue: Future.value(
          const Left<Failure, User>(InvalidCredentialsFailure()),
        ),
      ) as Future<Either<Failure, User>>;

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  }) =>
      super.noSuchMethod(
        Invocation.method(
            #register, [], {#name: name, #email: email, #password: password}),
        returnValue: Future.value(
          const Left<Failure, User>(ServerFailure()),
        ),
      ) as Future<Either<Failure, User>>;

  @override
  Future<Either<Failure, void>> logout() =>
      super.noSuchMethod(
        Invocation.method(#logout, []),
        returnValue: Future<Either<Failure, void>>.value(
          Left<Failure, void>(const ServerFailure()),
        ),
      ) as Future<Either<Failure, void>>;

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) =>
      super.noSuchMethod(
        Invocation.method(#forgotPassword, [], {#email: email}),
        returnValue: Future<Either<Failure, void>>.value(
          Left<Failure, void>(const ServerFailure()),
        ),
      ) as Future<Either<Failure, void>>;

  @override
  Future<Either<Failure, void>> resetPassword({required String newPassword}) =>
      super.noSuchMethod(
        Invocation.method(#resetPassword, [], {#newPassword: newPassword}),
        returnValue: Future<Either<Failure, void>>.value(
          Left<Failure, void>(const ServerFailure()),
        ),
      ) as Future<Either<Failure, void>>;
}

void main() {
  late MockAuthRepository repository;
  late LoginUseCase useCase;

  const tUser = User(id: '1', email: 'a@b.com', name: 'Ana', token: 'tok');
  const tParams = LoginParams(email: 'a@b.com', password: '123456');

  setUp(() {
    repository = MockAuthRepository();
    useCase = LoginUseCase(repository);
  });

  group('LoginUseCase', () {
    test('returns Right(user) when repository login succeeds', () async {
      when(repository.login(
        email: 'a@b.com',
        password: '123456',
      )).thenAnswer((_) async => const Right(tUser));

      final result = await useCase(tParams);

      expect(result, const Right<Failure, User>(tUser));
      verify(repository.login(email: 'a@b.com', password: '123456')).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('returns Left(failure) when repository login fails', () async {
      when(repository.login(
        email: 'a@b.com',
        password: '123456',
      )).thenAnswer((_) async => const Left(InvalidCredentialsFailure()));

      final result = await useCase(tParams);

      expect(result, const Left<Failure, User>(InvalidCredentialsFailure()));
      verify(repository.login(email: 'a@b.com', password: '123456')).called(1);
    });
  });
}
