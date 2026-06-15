part of 'alumno_bloc.dart';

abstract class AlumnoState extends Equatable {
  const AlumnoState();

  @override
  List<Object?> get props => [];
}

class AlumnoInitial extends AlumnoState {
  const AlumnoInitial();
}

class AlumnoLoading extends AlumnoState {
  const AlumnoLoading();
}

class AlumnoAuthenticated extends AlumnoState {
  final AlumnoProfile perfil;
  const AlumnoAuthenticated({required this.perfil});

  @override
  List<Object> get props => [perfil.idAlumno];
}

class AlumnoRegisterSuccess extends AlumnoState {
  const AlumnoRegisterSuccess();
}

class AlumnoAuthFailure extends AlumnoState {
  final String message;
  const AlumnoAuthFailure({required this.message});

  @override
  List<Object> get props => [message];
}

// ── Estados de exámenes ───────────────────────────────────────────────────────

class AlumnoExamsLoading extends AlumnoState {
  final AlumnoProfile perfil;
  const AlumnoExamsLoading({required this.perfil});

  @override
  List<Object> get props => [perfil.idAlumno];
}

class AlumnoExamsSuccess extends AlumnoState {
  final AlumnoProfile perfil;
  final List<ExamModel> exams;

  const AlumnoExamsSuccess({required this.perfil, required this.exams});

  @override
  List<Object> get props => [perfil.idAlumno, exams];
}

class AlumnoExamsFailure extends AlumnoState {
  final AlumnoProfile perfil;
  final String message;

  const AlumnoExamsFailure({required this.perfil, required this.message});

  @override
  List<Object> get props => [perfil.idAlumno, message];
}

// ── Estados de inscripciones ──────────────────────────────────────────────────

class AlumnoInscripcionesLoading extends AlumnoState {
  final AlumnoProfile perfil;
  const AlumnoInscripcionesLoading({required this.perfil});

  @override
  List<Object> get props => [perfil.idAlumno];
}

class AlumnoInscripcionesSuccess extends AlumnoState {
  final AlumnoProfile perfil;
  final List<InscripcionItem> inscripciones;

  const AlumnoInscripcionesSuccess({
    required this.perfil,
    required this.inscripciones,
  });

  @override
  List<Object> get props => [perfil.idAlumno, inscripciones];
}

class AlumnoInscripcionesFailure extends AlumnoState {
  final AlumnoProfile perfil;
  final String message;

  const AlumnoInscripcionesFailure({
    required this.perfil,
    required this.message,
  });

  @override
  List<Object> get props => [perfil.idAlumno, message];
}

// ── Estados de inscribirse ────────────────────────────────────────────────────

class AlumnoInscribiendose extends AlumnoState {
  final AlumnoProfile perfil;
  const AlumnoInscribiendose({required this.perfil});

  @override
  List<Object> get props => [perfil.idAlumno];
}

class AlumnoInscripcionSuccess extends AlumnoState {
  final AlumnoProfile perfil;
  const AlumnoInscripcionSuccess({required this.perfil});

  @override
  List<Object> get props => [perfil.idAlumno];
}

class AlumnoInscripcionFailure extends AlumnoState {
  final AlumnoProfile perfil;
  final String message;

  const AlumnoInscripcionFailure({
    required this.perfil,
    required this.message,
  });

  @override
  List<Object> get props => [perfil.idAlumno, message];
}

// ── Estados de solicitar baja ─────────────────────────────────────────────────

class AlumnoBajando extends AlumnoState {
  final AlumnoProfile perfil;
  const AlumnoBajando({required this.perfil});

  @override
  List<Object> get props => [perfil.idAlumno];
}

class AlumnoBajaSuccess extends AlumnoState {
  final AlumnoProfile perfil;
  const AlumnoBajaSuccess({required this.perfil});

  @override
  List<Object> get props => [perfil.idAlumno];
}

class AlumnoBajaFailure extends AlumnoState {
  final AlumnoProfile perfil;
  final String message;

  const AlumnoBajaFailure({required this.perfil, required this.message});

  @override
  List<Object> get props => [perfil.idAlumno, message];
}
