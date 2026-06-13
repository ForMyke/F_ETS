part of 'jefe_bloc.dart';

abstract class JefeEvent extends Equatable {
  const JefeEvent();

  @override
  List<Object?> get props => [];
}

class JefeLoginSubmitted extends JefeEvent {
  final String correo;
  final String password;

  const JefeLoginSubmitted({required this.correo, required this.password});

  @override
  List<Object> get props => [correo, password];
}

class JefeLogoutRequested extends JefeEvent {
  const JefeLogoutRequested();
}

class JefeEtsLoaded extends JefeEvent {
  final JefeProfile perfil;
  const JefeEtsLoaded({required this.perfil});

  @override
  List<Object> get props => [perfil.idJefe];
}

class JefeAlumnosLoaded extends JefeEvent {
  final JefeProfile perfil;
  final String idEts;
  final String materiaEts;

  const JefeAlumnosLoaded({
    required this.perfil,
    required this.idEts,
    required this.materiaEts,
  });

  @override
  List<Object> get props => [perfil.idJefe, idEts];
}

class JefeCalificacionGuardada extends JefeEvent {
  final JefeProfile perfil;
  final String idEts;
  final String materiaEts;
  final String idInscripcion;
  final double calificacion;
  final List<AlumnoInscritoItem> alumnosActuales;

  const JefeCalificacionGuardada({
    required this.perfil,
    required this.idEts,
    required this.materiaEts,
    required this.idInscripcion,
    required this.calificacion,
    required this.alumnosActuales,
  });

  @override
  List<Object> get props => [idInscripcion, calificacion];
}
