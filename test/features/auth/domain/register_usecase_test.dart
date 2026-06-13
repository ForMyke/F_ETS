import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/auth/domain/entities/user.dart';
import 'package:etsAndroid/features/auth/domain/repositories/auth_repository.dart';
import 'package:etsAndroid/features/auth/domain/usecases/register_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// AuthRepository.register() has non-nullable String params; use
// noSuchMethod overrides to ensure correct default return values.
class MockAuthRepository extends Mock implements AuthRepository {
  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) =>
      super.noSuchMethod(
        Invocation.method(#login, [], {#email: email, #password: password}),
        returnValue: Future.value(
          const Left<Failure, User>(ServerFailure()),
        ),
      ) as Future<Either<Failure, User>>;

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  }) =>
      super.noSuchMethod(
        Invocation.method(#register, [], {
          #name: name,
          #email: email,
          #password: password,
        }),
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
  late RegisterUseCase useCase;

  const tUser =
      User(id: '2', email: 'reg@ipn.mx', name: 'Rosa', token: 'tok2');
  const tParams = RegisterParams(
    name: 'Rosa',
    email: 'reg@ipn.mx',
    password: 'Secure1!',
  );

  setUp(() {
    repository = MockAuthRepository();
    useCase = RegisterUseCase(repository);
  });

  group('RegisterUseCase', () {
    test('returns Right(user) when repository register succeeds', () async {
      when(repository.register(
        name: 'Rosa',
        email: 'reg@ipn.mx',
        password: 'Secure1!',
      )).thenAnswer((_) async => const Right(tUser));

      final result = await useCase(tParams);

      expect(result, const Right<Failure, User>(tUser));
      verify(repository.register(
        name: 'Rosa',
        email: 'reg@ipn.mx',
        password: 'Secure1!',
      )).called(1);
    });

    test('returns Left(ServerFailure) when repository register fails',
        () async {
      when(repository.register(
        name: 'Rosa',
        email: 'reg@ipn.mx',
        password: 'Secure1!',
      )).thenAnswer((_) async => const Left(ServerFailure()));

      final result = await useCase(tParams);

      expect(result, const Left<Failure, User>(ServerFailure()));
    });

    test('forwards all three params to repository', () async {
      when(repository.register(
        name: 'Rosa',
        email: 'reg@ipn.mx',
        password: 'Secure1!',
      )).thenAnswer((_) async => const Right(tUser));

      await useCase(tParams);

      verify(repository.register(
        name: 'Rosa',
        email: 'reg@ipn.mx',
        password: 'Secure1!',
      )).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}
