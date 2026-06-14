import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/auth/domain/entities/user.dart';
import 'package:etsAndroid/features/auth/domain/usecases/login_usecase.dart';
import 'package:etsAndroid/features/auth/presentation/bloc/login_bloc.dart';
import 'package:etsAndroid/features/auth/presentation/pages/login_page.dart';
import 'package:etsAndroid/features/auth/presentation/widgets/labeled_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Null-safe mock: override call() so Mockito has a valid non-null default
// return value instead of null for Future<Either<Failure, User>>.
class MockLoginUseCase extends Mock implements LoginUseCase {
  @override
  Future<Either<Failure, User>> call(LoginParams params) =>
      super.noSuchMethod(
        Invocation.method(#call, [params]),
        returnValue: Future.value(
          const Left<Failure, User>(InvalidCredentialsFailure()),
        ),
      ) as Future<Either<Failure, User>>;
}

void main() {
  late MockLoginUseCase useCase;

  setUp(() {
    useCase = MockLoginUseCase();
  });

  Widget harness() => MaterialApp(
        home: BlocProvider(
          create: (_) => LoginBloc(loginUseCase: useCase),
          child: const LoginPage(),
        ),
      );

  group('LoginPage', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(harness());
      await tester.pump();

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('shows email and password fields', (tester) async {
      await tester.pumpWidget(harness());
      await tester.pump();

      expect(find.byType(LabeledTextField), findsNWidgets(2));
      expect(find.text('Correo electrónico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
    });

    testWidgets('shows the submit button', (tester) async {
      await tester.pumpWidget(harness());
      await tester.pump();

      expect(find.text('Entrar'), findsOneWidget);
    });
  });
}
