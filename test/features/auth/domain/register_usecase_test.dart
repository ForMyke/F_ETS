import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/auth/domain/entities/user.dart';
import 'package:etsAndroid/features/auth/domain/repositories/auth_repository.dart';
import 'package:etsAndroid/features/auth/domain/usecases/register_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late RegisterUseCase useCase;

  const tUser = User(id: '2', email: 'reg@ipn.mx', name: 'Rosa', token: 'tok2');
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
        name: anyNamed('name'),
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Right(tUser));

      final result = await useCase(tParams);

      expect(result, const Right<Failure, User>(tUser));
      verify(repository.register(
        name: 'Rosa',
        email: 'reg@ipn.mx',
        password: 'Secure1!',
      )).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('returns Left(ServerFailure) when repository register fails',
        () async {
      when(repository.register(
        name: anyNamed('name'),
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Left(ServerFailure()));

      final result = await useCase(tParams);

      expect(result, const Left<Failure, User>(ServerFailure()));
    });

    test('forwards all three params to repository', () async {
      when(repository.register(
        name: anyNamed('name'),
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Right(tUser));

      await useCase(tParams);

      verify(repository.register(
        name: 'Rosa',
        email: 'reg@ipn.mx',
        password: 'Secure1!',
      )).called(1);
    });
  });
}
