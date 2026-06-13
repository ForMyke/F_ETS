part of 'jefe_bloc.dart';

abstract class JefeState extends Equatable {
  const JefeState();

  @override
  List<Object?> get props => [];
}

class JefeInitial extends JefeState {
  const JefeInitial();
}

class JefeLoading extends JefeState {
  const JefeLoading();
}

class JefeAuthenticated extends JefeState {
  final JefeProfile perfil;
  const JefeAuthenticated({required this.perfil});

  @override
  List<Object> get props => [perfil.idJefe];
}

class JefeAuthFailure extends JefeState {
  final String message;
  const JefeAuthFailure({required this.message});

  @override
  List<Object> get props => [message];
}

// ── ETS del jefe ──────────────────────────────────────────────────────────────

class JefeEtsLoading extends JefeState {
  final JefeProfile perfil;
  const JefeEtsLoading({required this.perfil});

  @override
  List<Object> get props => [perfil.idJefe];
}

class JefeEtsSuccess extends JefeState {
  final JefeProfile perfil;
  final List<EtsDeJefeItem> etsList;

  const JefeEtsSuccess({required this.perfil, required this.etsList});

  @override
  List<Object> get props => [perfil.idJefe, etsList];
}

class JefeEtsFailure extends JefeState {
  final JefeProfile perfil;
  final String message;

  const JefeEtsFailure({required this.perfil, required this.message});

  @override
  List<Object> get props => [perfil.idJefe, message];
}

// ── Alumnos inscritos ─────────────────────────────────────────────────────────

class JefeAlumnosLoading extends JefeState {
  final JefeProfile perfil;
  final String idEts;

  const JefeAlumnosLoading({required this.perfil, required this.idEts});

  @override
  List<Object> get props => [perfil.idJefe, idEts];
}

class JefeAlumnosSuccess extends JefeState {
  final JefeProfile perfil;
  final String idEts;
  final String materiaEts;
  final List<AlumnoInscritoItem> alumnos;

  const JefeAlumnosSuccess({
    required this.perfil,
    required this.idEts,
    required this.materiaEts,
    required this.alumnos,
  });

  @override
  List<Object> get props => [perfil.idJefe, idEts, alumnos];
}

class JefeAlumnosFailure extends JefeState {
  final JefeProfile perfil;
  final String idEts;
  final String message;

  const JefeAlumnosFailure({
    required this.perfil,
    required this.idEts,
    required this.message,
  });

  @override
  List<Object> get props => [perfil.idJefe, idEts, message];
}

// ── Calificación ──────────────────────────────────────────────────────────────

class JefeGuardandoCalificacion extends JefeState {
  final JefeProfile perfil;
  final String idEts;
  final String materiaEts;
  final List<AlumnoInscritoItem> alumnos;

  const JefeGuardandoCalificacion({
    required this.perfil,
    required this.idEts,
    required this.materiaEts,
    required this.alumnos,
  });

  @override
  List<Object> get props => [perfil.idJefe, idEts];
}

class JefeCalificacionFailure extends JefeState {
  final JefeProfile perfil;
  final String idEts;
  final String materiaEts;
  final List<AlumnoInscritoItem> alumnos;
  final String message;

  const JefeCalificacionFailure({
    required this.perfil,
    required this.idEts,
    required this.materiaEts,
    required this.alumnos,
    required this.message,
  });

  @override
  List<Object> get props => [perfil.idJefe, idEts, message];
}
