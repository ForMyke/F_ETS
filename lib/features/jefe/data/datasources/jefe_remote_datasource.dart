import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etsAndroid/core/constants/api_endpoints.dart';

// ── Modelos ───────────────────────────────────────────────────────────────────

class JefeProfile {
  final String idJefe;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;

  const JefeProfile({
    required this.idJefe,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
  });

  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';
}

class EtsDeJefeItem {
  final String idEts;
  final String materia;
  final String carrera;
  final String salon;
  final String edificio;
  final DateTime fechaInicio;
  final String hora;
  final String turno;
  final String estado;

  const EtsDeJefeItem({
    required this.idEts,
    required this.materia,
    required this.carrera,
    required this.salon,
    required this.edificio,
    required this.fechaInicio,
    required this.hora,
    required this.turno,
    required this.estado,
  });
}

class AlumnoInscritoItem {
  final String idInscripcion;
  final String boleta;
  final String nombreAlumno;
  final double? calificacion;
  final String? resultado;
  final String estado;

  const AlumnoInscritoItem({
    required this.idInscripcion,
    required this.boleta,
    required this.nombreAlumno,
    this.calificacion,
    this.resultado,
    required this.estado,
  });
}

// ── Contrato ──────────────────────────────────────────────────────────────────

abstract class JefeRemoteDataSource {
  Future<JefeProfile> login({
    required String correo,
    required String password,
  });

  Future<void> logout();

  Future<List<EtsDeJefeItem>> getEtsDeJefe(String idJefe);

  Future<List<AlumnoInscritoItem>> getAlumnosInscritos(String idEts);

  Future<void> guardarCalificacion({
    required String idInscripcion,
    required double calificacion,
  });
}

// ── Implementación ────────────────────────────────────────────────────────────

class JefeRemoteDataSourceImpl implements JefeRemoteDataSource {
  final SupabaseClient client;

  const JefeRemoteDataSourceImpl({required this.client});

  @override
  Future<JefeProfile> login({
    required String correo,
    required String password,
  }) async {
    final authRes = await client.auth.signInWithPassword(
      email: correo,
      password: password,
    );

    final user = authRes.user;
    if (user == null) throw Exception('Credenciales incorrectas.');

    final uid = user.id;

    // Verificar que sea jefe de academia
    final jefeRes = await client
        .from(Tables.jefeAcademia)
        .select(
            'id_jefeacademia, usuario(nombre, apellidopaterno, apellidomaterno, correo)')
        .eq(Cols.idJefeAcademiaCol, uid)
        .maybeSingle();

    if (jefeRes == null) {
      await client.auth.signOut();
      throw Exception(
          'Esta cuenta no corresponde a un jefe de academia registrado.');
    }

    final u = jefeRes['usuario'] as Map<String, dynamic>;

    return JefeProfile(
      idJefe: jefeRes['id_jefeacademia'] as String,
      nombre: u['nombre'] as String,
      apellidoPaterno: u['apellidopaterno'] as String,
      apellidoMaterno: u['apellidomaterno'] as String,
      correo: u['correo'] as String,
    );
  }

  @override
  Future<void> logout() async {
    await client.auth.signOut();
  }

  @override
  Future<List<EtsDeJefeItem>> getEtsDeJefe(String idJefe) async {
    // Obtenemos la academia del jefe
    final academiaRes = await client
        .from(Tables.academia)
        .select('id_academia')
        .eq(Cols.idJefeAcademiaCol, idJefe)
        .maybeSingle();

    if (academiaRes == null) return [];

    final idAcademia = academiaRes['id_academia'] as String;

    // Obtenemos los ETS donde la carrera_materia pertenece a esa academia
    final res = await client.from(Tables.ets).select('''
      id_ets,
      fechahorainicio,
      turno,
      estado,
      salon ( codigo, edificio ( numero ) ),
      carrera_materia (
        id_academia,
        materia ( nombre ),
        carrera ( acronimo )
      )
    ''').eq(Cols.estado, ColValues.estadoActivo);

    // Filtrar en memoria por academia
    final filtrados = (res as List).where((e) {
      final cm = e['carrera_materia'] as Map<String, dynamic>;
      return cm['id_academia'] == idAcademia;
    }).toList();

    return filtrados.map((e) {
      final salon = e['salon'] as Map<String, dynamic>;
      final cm = e['carrera_materia'] as Map<String, dynamic>;
      final fechaInicio = DateTime.parse(e['fechahorainicio'] as String);

      return EtsDeJefeItem(
        idEts: e['id_ets'] as String,
        materia: cm['materia']['nombre'] as String,
        carrera: cm['carrera']['acronimo'] as String,
        salon: salon['codigo'] as String,
        edificio: salon['edificio']['numero'] as String,
        fechaInicio: fechaInicio,
        hora:
            '${fechaInicio.hour.toString().padLeft(2, '0')}:${fechaInicio.minute.toString().padLeft(2, '0')}',
        turno: e['turno'] as String? ?? '',
        estado: e['estado'] as String,
      );
    }).toList();
  }

  @override
  Future<List<AlumnoInscritoItem>> getAlumnosInscritos(String idEts) async {
    final res = await client.from(Tables.inscripcionEts).select('''
      id_inscripcionets,
      estado,
      calificacion,
      resultado,
      alumno (
        boleta,
        usuario ( nombre, apellidopaterno, apellidomaterno )
      )
    ''').eq(Cols.idEts, idEts);

    return (res as List).map((e) {
      final alumno = e['alumno'] as Map<String, dynamic>;
      final usuario = alumno['usuario'] as Map<String, dynamic>;
      final nombre =
          '${usuario['nombre']} ${usuario['apellidopaterno']} ${usuario['apellidomaterno']}';

      return AlumnoInscritoItem(
        idInscripcion: e['id_inscripcionets'] as String,
        boleta: alumno['boleta'] as String,
        nombreAlumno: nombre,
        calificacion: (e['calificacion'] as num?)?.toDouble(),
        resultado: e['resultado'] as String?,
        estado: e['estado'] as String,
      );
    }).toList();
  }

  @override
  Future<void> guardarCalificacion({
    required String idInscripcion,
    required double calificacion,
  }) async {
    final resultado = calificacion >= 6.0 ? ColValues.resultadoAprobado : ColValues.resultadoReprobado;
    await client.from(Tables.inscripcionEts).update({
      Cols.calificacion: calificacion,
      Cols.resultado: resultado,
      Cols.estado: ColValues.estadoCalificado,
    }).eq(Cols.idInscripcionEts, idInscripcion);
  }
}
