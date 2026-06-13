import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:etsAndroid/features/auth/presentation/bloc/reset_password_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}

void main() {
  late MockResetPasswordUseCase useCase;

  const tParams = ResetPasswordParams(newPassword: 'newPass123');

  setUp(() {
    useCase = MockResetPasswordUseCase();
  });

  ResetPasswordBloc buildBloc() =>
      ResetPasswordBloc(resetPasswordUseCase: useCase);

  group('ResetPasswordBloc', () {
    test('initial state is ResetPasswordInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, const ResetPasswordInitial());
      bloc.close();
    });

    test(
        'emits [ResetPasswordLoading, ResetPasswordSuccess] when use case succeeds',
        () async {
      when(useCase.call(tParams))
          .thenAnswer((_) async => const Right(null));

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<ResetPasswordLoading>(),
          isA<ResetPasswordSuccess>(),
        ]),
      );

      bloc.add(const ResetPasswordSubmitted(newPassword: 'newPass123'));
      await expectation;
      bloc.close();
    });

    test(
        'emits [ResetPasswordLoading, ResetPasswordFailure] when use case fails',
        () async {
      when(useCase.call(tParams))
          .thenAnswer((_) async => const Left(ServerFailure()));

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<ResetPasswordLoading>(),
          isA<ResetPasswordFailure>().having(
            (s) => s.message,
            'message',
            'Error de servidor. Intenta de nuevo.',
          ),
        ]),
      );

      bloc.add(const ResetPasswordSubmitted(newPassword: 'newPass123'));
      await expectation;
      bloc.close();
    });

    test('toggles password visibility', () async {
      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emits(isA<ResetPasswordInitial>().having(
          (s) => s.isPasswordVisible,
          'isPasswordVisible',
          true,
        )),
      );

      bloc.add(const ResetPasswordVisibilityToggled());
      await expectation;
      bloc.close();
    });

    test('toggles confirm password visibility', () async {
      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emits(isA<ResetPasswordInitial>().having(
          (s) => s.isConfirmVisible,
          'isConfirmVisible',
          true,
        )),
      );

      bloc.add(const ResetPasswordConfirmVisibilityToggled());
      await expectation;
      bloc.close();
    });

    test('preserves visibility flags in loading state', () async {
      when(useCase.call(tParams))
          .thenAnswer((_) async => const Right(null));

      final bloc = buildBloc();
      // First toggle password visible
      bloc.add(const ResetPasswordVisibilityToggled());
      await bloc.stream.firstWhere((s) => s is ResetPasswordInitial);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<ResetPasswordLoading>().having(
              (s) => s.isPasswordVisible, 'isPasswordVisible', true),
          isA<ResetPasswordSuccess>(),
        ]),
      );

      bloc.add(const ResetPasswordSubmitted(newPassword: 'newPass123'));
      await expectation;
      bloc.close();
    });
  });
}
