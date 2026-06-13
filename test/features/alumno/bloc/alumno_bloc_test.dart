import 'package:etsAndroid/features/alumno/data/datasources/alumno_remote_datasource.dart';
import 'package:etsAndroid/features/alumno/presentation/bloc/alumno_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAlumnoRemoteDataSource extends Mock
    implements AlumnoRemoteDataSource {}

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
        correo: anyNamed('correo'),
        password: anyNamed('password'),
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
        correo: anyNamed('correo'),
        password: anyNamed('password'),
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
        idAlumno: anyNamed('idAlumno'),
        idEts: anyNamed('idEts'),
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
        idAlumno: anyNamed('idAlumno'),
        idEts: anyNamed('idEts'),
      ));
      bloc.close();
    });
  });
}
