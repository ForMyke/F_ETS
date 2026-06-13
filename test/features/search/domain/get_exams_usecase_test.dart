import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/search/domain/entities/exam.dart';
import 'package:etsAndroid/features/search/domain/repositories/search_repository.dart';
import 'package:etsAndroid/features/search/domain/usecases/get_exams_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Null-safe mock: override getExams() with a valid non-null default.
class MockSearchRepository extends Mock implements SearchRepository {
  @override
  Future<Either<Failure, List<Exam>>> getExams({
    String? carrera,
    int? semestre,
    String? plan,
    String? materia,
  }) =>
      super.noSuchMethod(
        Invocation.method(#getExams, [], {
          #carrera: carrera,
          #semestre: semestre,
          #plan: plan,
          #materia: materia,
        }),
        returnValue: Future.value(
          const Left<Failure, List<Exam>>(ServerFailure()),
        ),
      ) as Future<Either<Failure, List<Exam>>>;

  @override
  Future<Either<Failure, List<String>>> getCarreras() =>
      super.noSuchMethod(
        Invocation.method(#getCarreras, []),
        returnValue: Future.value(
          const Left<Failure, List<String>>(ServerFailure()),
        ),
      ) as Future<Either<Failure, List<String>>>;
}

void main() {
  late MockSearchRepository repository;
  late GetExamsUseCase useCase;

  final tExam = Exam(
    id: '1',
    materia: 'Cálculo',
    carrera: 'ISC',
    semestre: 1,
    plan: '2020',
    fechaInicio: DateTime(2026, 6, 12, 9),
    fechaFin: DateTime(2026, 6, 12, 11),
    turno: 'Matutino',
    hora: '09:00',
    salon: 'A1',
    edificio: '1',
    piso: '1',
    profesor: 'Dr. X',
    periodoETS: 'P1',
    estado: 'activo',
  );

  const tParams = GetExamsParams(carrera: 'ISC', semestre: 1);

  setUp(() {
    repository = MockSearchRepository();
    useCase = GetExamsUseCase(repository);
  });

  group('GetExamsUseCase', () {
    test('returns Right(list) when repository succeeds', () async {
      when(repository.getExams(
        carrera: 'ISC',
        semestre: 1,
        plan: null,
        materia: null,
      )).thenAnswer((_) async => Right([tExam]));

      final result = await useCase(tParams);

      // Use fold to avoid List identity inequality in dartz's Right.==
      expect(result.isRight(), isTrue);
      result.fold(
        (f) => fail('Expected Right but got Left: $f'),
        (list) {
          expect(list.length, 1);
          expect(list.first, tExam);
        },
      );
      verify(repository.getExams(
        carrera: 'ISC',
        semestre: 1,
        plan: null,
        materia: null,
      )).called(1);
    });

    test('returns Left(failure) when repository fails', () async {
      when(repository.getExams(
        carrera: 'ISC',
        semestre: 1,
        plan: null,
        materia: null,
      )).thenAnswer((_) async => const Left(ServerFailure()));

      final result = await useCase(tParams);

      expect(result, const Left<Failure, List<Exam>>(ServerFailure()));
    });
  });
}
