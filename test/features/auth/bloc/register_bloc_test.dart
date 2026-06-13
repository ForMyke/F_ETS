import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/auth/domain/entities/user.dart';
import 'package:etsAndroid/features/auth/domain/usecases/register_usecase.dart';
import 'package:etsAndroid/features/auth/presentation/bloc/register_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  late MockRegisterUseCase useCase;

  const tUser = User(id: '1', email: 'new@ipn.mx', name: 'Pedro', token: 'tok');
  const tParams = RegisterParams(
    name: 'Pedro',
    email: 'new@ipn.mx',
    password: 'Pass1234',
  );

  setUp(() {
    useCase = MockRegisterUseCase();
  });

  RegisterBloc buildBloc() => RegisterBloc(registerUseCase: useCase);

  group('RegisterBloc', () {
    test('initial state is RegisterInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, const RegisterInitial());
      bloc.close();
    });

    test(
        'emits [RegisterLoading, RegisterSuccess] when use case returns Right(user)',
        () async {
      when(useCase.call(tParams))
          .thenAnswer((_) async => const Right(tUser));

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<RegisterLoading>(),
          isA<RegisterSuccess>().having((s) => s.user, 'user', tUser),
        ]),
      );

      bloc.add(const RegisterSubmitted(
        name: 'Pedro',
        email: 'new@ipn.mx',
        password: 'Pass1234',
      ));
      await expectation;
      bloc.close();
    });

    test(
        'emits [RegisterLoading, RegisterFailure] when use case returns Left(failure)',
        () async {
      when(useCase.call(tParams))
          .thenAnswer((_) async => const Left(ServerFailure()));

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<RegisterLoading>(),
          isA<RegisterFailure>().having(
            (s) => s.message,
            'message',
            'Error de servidor. Intenta de nuevo.',
          ),
        ]),
      );

      bloc.add(const RegisterSubmitted(
        name: 'Pedro',
        email: 'new@ipn.mx',
        password: 'Pass1234',
      ));
      await expectation;
      bloc.close();
    });

    test('calls use case with the submitted params', () async {
      when(useCase.call(tParams))
          .thenAnswer((_) async => const Right(tUser));

      final bloc = buildBloc();
      bloc.add(const RegisterSubmitted(
        name: 'Pedro',
        email: 'new@ipn.mx',
        password: 'Pass1234',
      ));
      await bloc.stream.firstWhere((s) => s is RegisterSuccess);

      verify(useCase.call(tParams)).called(1);
      bloc.close();
    });

    test('toggles password visibility', () async {
      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emits(isA<RegisterInitial>().having(
          (s) => s.isPasswordVisible,
          'isPasswordVisible',
          true,
        )),
      );

      bloc.add(const RegisterPasswordVisibilityToggled());
      await expectation;
      bloc.close();
    });

    test('toggles confirm password visibility', () async {
      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emits(isA<RegisterInitial>().having(
          (s) => s.isConfirmPasswordVisible,
          'isConfirmPasswordVisible',
          true,
        )),
      );

      bloc.add(const RegisterConfirmPasswordVisibilityToggled());
      await expectation;
      bloc.close();
    });
  });
}
