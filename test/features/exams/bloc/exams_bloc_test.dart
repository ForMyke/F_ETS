import 'package:etsAndroid/features/exams/data/datasources/exams_remote_datasource.dart';
import 'package:etsAndroid/features/exams/domain/entities/exam_admin.dart';
import 'package:etsAndroid/features/exams/presentation/bloc/exams_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Null-safe mock: override every method that returns a non-nullable Future.
class MockExamsRemoteDataSource extends Mock implements ExamsRemoteDataSource {
  @override
  Future<List<ExamListItem>> getExams() =>
      super.noSuchMethod(
        Invocation.method(#getExams, []),
        returnValue: Future.value(<ExamListItem>[]),
      ) as Future<List<ExamListItem>>;

  @override
  Future<ExamFormData> getFormData(
    String? carreraId,
    String? planId,
    String? semestre,
  ) =>
      super.noSuchMethod(
        Invocation.method(#getFormData, [carreraId, planId, semestre]),
        returnValue: Future.value(const ExamFormData(
          carreras: [],
          planes: [],
          materias: [],
          salones: [],
          periodos: [],
          jefes: [],
        )),
      ) as Future<ExamFormData>;

  @override
  Future<void> createExam({
    required String carreraeMateriaId,
    required String salonId,
    required String periodoId,
    required String jefeId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) =>
      super.noSuchMethod(
        Invocation.method(#createExam, [], {
          #carreraeMateriaId: carreraeMateriaId,
          #salonId: salonId,
          #periodoId: periodoId,
          #jefeId: jefeId,
          #fechaInicio: fechaInicio,
          #fechaFin: fechaFin,
        }),
        returnValue: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<void> updateExam({
    required String id,
    required String carreraMateriaId,
    required String salonId,
    required String periodoId,
    required String jefeId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) =>
      super.noSuchMethod(
        Invocation.method(#updateExam, [], {
          #id: id,
          #carreraMateriaId: carreraMateriaId,
          #salonId: salonId,
          #periodoId: periodoId,
          #jefeId: jefeId,
          #fechaInicio: fechaInicio,
          #fechaFin: fechaFin,
        }),
        returnValue: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<void> deleteExam(String id) =>
      super.noSuchMethod(
        Invocation.method(#deleteExam, [id]),
        returnValue: Future<void>.value(),
      ) as Future<void>;
}

ExamListItem _examItem(String id) => ExamListItem(
      id: id,
      materia: 'Cálculo',
      carrera: 'ISC',
      salon: 'A1',
      salonId: 's-1',
      edificio: '1',
      turno: 'Matutino',
      fechaInicio: DateTime(2026, 6, 12, 9),
      fechaFin: DateTime(2026, 6, 12, 11),
      estado: 'activo',
      periodo: 'P1',
      profesor: 'Dr. X',
      jefeId: 'j-1',
      carreraMateriaId: 'cm-1',
      carreraId: 'c-1',
      planId: 'p-1',
      semestre: 1,
    );

void main() {
  late MockExamsRemoteDataSource dataSource;

  setUp(() {
    dataSource = MockExamsRemoteDataSource();
  });

  ExamsBloc buildBloc() => ExamsBloc(dataSource: dataSource);

  group('ExamsBloc', () {
    test('initial state is ExamsInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, const ExamsInitial());
      bloc.close();
    });

    test('emits [ExamsLoading, ExamsSuccess] on ExamsStarted', () async {
      when(dataSource.getExams())
          .thenAnswer((_) async => [_examItem('1'), _examItem('2')]);

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<ExamsLoading>(),
          isA<ExamsSuccess>().having((s) => s.exams.length, 'count', 2),
        ]),
      );

      bloc.add(const ExamsStarted());
      await expectation;
      bloc.close();
    });

    test('emits [ExamsLoading, ExamsFailure] when getExams throws', () async {
      when(dataSource.getExams()).thenThrow(Exception('boom'));

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<ExamsLoading>(),
          isA<ExamsFailure>().having(
              (s) => s.message, 'message', 'Error al cargar exámenes.'),
        ]),
      );

      bloc.add(const ExamsStarted());
      await expectation;
      bloc.close();
    });

    test('reloads exams after a successful delete', () async {
      when(dataSource.deleteExam('2')).thenAnswer((_) async {});
      when(dataSource.getExams())
          .thenAnswer((_) async => [_examItem('1')]);

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emits(isA<ExamsSuccess>().having((s) => s.exams.length, 'count', 1)),
      );

      bloc.add(const ExamDeleted(id: '2'));
      await expectation;

      verify(dataSource.deleteExam('2')).called(1);
      bloc.close();
    });

    test('emits ExamsFailure when delete throws', () async {
      when(dataSource.deleteExam('2')).thenThrow(Exception('boom'));

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emits(isA<ExamsFailure>().having(
            (s) => s.message, 'message', 'Error al eliminar el examen.')),
      );

      bloc.add(const ExamDeleted(id: '2'));
      await expectation;
      bloc.close();
    });
  });
}
