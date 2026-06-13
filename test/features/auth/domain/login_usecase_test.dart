import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/auth/domain/entities/user.dart';
import 'package:etsAndroid/features/auth/domain/repositories/auth_repository.dart';
import 'package:etsAndroid/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

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
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Right(tUser));

      final result = await useCase(tParams);

      expect(result, const Right<Failure, User>(tUser));
      verify(repository.login(email: 'a@b.com', password: '123456')).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('returns Left(failure) when repository login fails', () async {
      when(repository.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Left(InvalidCredentialsFailure()));

      final result = await useCase(tParams);

      expect(result, const Left<Failure, User>(InvalidCredentialsFailure()));
      verify(repository.login(email: 'a@b.com', password: '123456')).called(1);
    });
  });
}
