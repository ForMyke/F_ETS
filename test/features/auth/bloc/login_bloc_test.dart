import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/auth/domain/entities/user.dart';
import 'package:etsAndroid/features/auth/domain/usecases/login_usecase.dart';
import 'package:etsAndroid/features/auth/presentation/bloc/login_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late MockLoginUseCase useCase;

  const tUser = User(id: '1', email: 'a@b.com', name: 'Ana', token: 'tok');
  const tParams = LoginParams(email: 'a@b.com', password: '123456');

  setUp(() {
    useCase = MockLoginUseCase();
  });

  LoginBloc buildBloc() => LoginBloc(loginUseCase: useCase);

  group('LoginBloc', () {
    test('initial state is LoginInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, const LoginInitial());
      bloc.close();
    });

    test('emits [LoginLoading, LoginSuccess] when usecase returns Right(user)',
        () async {
      when(useCase.call(tParams))
          .thenAnswer((_) async => const Right(tUser));

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<LoginLoading>(),
          isA<LoginSuccess>()
              .having((s) => s.user, 'user', tUser),
        ]),
      );

      bloc.add(const LoginSubmitted(email: 'a@b.com', password: '123456'));
      await expectation;
      bloc.close();
    });

    test('emits [LoginLoading, LoginFailure] when usecase returns Left(failure)',
        () async {
      const badParams = LoginParams(email: 'a@b.com', password: 'bad');
      when(useCase.call(badParams)).thenAnswer(
          (_) async => const Left(InvalidCredentialsFailure()));

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<LoginLoading>(),
          isA<LoginFailure>().having(
              (s) => s.message, 'message', 'Correo o contraseña incorrectos.'),
        ]),
      );

      bloc.add(const LoginSubmitted(email: 'a@b.com', password: 'bad'));
      await expectation;
      bloc.close();
    });

    test('passes provided credentials to the usecase', () async {
      when(useCase.call(tParams))
          .thenAnswer((_) async => const Right(tUser));

      final bloc = buildBloc();
      bloc.add(const LoginSubmitted(email: 'a@b.com', password: '123456'));
      await bloc.stream.firstWhere((s) => s is LoginSuccess);

      verify(useCase.call(tParams)).called(1);
      bloc.close();
    });

    test('toggles password visibility', () async {
      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emits(isA<LoginInitial>().having(
            (s) => s.isPasswordVisible, 'isPasswordVisible', true)),
      );

      bloc.add(const LoginPasswordVisibilityToggled());
      await expectation;
      bloc.close();
    });
  });
}
