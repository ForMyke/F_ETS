part of 'alumno_bloc.dart';

abstract class AlumnoEvent extends Equatable {
  const AlumnoEvent();

  @override
  List<Object?> get props => [];
}

class AlumnoLoginSubmitted extends AlumnoEvent {
  final String correo;
  final String password;

  const AlumnoLoginSubmitted({required this.correo, required this.password});

  @override
  List<Object> get props => [correo, password];
}

class AlumnoRegisterSubmitted extends AlumnoEvent {
  final String boleta;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String password;
  final String idCarrera;
  final String idPlan;

  const AlumnoRegisterSubmitted({
    required this.boleta,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.password,
    required this.idCarrera,
    required this.idPlan,
  });

  @override
  List<Object> get props => [boleta, nombre, correo, idCarrera, idPlan];
}

class AlumnoLogoutRequested extends AlumnoEvent {
  const AlumnoLogoutRequested();
}

class AlumnoExamsLoaded extends AlumnoEvent {
  final AlumnoProfile perfil;
  const AlumnoExamsLoaded({required this.perfil});

  @override
  List<Object> get props => [perfil.idAlumno];
}

class AlumnoInscripcionesLoaded extends AlumnoEvent {
  final AlumnoProfile perfil;
  const AlumnoInscripcionesLoaded({required this.perfil});

  @override
  List<Object> get props => [perfil.idAlumno];
}

class AlumnoInscribirseRequested extends AlumnoEvent {
  final AlumnoProfile perfil;
  final String idEts;

  const AlumnoInscribirseRequested({
    required this.perfil,
    required this.idEts,
  });

  @override
  List<Object> get props => [perfil.idAlumno, idEts];
}

class AlumnoSolicitarBajaRequested extends AlumnoEvent {
  final AlumnoProfile perfil;
  final String idInscripcion;

  const AlumnoSolicitarBajaRequested({
    required this.perfil,
    required this.idInscripcion,
  });

  @override
  List<Object> get props => [perfil.idAlumno, idInscripcion];
}
