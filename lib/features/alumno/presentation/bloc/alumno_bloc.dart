import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:etsAndroid/features/search/data/models/exam_model.dart';
import 'package:etsAndroid/features/alumno/domain/entities/alumno_profile.dart';
import 'package:etsAndroid/features/alumno/domain/entities/inscripcion_item.dart';
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
    on<AlumnoSolicitarBajaRequested>(_onSolicitarBaja);
    on<AlumnoSolicitarRevisionRequested>(_onSolicitarRevision);
    on<AlumnoSolicitarEtsEspecialRequested>(_onSolicitarEtsEspecial);
    on<AlumnoSolicitarBajaEtsEspecialRequested>(_onSolicitarBajaEtsEspecial);
    on<AlumnoSolicitarRevisionEtsEspecialRequested>(
        _onSolicitarRevisionEtsEspecial);
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
      // ignore: avoid_print
      print('DEBUG getExamsDisponibles error: $e');
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
        add(AlumnoExamsLoaded(perfil: event.perfil));
        return;
      }
      await dataSource.inscribirse(
        idAlumno: event.perfil.idAlumno,
        idEts: event.idEts,
      );
      emit(AlumnoInscripcionSuccess(perfil: event.perfil));
      add(AlumnoExamsLoaded(perfil: event.perfil));
    } catch (e) {
      emit(AlumnoInscripcionFailure(
        perfil: event.perfil,
        message: 'Error al inscribirse. Intenta de nuevo.',
      ));
      add(AlumnoExamsLoaded(perfil: event.perfil));
    }
  }

  Future<void> _onSolicitarBaja(
    AlumnoSolicitarBajaRequested event,
    Emitter<AlumnoState> emit,
  ) async {
    emit(AlumnoBajando(perfil: event.perfil));
    try {
      await dataSource.solicitarBaja(event.idInscripcion);
      emit(AlumnoBajaSuccess(perfil: event.perfil));
      add(AlumnoInscripcionesLoaded(perfil: event.perfil));
    } catch (e) {
      emit(AlumnoBajaFailure(
        perfil: event.perfil,
        message: 'No se pudo solicitar la baja. Intenta de nuevo.',
      ));
      add(AlumnoInscripcionesLoaded(perfil: event.perfil));
    }
  }

  Future<void> _onSolicitarRevision(
    AlumnoSolicitarRevisionRequested event,
    Emitter<AlumnoState> emit,
  ) async {
    emit(AlumnoRevisionSolicitando(perfil: event.perfil));
    try {
      await dataSource.solicitarRevision(event.idInscripcion);
      emit(AlumnoRevisionSuccess(perfil: event.perfil));
      add(AlumnoInscripcionesLoaded(perfil: event.perfil));
    } catch (e) {
      print('DEBUG solicitarRevision error: $e');
      emit(AlumnoRevisionFailure(
        perfil: event.perfil,
        message: 'No se pudo solicitar la revisión. Intenta de nuevo.',
      ));
      add(AlumnoInscripcionesLoaded(perfil: event.perfil));
    }
  }

  Future<void> _onSolicitarEtsEspecial(
    AlumnoSolicitarEtsEspecialRequested event,
    Emitter<AlumnoState> emit,
  ) async {
    emit(AlumnoEtsEspLoading(perfil: event.perfil));
    try {
      await dataSource.solicitarEtsEspecial(event.idInscripcion);
      emit(AlumnoEtsEspSuccess(
        perfil: event.perfil,
        message: 'Solicitud de ETS especial enviada al administrador',
      ));
      add(AlumnoInscripcionesLoaded(perfil: event.perfil));
    } catch (e) {
      emit(AlumnoEtsEspFailure(
        perfil: event.perfil,
        message: 'No se pudo solicitar el ETS especial. Intenta de nuevo.',
      ));
      add(AlumnoInscripcionesLoaded(perfil: event.perfil));
    }
  }

  Future<void> _onSolicitarBajaEtsEspecial(
    AlumnoSolicitarBajaEtsEspecialRequested event,
    Emitter<AlumnoState> emit,
  ) async {
    emit(AlumnoEtsEspLoading(perfil: event.perfil));
    try {
      await dataSource.solicitarBajaEtsEspecial(event.idEtsEspecial);
      emit(AlumnoEtsEspSuccess(
        perfil: event.perfil,
        message: 'Solicitud de baja del ETS especial enviada',
      ));
      add(AlumnoInscripcionesLoaded(perfil: event.perfil));
    } catch (e) {
      emit(AlumnoEtsEspFailure(
        perfil: event.perfil,
        message: 'No se pudo solicitar la baja. Intenta de nuevo.',
      ));
      add(AlumnoInscripcionesLoaded(perfil: event.perfil));
    }
  }

  Future<void> _onSolicitarRevisionEtsEspecial(
    AlumnoSolicitarRevisionEtsEspecialRequested event,
    Emitter<AlumnoState> emit,
  ) async {
    emit(AlumnoEtsEspLoading(perfil: event.perfil));
    try {
      await dataSource.solicitarRevisionEtsEspecial(event.idEtsEspecial);
      emit(AlumnoEtsEspSuccess(
        perfil: event.perfil,
        message: 'Solicitud de revisión del ETS especial enviada',
      ));
      add(AlumnoInscripcionesLoaded(perfil: event.perfil));
    } catch (e) {
      print('DEBUG solicitarRevisionEtsEspecial error: $e');
      emit(AlumnoEtsEspFailure(
        perfil: event.perfil,
        message: 'No se pudo solicitar la revisión. Intenta de nuevo.',
      ));
      add(AlumnoInscripcionesLoaded(perfil: event.perfil));
    }
  }
}
