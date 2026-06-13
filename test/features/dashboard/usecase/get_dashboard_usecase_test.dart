import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:etsAndroid/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:etsAndroid/features/dashboard/domain/usecases/get_dashboard_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late MockDashboardRepository repository;
  late GetDashboardUseCase useCase;

  final tStats = DashboardStats(
    totalExams: 10,
    periodoNombre: 'ETS Enero 2026',
    examsByCarrera: {'ISC': 5, 'IIA': 3, 'LCD': 2},
    proximoExamen: DateTime(2026, 6, 12, 9),
    salonesEnUso: 4,
  );

  setUp(() {
    repository = MockDashboardRepository();
    useCase = GetDashboardUseCase(repository);
  });

  group('GetDashboardUseCase', () {
    test('returns Right(DashboardStats) when repository succeeds', () async {
      when(repository.getStats())
          .thenAnswer((_) async => Right(tStats));

      final result = await useCase(NoParams());

      expect(result, Right<Failure, DashboardStats>(tStats));
      verify(repository.getStats()).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('returns Left(ServerFailure) when repository fails', () async {
      when(repository.getStats())
          .thenAnswer((_) async => const Left(ServerFailure()));

      final result = await useCase(NoParams());

      expect(result, const Left<Failure, DashboardStats>(ServerFailure()));
      verify(repository.getStats()).called(1);
    });

    test('delegates entirely to repository.getStats(), not other methods',
        () async {
      when(repository.getStats())
          .thenAnswer((_) async => Right(tStats));

      await useCase(NoParams());

      verifyNoMoreInteractions(repository);
    });

    test('result contains expected totalExams', () async {
      when(repository.getStats())
          .thenAnswer((_) async => Right(tStats));

      final result = await useCase(NoParams());

      result.fold(
        (f) => fail('Expected Right but got Left'),
        (stats) => expect(stats.totalExams, 10),
      );
    });

    test('result contains expected periodoNombre', () async {
      when(repository.getStats())
          .thenAnswer((_) async => Right(tStats));

      final result = await useCase(NoParams());

      result.fold(
        (f) => fail('Expected Right but got Left'),
        (stats) => expect(stats.periodoNombre, 'ETS Enero 2026'),
      );
    });

    test('handles null proximoExamen gracefully', () async {
      final statsNoProximo = DashboardStats(
        totalExams: 0,
        periodoNombre: 'Vacio',
        examsByCarrera: const {},
        proximoExamen: null,
        salonesEnUso: 0,
      );
      when(repository.getStats())
          .thenAnswer((_) async => Right(statsNoProximo));

      final result = await useCase(NoParams());

      result.fold(
        (f) => fail('Expected Right but got Left'),
        (stats) => expect(stats.proximoExamen, isNull),
      );
    });
  });
}
