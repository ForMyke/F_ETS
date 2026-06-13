import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/jefe_remote_datasource.dart';

part 'jefe_event.dart';
part 'jefe_state.dart';

class JefeBloc extends Bloc<JefeEvent, JefeState> {
  final JefeRemoteDataSource dataSource;

  JefeBloc({required this.dataSource}) : super(const JefeInitial()) {
    on<JefeLoginSubmitted>(_onLogin);
    on<JefeLogoutRequested>(_onLogout);
    on<JefeEtsLoaded>(_onEtsLoaded);
    on<JefeAlumnosLoaded>(_onAlumnosLoaded);
    on<JefeCalificacionGuardada>(_onCalificacionGuardada);
  }

  Future<void> _onLogin(
    JefeLoginSubmitted event,
    Emitter<JefeState> emit,
  ) async {
    emit(const JefeLoading());
    try {
      final perfil = await dataSource.login(
        correo: event.correo,
        password: event.password,
      );
      emit(JefeAuthenticated(perfil: perfil));
    } catch (e) {
      emit(JefeAuthFailure(
          message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogout(
    JefeLogoutRequested event,
    Emitter<JefeState> emit,
  ) async {
    await dataSource.logout();
    emit(const JefeInitial());
  }

  Future<void> _onEtsLoaded(
    JefeEtsLoaded event,
    Emitter<JefeState> emit,
  ) async {
    emit(JefeEtsLoading(perfil: event.perfil));
    try {
      final lista = await dataSource.getEtsDeJefe(event.perfil.idJefe);
      emit(JefeEtsSuccess(perfil: event.perfil, etsList: lista));
    } catch (e) {
      emit(JefeEtsFailure(
          perfil: event.perfil, message: 'Error al cargar exámenes.'));
    }
  }

  Future<void> _onAlumnosLoaded(
    JefeAlumnosLoaded event,
    Emitter<JefeState> emit,
  ) async {
    emit(JefeAlumnosLoading(perfil: event.perfil, idEts: event.idEts));
    try {
      final alumnos = await dataSource.getAlumnosInscritos(event.idEts);
      emit(JefeAlumnosSuccess(
        perfil: event.perfil,
        idEts: event.idEts,
        materiaEts: event.materiaEts,
        alumnos: alumnos,
      ));
    } catch (e) {
      emit(JefeAlumnosFailure(
        perfil: event.perfil,
        idEts: event.idEts,
        message: 'Error al cargar alumnos.',
      ));
    }
  }

  Future<void> _onCalificacionGuardada(
    JefeCalificacionGuardada event,
    Emitter<JefeState> emit,
  ) async {
    emit(JefeGuardandoCalificacion(
      perfil: event.perfil,
      idEts: event.idEts,
      materiaEts: event.materiaEts,
      alumnos: event.alumnosActuales,
    ));
    try {
      await dataSource.guardarCalificacion(
        idInscripcion: event.idInscripcion,
        calificacion: event.calificacion,
      );
      // Recargar lista de alumnos
      final alumnos = await dataSource.getAlumnosInscritos(event.idEts);
      emit(JefeAlumnosSuccess(
        perfil: event.perfil,
        idEts: event.idEts,
        materiaEts: event.materiaEts,
        alumnos: alumnos,
      ));
    } catch (e) {
      emit(JefeCalificacionFailure(
        perfil: event.perfil,
        idEts: event.idEts,
        materiaEts: event.materiaEts,
        alumnos: event.alumnosActuales,
        message: 'Error al guardar calificación.',
      ));
    }
  }
}
