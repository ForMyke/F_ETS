import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/search/domain/entities/exam.dart';
import 'package:etsAndroid/features/search/domain/repositories/search_repository.dart';
import 'package:etsAndroid/features/search/domain/usecases/get_exams_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

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
        carrera: anyNamed('carrera'),
        semestre: anyNamed('semestre'),
        plan: anyNamed('plan'),
        materia: anyNamed('materia'),
      )).thenAnswer((_) async => Right([tExam]));

      final result = await useCase(tParams);

      expect(result, Right<Failure, List<Exam>>([tExam]));
      verify(repository.getExams(
        carrera: 'ISC',
        semestre: 1,
        plan: null,
        materia: null,
      )).called(1);
    });

    test('returns Left(failure) when repository fails', () async {
      when(repository.getExams(
        carrera: anyNamed('carrera'),
        semestre: anyNamed('semestre'),
        plan: anyNamed('plan'),
        materia: anyNamed('materia'),
      )).thenAnswer((_) async => const Left(ServerFailure()));

      final result = await useCase(tParams);

      expect(result, const Left<Failure, List<Exam>>(ServerFailure()));
    });
  });
}
