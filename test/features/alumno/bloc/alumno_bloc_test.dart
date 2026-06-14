import 'package:etsAndroid/features/alumno/domain/entities/alumno_profile.dart';
import 'package:etsAndroid/features/alumno/domain/entities/inscripcion_item.dart';
import 'package:etsAndroid/features/alumno/data/datasources/alumno_remote_datasource.dart';
import 'package:etsAndroid/features/alumno/presentation/bloc/alumno_bloc.dart';
import 'package:etsAndroid/features/search/data/models/exam_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Null-safe mock: override every method that returns a non-nullable Future
// so Mockito has a valid default return value instead of null.
class MockAlumnoRemoteDataSource extends Mock
    implements AlumnoRemoteDataSource {
  static const _defaultProfile = AlumnoProfile(
    idAlumno: '',
    boleta: '',
    idCarrera: '',
    idPlan: '',
    nombre: '',
    apellidoPaterno: '',
    apellidoMaterno: '',
    correo: '',
  );

  @override
  Future<AlumnoProfile> login({
    required String correo,
    required String password,
  }) =>
      super.noSuchMethod(
        Invocation.method(#login, [], {#correo: correo, #password: password}),
        returnValue: Future.value(_defaultProfile),
      ) as Future<AlumnoProfile>;

  @override
  Future<void> logout() => super.noSuchMethod(
        Invocation.method(#logout, []),
        returnValue: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<AlumnoProfile?> getPerfilActual() =>
      super.noSuchMethod(
        Invocation.method(#getPerfilActual, []),
        returnValue: Future<AlumnoProfile?>.value(null),
      ) as Future<AlumnoProfile?>;

  @override
  Future<void> register({
    required String boleta,
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String correo,
    required String password,
    required String idCarrera,
    required String idPlan,
  }) =>
      super.noSuchMethod(
        Invocation.method(#register, [], {
          #boleta: boleta,
          #nombre: nombre,
          #apellidoPaterno: apellidoPaterno,
          #apellidoMaterno: apellidoMaterno,
          #correo: correo,
          #password: password,
          #idCarrera: idCarrera,
          #idPlan: idPlan,
        }),
        returnValue: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<List<ExamModel>> getExamsDisponibles({required String idCarrera}) =>
      super.noSuchMethod(
        Invocation.method(#getExamsDisponibles, [], {#idCarrera: idCarrera}),
        returnValue: Future.value(<ExamModel>[]),
      ) as Future<List<ExamModel>>;

  @override
  Future<bool> yaInscrito({
    required String idAlumno,
    required String idEts,
  }) =>
      super.noSuchMethod(
        Invocation.method(
            #yaInscrito, [], {#idAlumno: idAlumno, #idEts: idEts}),
        returnValue: Future.value(false),
      ) as Future<bool>;

  @override
  Future<void> inscribirse({
    required String idAlumno,
    required String idEts,
  }) =>
      super.noSuchMethod(
        Invocation.method(
            #inscribirse, [], {#idAlumno: idAlumno, #idEts: idEts}),
        returnValue: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<List<InscripcionItem>> getMisInscripciones(String idAlumno) =>
      super.noSuchMethod(
        Invocation.method(#getMisInscripciones, [idAlumno]),
        returnValue: Future.value(<InscripcionItem>[]),
      ) as Future<List<InscripcionItem>>;

  @override
  Future<List<Map<String, dynamic>>> getCarreras() =>
      super.noSuchMethod(
        Invocation.method(#getCarreras, []),
        returnValue: Future.value(<Map<String, dynamic>>[]),
      ) as Future<List<Map<String, dynamic>>>;

  @override
  Future<List<Map<String, dynamic>>> getPlanes() =>
      super.noSuchMethod(
        Invocation.method(#getPlanes, []),
        returnValue: Future.value(<Map<String, dynamic>>[]),
      ) as Future<List<Map<String, dynamic>>>;
}

void main() {
  late MockAlumnoRemoteDataSource dataSource;

  const tProfile = AlumnoProfile(
    idAlumno: 'al-1',
    boleta: '2020630000',
    idCarrera: 'ISC',
    idPlan: '2020',
    nombre: 'Ana',
    apellidoPaterno: 'López',
    apellidoMaterno: 'Pérez',
    correo: 'ana@ipn.mx',
  );

  setUp(() {
    dataSource = MockAlumnoRemoteDataSource();
  });

  AlumnoBloc buildBloc() => AlumnoBloc(dataSource: dataSource);

  group('AlumnoBloc', () {
    test('initial state is AlumnoInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, const AlumnoInitial());
      bloc.close();
    });

    test('emits [AlumnoLoading, AlumnoAuthenticated] on successful login',
        () async {
      when(dataSource.login(
        correo: 'ana@ipn.mx',
        password: '123456',
      )).thenAnswer((_) async => tProfile);

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<AlumnoLoading>(),
          isA<AlumnoAuthenticated>()
              .having((s) => s.perfil.idAlumno, 'idAlumno', 'al-1'),
        ]),
      );

      bloc.add(const AlumnoLoginSubmitted(
          correo: 'ana@ipn.mx', password: '123456'));
      await expectation;
      bloc.close();
    });

    test('emits [AlumnoLoading, AlumnoAuthFailure] when login throws',
        () async {
      when(dataSource.login(
        correo: 'ana@ipn.mx',
        password: 'bad',
      )).thenThrow(Exception('Credenciales incorrectas.'));

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<AlumnoLoading>(),
          isA<AlumnoAuthFailure>().having(
              (s) => s.message, 'message', 'Credenciales incorrectas.'),
        ]),
      );

      bloc.add(const AlumnoLoginSubmitted(
          correo: 'ana@ipn.mx', password: 'bad'));
      await expectation;
      bloc.close();
    });

    test(
        'emits AlumnoInscripcionFailure when student is already enrolled',
        () async {
      when(dataSource.yaInscrito(
        idAlumno: 'al-1',
        idEts: 'ets-1',
      )).thenAnswer((_) async => true);

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<AlumnoInscribiendose>(),
          isA<AlumnoInscripcionFailure>().having(
              (s) => s.message, 'message', 'Ya estás inscrito a este examen.'),
        ]),
      );

      bloc.add(const AlumnoInscribirseRequested(
          perfil: tProfile, idEts: 'ets-1'));
      await expectation;

      verifyNever(dataSource.inscribirse(
        idAlumno: 'al-1',
        idEts: 'ets-1',
      ));
      bloc.close();
    });
  });
}
