import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:etsAndroid/features/auth/presentation/bloc/forgot_password_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// ForgotPasswordUseCase.call() returns Future<Either<Failure, void>>.
// Mockito cannot auto-generate a default for this type without code generation,
// so we provide an explicit noSuchMethod override with a valid returnValue.
class MockForgotPasswordUseCase extends Mock implements ForgotPasswordUseCase {
  @override
  Future<Either<Failure, void>> call(ForgotPasswordParams params) =>
      super.noSuchMethod(
        Invocation.method(#call, [params]),
        returnValue: Future<Either<Failure, void>>.value(
          Left<Failure, void>(const ServerFailure()),
        ),
      ) as Future<Either<Failure, void>>;
}

void main() {
  late MockForgotPasswordUseCase useCase;

  const tParams = ForgotPasswordParams(email: 'user@ipn.mx');

  setUp(() {
    useCase = MockForgotPasswordUseCase();
  });

  ForgotPasswordBloc buildBloc() =>
      ForgotPasswordBloc(forgotPasswordUseCase: useCase);

  group('ForgotPasswordBloc', () {
    test('initial state is ForgotPasswordInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, const ForgotPasswordInitial());
      bloc.close();
    });

    test(
        'emits [ForgotPasswordLoading, ForgotPasswordSuccess] when use case succeeds',
        () async {
      when(useCase.call(tParams)).thenAnswer(
        (_) async => Right<Failure, void>(null),
      );

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<ForgotPasswordLoading>(),
          isA<ForgotPasswordSuccess>(),
        ]),
      );

      bloc.add(const ForgotPasswordSubmitted(email: 'user@ipn.mx'));
      await expectation;
      bloc.close();
    });

    test(
        'emits [ForgotPasswordLoading, ForgotPasswordFailure] when use case fails',
        () async {
      when(useCase.call(tParams)).thenAnswer(
        (_) async => Left<Failure, void>(const ServerFailure()),
      );

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<ForgotPasswordLoading>(),
          isA<ForgotPasswordFailure>().having(
            (s) => s.message,
            'message',
            'Error de servidor. Intenta de nuevo.',
          ),
        ]),
      );

      bloc.add(const ForgotPasswordSubmitted(email: 'user@ipn.mx'));
      await expectation;
      bloc.close();
    });

    test('calls use case with the submitted email', () async {
      when(useCase.call(tParams)).thenAnswer(
        (_) async => Right<Failure, void>(null),
      );

      final bloc = buildBloc();
      bloc.add(const ForgotPasswordSubmitted(email: 'user@ipn.mx'));
      await bloc.stream.firstWhere((s) => s is ForgotPasswordSuccess);

      verify(useCase.call(tParams)).called(1);
      bloc.close();
    });
  });
}
