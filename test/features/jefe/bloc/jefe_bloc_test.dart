import 'package:etsAndroid/features/jefe/data/datasources/jefe_remote_datasource.dart';
import 'package:etsAndroid/features/jefe/presentation/bloc/jefe_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockJefeRemoteDataSource extends Mock implements JefeRemoteDataSource {}

const tPerfil = JefeProfile(
  idJefe: 'j-1',
  nombre: 'Laura',
  apellidoPaterno: 'Martínez',
  apellidoMaterno: 'Ruiz',
  correo: 'laura@ipn.mx',
);

final tEtsItem = EtsDeJefeItem(
  idEts: 'ets-1',
  materia: 'Cálculo',
  carrera: 'ISC',
  salon: 'A1',
  edificio: '1',
  fechaInicio: DateTime(2026, 6, 12, 9),
  hora: '09:00',
  turno: 'Matutino',
  estado: 'activo',
);

const tAlumno = AlumnoInscritoItem(
  idInscripcion: 'ins-1',
  boleta: '2020630001',
  nombreAlumno: 'Pedro García López',
  calificacion: null,
  resultado: null,
  estado: 'inscrito',
);

void main() {
  late MockJefeRemoteDataSource dataSource;

  setUp(() {
    dataSource = MockJefeRemoteDataSource();
  });

  JefeBloc buildBloc() => JefeBloc(dataSource: dataSource);

  group('JefeBloc', () {
    // ── Authentication ────────────────────────────────────────────────────────

    test('initial state is JefeInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, const JefeInitial());
      bloc.close();
    });

    test('emits [JefeLoading, JefeAuthenticated] on successful login',
        () async {
      when(dataSource.login(
        correo: anyNamed('correo'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => tPerfil);

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<JefeLoading>(),
          isA<JefeAuthenticated>()
              .having((s) => s.perfil.idJefe, 'idJefe', 'j-1'),
        ]),
      );

      bloc.add(const JefeLoginSubmitted(
          correo: 'laura@ipn.mx', password: '123456'));
      await expectation;
      bloc.close();
    });

    test('emits [JefeLoading, JefeAuthFailure] when login throws', () async {
      when(dataSource.login(
        correo: anyNamed('correo'),
        password: anyNamed('password'),
      )).thenThrow(Exception('Credenciales incorrectas.'));

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<JefeLoading>(),
          isA<JefeAuthFailure>().having(
            (s) => s.message,
            'message',
            'Credenciales incorrectas.',
          ),
        ]),
      );

      bloc.add(const JefeLoginSubmitted(correo: 'x@x.com', password: 'bad'));
      await expectation;
      bloc.close();
    });

    test('emits JefeInitial after logout', () async {
      when(dataSource.logout()).thenAnswer((_) async {});

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emits(isA<JefeInitial>()),
      );

      bloc.add(const JefeLogoutRequested());
      await expectation;

      verify(dataSource.logout()).called(1);
      bloc.close();
    });

    // ── ETS loading ───────────────────────────────────────────────────────────

    test(
        'emits [JefeEtsLoading, JefeEtsSuccess] when getEtsDeJefe succeeds',
        () async {
      when(dataSource.getEtsDeJefe('j-1'))
          .thenAnswer((_) async => [tEtsItem]);

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<JefeEtsLoading>(),
          isA<JefeEtsSuccess>()
              .having((s) => s.etsList.length, 'etsList.length', 1),
        ]),
      );

      bloc.add(const JefeEtsLoaded(perfil: tPerfil));
      await expectation;
      bloc.close();
    });

    test(
        'emits [JefeEtsLoading, JefeEtsFailure] when getEtsDeJefe throws',
        () async {
      when(dataSource.getEtsDeJefe('j-1')).thenThrow(Exception('boom'));

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<JefeEtsLoading>(),
          isA<JefeEtsFailure>().having(
            (s) => s.message,
            'message',
            'Error al cargar exámenes.',
          ),
        ]),
      );

      bloc.add(const JefeEtsLoaded(perfil: tPerfil));
      await expectation;
      bloc.close();
    });

    // ── Alumnos loading ───────────────────────────────────────────────────────

    test(
        'emits [JefeAlumnosLoading, JefeAlumnosSuccess] when getAlumnosInscritos succeeds',
        () async {
      when(dataSource.getAlumnosInscritos('ets-1'))
          .thenAnswer((_) async => [tAlumno]);

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<JefeAlumnosLoading>(),
          isA<JefeAlumnosSuccess>()
              .having((s) => s.alumnos.length, 'alumnos.length', 1),
        ]),
      );

      bloc.add(const JefeAlumnosLoaded(
        perfil: tPerfil,
        idEts: 'ets-1',
        materiaEts: 'Cálculo',
      ));
      await expectation;
      bloc.close();
    });

    test(
        'emits [JefeAlumnosLoading, JefeAlumnosFailure] when getAlumnosInscritos throws',
        () async {
      when(dataSource.getAlumnosInscritos('ets-1'))
          .thenThrow(Exception('network error'));

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<JefeAlumnosLoading>(),
          isA<JefeAlumnosFailure>().having(
            (s) => s.message,
            'message',
            'Error al cargar alumnos.',
          ),
        ]),
      );

      bloc.add(const JefeAlumnosLoaded(
        perfil: tPerfil,
        idEts: 'ets-1',
        materiaEts: 'Cálculo',
      ));
      await expectation;
      bloc.close();
    });

    // ── Calificación ──────────────────────────────────────────────────────────

    test(
        'emits [JefeGuardandoCalificacion, JefeAlumnosSuccess] after saving grade',
        () async {
      when(dataSource.guardarCalificacion(
        idInscripcion: anyNamed('idInscripcion'),
        calificacion: anyNamed('calificacion'),
      )).thenAnswer((_) async {});
      when(dataSource.getAlumnosInscritos('ets-1'))
          .thenAnswer((_) async => [tAlumno]);

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<JefeGuardandoCalificacion>(),
          isA<JefeAlumnosSuccess>(),
        ]),
      );

      bloc.add(const JefeCalificacionGuardada(
        perfil: tPerfil,
        idEts: 'ets-1',
        materiaEts: 'Cálculo',
        idInscripcion: 'ins-1',
        calificacion: 8.5,
        alumnosActuales: [tAlumno],
      ));
      await expectation;
      bloc.close();
    });

    test(
        'emits [JefeGuardandoCalificacion, JefeCalificacionFailure] when guardarCalificacion throws',
        () async {
      when(dataSource.guardarCalificacion(
        idInscripcion: anyNamed('idInscripcion'),
        calificacion: anyNamed('calificacion'),
      )).thenThrow(Exception('db error'));

      final bloc = buildBloc();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Matcher>[
          isA<JefeGuardandoCalificacion>(),
          isA<JefeCalificacionFailure>().having(
            (s) => s.message,
            'message',
            'Error al guardar calificación.',
          ),
        ]),
      );

      bloc.add(const JefeCalificacionGuardada(
        perfil: tPerfil,
        idEts: 'ets-1',
        materiaEts: 'Cálculo',
        idInscripcion: 'ins-1',
        calificacion: 5.0,
        alumnosActuales: [tAlumno],
      ));
      await expectation;
      bloc.close();
    });
  });
}
