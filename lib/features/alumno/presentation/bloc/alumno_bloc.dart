import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:etsAndroid/features/search/data/models/exam_model.dart';
import 'package:etsAndroid/features/alumno/data/datasources/alumno_remote_datasource.dart';

part 'alumno_event.dart';
part 'alumno_state.dart';

class AlumnoBloc extends Bloc<AlumnoEvent, AlumnoState> {
  final AlumnoRemoteDataSource dataSource;

  AlumnoBloc({required this.dataSource}) : super(const AlumnoInitial()) {
    on<AlumnoLoginSubmitted>(_onLogin);
    on<AlumnoRegisterSubmitted>(_onRegister);
    on<AlumnoLogoutRequested>(_onLogout);
    on<AlumnoExamsLoaded>(_onExamsLoaded);
    on<AlumnoInscripcionesLoaded>(_onInscripcionesLoaded);
    on<AlumnoInscribirseRequested>(_onInscribirse);
  }

  Future<void> _onLogin(
    AlumnoLoginSubmitted event,
    Emitter<AlumnoState> emit,
  ) async {
    emit(const AlumnoLoading());
    try {
      final perfil = await dataSource.login(
        correo: event.correo,
        password: event.password,
      );
      emit(AlumnoAuthenticated(perfil: perfil));
    } catch (e) {
      emit(AlumnoAuthFailure(
          message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegister(
    AlumnoRegisterSubmitted event,
    Emitter<AlumnoState> emit,
  ) async {
    emit(const AlumnoLoading());
    try {
      await dataSource.register(
        boleta: event.boleta,
        nombre: event.nombre,
        apellidoPaterno: event.apellidoPaterno,
        apellidoMaterno: event.apellidoMaterno,
        correo: event.correo,
        password: event.password,
        idCarrera: event.idCarrera,
        idPlan: event.idPlan,
      );
      emit(const AlumnoRegisterSuccess());
    } catch (e) {
      emit(AlumnoAuthFailure(
          message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogout(
    AlumnoLogoutRequested event,
    Emitter<AlumnoState> emit,
  ) async {
    await dataSource.logout();
    emit(const AlumnoInitial());
  }

  Future<void> _onExamsLoaded(
    AlumnoExamsLoaded event,
    Emitter<AlumnoState> emit,
  ) async {
    emit(AlumnoExamsLoading(perfil: event.perfil));
    try {
      final exams = await dataSource.getExamsDisponibles(
        idCarrera: event.perfil.idCarrera,
      );
      emit(AlumnoExamsSuccess(perfil: event.perfil, exams: exams));
    } catch (e) {
      emit(AlumnoExamsFailure(
        perfil: event.perfil,
        message: 'Error al cargar exámenes.',
      ));
    }
  }

  Future<void> _onInscripcionesLoaded(
    AlumnoInscripcionesLoaded event,
    Emitter<AlumnoState> emit,
  ) async {
    emit(AlumnoInscripcionesLoading(perfil: event.perfil));
    try {
      final inscripciones =
          await dataSource.getMisInscripciones(event.perfil.idAlumno);
      emit(AlumnoInscripcionesSuccess(
        perfil: event.perfil,
        inscripciones: inscripciones,
      ));
    } catch (e) {
      emit(AlumnoInscripcionesFailure(
        perfil: event.perfil,
        message: 'Error al cargar inscripciones.',
      ));
    }
  }

  Future<void> _onInscribirse(
    AlumnoInscribirseRequested event,
    Emitter<AlumnoState> emit,
  ) async {
    emit(AlumnoInscribiendose(perfil: event.perfil));
    try {
      final yaInscrito = await dataSource.yaInscrito(
        idAlumno: event.perfil.idAlumno,
        idEts: event.idEts,
      );
      if (yaInscrito) {
        emit(AlumnoInscripcionFailure(
          perfil: event.perfil,
          message: 'Ya estás inscrito a este examen.',
        ));
        return;
      }
      await dataSource.inscribirse(
        idAlumno: event.perfil.idAlumno,
        idEts: event.idEts,
      );
      emit(AlumnoInscripcionSuccess(perfil: event.perfil));
    } catch (e) {
      emit(AlumnoInscripcionFailure(
        perfil: event.perfil,
        message: 'Error al inscribirse. Intenta de nuevo.',
      ));
    }
  }
}
