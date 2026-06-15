/// Supabase table names and common column/field constants.
///
/// Use these instead of raw string literals in datasources and repositories
/// to prevent typos and centralise future schema changes.
abstract class Tables {
  Tables._();

  static const String ets = 'ets';
  static const String carrera = 'carrera';
  static const String carreraMateria = 'carrera_materia';
  static const String salon = 'salon';
  static const String edificio = 'edificio';
  static const String periodoEts = 'periodoets';
  static const String jefeAcademia = 'jefeacademia';
  static const String academia = 'academia';
  static const String inscripcionEts = 'inscripcionets';
  static const String alumno = 'alumno';
  static const String usuario = 'usuario';
  static const String planEstudios = 'planestudios';
  static const String materia = 'materia';
}

abstract class Cols {
  Cols._();

  // ── ets ──────────────────────────────────────────────────────────────────
  static const String idEts = 'id_ets';
  static const String fechaHoraInicio = 'fechahorainicio';
  static const String fechaHoraFin = 'fechahorafin';
  static const String turno = 'turno';
  static const String estado = 'estado';
  static const String idPeriodoEts = 'id_periodoets';
  static const String idSalon = 'id_salon';
  static const String idCarreraMateria = 'id_carrera_materia';
  static const String idJefeAcademia = 'id_jefeacademia';

  // ── carrera_materia ───────────────────────────────────────────────────────
  static const String idCarrera = 'id_carrera';
  static const String idPlan = 'id_plan';
  static const String semestre = 'semestre';
  static const String idAcademia = 'id_academia';

  // ── salon / edificio ──────────────────────────────────────────────────────
  static const String idSalonCol = 'id_salon';
  static const String codigo = 'codigo';
  static const String piso = 'piso';
  static const String idEdificio = 'id_edificio';
  static const String numero = 'numero';

  // ── periodoets ────────────────────────────────────────────────────────────
  static const String idPeriodoEtsCol = 'id_periodoets';

  // ── jefeacademia / usuario ────────────────────────────────────────────────
  static const String idJefeAcademiaCol = 'id_jefeacademia';
  static const String idUsuario = 'id_usuario';
  static const String correo = 'correo';
  static const String nombre = 'nombre';
  static const String apellidoPaterno = 'apellidopaterno';
  static const String apellidoMaterno = 'apellidomaterno';
  static const String passwordHash = 'passwordhash';
  static const String activo = 'activo';

  // ── inscripcionets ────────────────────────────────────────────────────────
  static const String idInscripcionEts = 'id_inscripcionets';
  static const String idAlumno = 'id_alumno';
  static const String calificacion = 'calificacion';
  static const String resultado = 'resultado';
  static const String fechaInscripcion = 'fechainscripcion';

  // ── alumno ────────────────────────────────────────────────────────────────
  static const String idAlumnoCol = 'id_alumno';
  static const String boleta = 'boleta';

  // ── academia ──────────────────────────────────────────────────────────────
  static const String idAcademiaCol = 'id_academia';
  static const String acronimo = 'acronimo';

  // ── carrera ───────────────────────────────────────────────────────────────
  static const String idCarreraCol = 'id_carrera';

  // ── planestudios ──────────────────────────────────────────────────────────
  static const String idPlan2 = 'id_plan';
}

abstract class ColValues {
  ColValues._();

  static const String estadoActivo = 'activo';
  static const String estadoPendiente = 'pendiente';
  static const String estadoCalificado = 'calificado';
  static const String turnoMatutino = 'Matutino';
  static const String turnoVespertino = 'Vespertino';
  static const String estadoConfirmada = 'confirmada';
  static const String estadoBajaSolicitada = 'baja_solicitada';
  static const String estadoRechazada = 'rechazada';
  static const String estadoBajaAprobada = 'baja_aprobada';
  static const String resultadoAprobado = 'aprobado';
  static const String resultadoReprobado = 'reprobado';
}
