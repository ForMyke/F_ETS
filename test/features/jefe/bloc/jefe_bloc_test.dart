import 'package:etsAndroid/features/jefe/data/datasources/jefe_remote_datasource.dart';
import 'package:etsAndroid/features/jefe/presentation/bloc/jefe_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Null-safe mock: provide noSuchMethod overrides for every return type so
// Mockito can return a valid default instead of `null` for non-nullable types.
class MockJefeRemoteDataSource extends Mock implements JefeRemoteDataSource {
  static const _defaultPerfil = JefeProfile(
    idJefe: '',
    nombre: '',
    apellidoPaterno: '',
    apellidoMaterno: '',
    correo: '',
  );

  @override
  Future<JefeProfile> login({
    required String correo,
    required String password,
  }) =>
      super.noSuchMethod(
        Invocation.method(#login, [], {#correo: correo, #password: password}),
        returnValue: Future.value(_defaultPerfil),
      ) as Future<JefeProfile>;

  @override
  Future<void> logout() => super.noSuchMethod(
        Invocation.method(#logout, []),
        returnValue: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<List<EtsDeJefeItem>> getEtsDeJefe(String idJefe) =>
      super.noSuchMethod(
        Invocation.method(#getEtsDeJefe, [idJefe]),
        returnValue: Future.value(<EtsDeJefeItem>[]),
      ) as Future<List<EtsDeJefeItem>>;

  @override
  Future<List<AlumnoInscritoItem>> getAlumnosInscritos(String idEts) =>
      super.noSuchMethod(
        Invocation.method(#getAlumnosInscritos, [idEts]),
        returnValue: Future.value(<AlumnoInscritoItem>[]),
      ) as Future<List<AlumnoInscritoItem>>;

  @override
  Future<void> guardarCalificacion({
    required String idInscripcion,
    required double calificacion,
  }) =>
      super.noSuchMethod(
        Invocation.method(#guardarCalificacion, [], {
          #idInscripcion: idInscripcion,
          #calificacion: calificacion,
        }),
        returnValue: Future<void>.value(),
      ) as Future<void>;
}

// ── Test fixtures ─────────────────────────────────────────────────────────────

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
      when(dataSource.login(correo: 'laura@ipn.mx', password: '123456'))
          .thenAnswer((_) async => tPerfil);

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
      when(dataSource.login(correo: 'x@x.com', password: 'bad'))
          .thenThrow(Exception('Credenciales incorrectas.'));

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
        idInscripcion: 'ins-1',
        calificacion: 8.5,
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
        idInscripcion: 'ins-1',
        calificacion: 5.0,
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
