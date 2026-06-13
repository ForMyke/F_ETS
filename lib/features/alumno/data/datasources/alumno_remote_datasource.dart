import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etsAndroid/features/search/data/models/exam_model.dart';

// ── Modelos ──────────────────────────────────────────────────────────────────

class AlumnoProfile {
  final String idAlumno;
  final String boleta;
  final String idCarrera;
  final String idPlan;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;

  const AlumnoProfile({
    required this.idAlumno,
    required this.boleta,
    required this.idCarrera,
    required this.idPlan,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
  });
}

class InscripcionItem {
  final String idInscripcion;
  final String idEts;
  final String materia;
  final String carrera;
  final String salon;
  final String edificio;
  final DateTime fechaInicio;
  final String hora;
  final String turno;
  final String estado;
  final double? calificacion;
  final String? resultado;

  const InscripcionItem({
    required this.idInscripcion,
    required this.idEts,
    required this.materia,
    required this.carrera,
    required this.salon,
    required this.edificio,
    required this.fechaInicio,
    required this.hora,
    required this.turno,
    required this.estado,
    this.calificacion,
    this.resultado,
  });
}

// ── Contrato ─────────────────────────────────────────────────────────────────

abstract class AlumnoRemoteDataSource {
  Future<void> register({
    required String boleta,
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String correo,
    required String password,
    required String idCarrera,
    required String idPlan,
  });

  Future<AlumnoProfile> login({
    required String correo,
    required String password,
  });

  Future<void> logout();

  Future<AlumnoProfile?> getPerfilActual();

  Future<List<ExamModel>> getExamsDisponibles({required String idCarrera});

  Future<bool> yaInscrito({
    required String idAlumno,
    required String idEts,
  });

  Future<void> inscribirse({
    required String idAlumno,
    required String idEts,
  });

  Future<List<InscripcionItem>> getMisInscripciones(String idAlumno);

  Future<List<Map<String, dynamic>>> getCarreras();
  Future<List<Map<String, dynamic>>> getPlanes();
}

// ── Implementación ────────────────────────────────────────────────────────────

class AlumnoRemoteDataSourceImpl implements AlumnoRemoteDataSource {
  final SupabaseClient client;

  const AlumnoRemoteDataSourceImpl({required this.client});

  static const String _selectExams = '''
    id_ets,
    fechahorainicio,
    fechahorafin,
    turno,
    estado,
    id_periodoets,
    salon (
      id_salon,
      codigo,
      piso,
      edificio (
        numero
      )
    ),
    carrera_materia (
      id_carrera,
      semestre,
      materia (
        nombre
      ),
      carrera (
        acronimo
      ),
      planestudios (
        nombre
      )
    ),
    jefeacademia (
      usuario (
        nombre,
        apellidopaterno,
        apellidomaterno
      )
    )
  ''';

  @override
  Future<void> register({
    required String boleta,
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String correo,
    required String password,
    required String idCarrera,
    required String idPlan,
  }) async {
    // 1. Crear cuenta en Supabase Auth
    final authRes = await client.auth.signUp(
      email: correo,
      password: password,
    );

    final user = authRes.user;
    if (user == null) {
      throw Exception('No se pudo crear la cuenta. Intenta de nuevo.');
    }

    final uid = user.id;

    // 2. Insertar en tabla usuario
    await client.from('usuario').insert({
      'id_usuario': uid,
      'correo': correo,
      'activo': true,
      'passwordhash': '',
      'nombre': nombre,
      'apellidopaterno': apellidoPaterno,
      'apellidomaterno': apellidoMaterno,
    });

    // 3. Insertar en tabla alumno
    await client.from('alumno').insert({
      'id_alumno': uid,
      'boleta': boleta,
      'id_carrera': idCarrera,
      'id_plan': idPlan,
      'id_usuario': uid,
    });
  }

  @override
  Future<AlumnoProfile> login({
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

    // Verificar que sea alumno
    final alumnoRes = await client
        .from('alumno')
        .select(
            'id_alumno, boleta, id_carrera, id_plan, usuario(nombre, apellidopaterno, apellidomaterno, correo)')
        .eq('id_alumno', uid)
        .maybeSingle();

    if (alumnoRes == null) {
      await client.auth.signOut();
      throw Exception('Esta cuenta no corresponde a un alumno registrado.');
    }

    final u = alumnoRes['usuario'] as Map<String, dynamic>;

    return AlumnoProfile(
      idAlumno: alumnoRes['id_alumno'] as String,
      boleta: alumnoRes['boleta'] as String,
      idCarrera: alumnoRes['id_carrera'] as String,
      idPlan: alumnoRes['id_plan'] as String,
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
  Future<AlumnoProfile?> getPerfilActual() async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    final alumnoRes = await client
        .from('alumno')
        .select(
            'id_alumno, boleta, id_carrera, id_plan, usuario(nombre, apellidopaterno, apellidomaterno, correo)')
        .eq('id_alumno', user.id)
        .maybeSingle();

    if (alumnoRes == null) return null;

    final u = alumnoRes['usuario'] as Map<String, dynamic>;

    return AlumnoProfile(
      idAlumno: alumnoRes['id_alumno'] as String,
      boleta: alumnoRes['boleta'] as String,
      idCarrera: alumnoRes['id_carrera'] as String,
      idPlan: alumnoRes['id_plan'] as String,
      nombre: u['nombre'] as String,
      apellidoPaterno: u['apellidopaterno'] as String,
      apellidoMaterno: u['apellidomaterno'] as String,
      correo: u['correo'] as String,
    );
  }

  @override
  Future<List<ExamModel>> getExamsDisponibles(
      {required String idCarrera}) async {
    final res =
        await client.from('ets').select(_selectExams).eq('estado', 'activo');

    // Filtrar en memoria: solo ETS donde id_carrera coincide con la del alumno
    final filtrados = (res as List).where((json) {
      final cm = json['carrera_materia'] as Map<String, dynamic>;
      return cm['id_carrera'] == idCarrera;
    }).toList();

    return filtrados.map((json) => ExamModel.fromJson(json)).toList();
  }

  @override
  Future<bool> yaInscrito({
    required String idAlumno,
    required String idEts,
  }) async {
    final res = await client
        .from('inscripcionets')
        .select('id_inscripcionets')
        .eq('id_alumno', idAlumno)
        .eq('id_ets', idEts)
        .maybeSingle();
    return res != null;
  }

  @override
  Future<void> inscribirse({
    required String idAlumno,
    required String idEts,
  }) async {
    // Generar ID simple con timestamp
    final id = 'INS${DateTime.now().millisecondsSinceEpoch}';
    await client.from('inscripcionets').insert({
      'id_inscripcionets': id,
      'id_ets': idEts,
      'id_alumno': idAlumno,
      'estado': 'pendiente',
      'fechainscripcion': DateTime.now().toIso8601String().substring(0, 10),
      'calificacion': null,
      'resultado': null,
    });
  }

  @override
  Future<List<InscripcionItem>> getMisInscripciones(String idAlumno) async {
    final res = await client
        .from('inscripcionets')
        .select('''
          id_inscripcionets,
          id_ets,
          estado,
          calificacion,
          resultado,
          ets (
            fechahorainicio,
            turno,
            salon ( codigo, edificio ( numero ) ),
            carrera_materia (
              materia ( nombre ),
              carrera ( acronimo )
            )
          )
        ''')
        .eq('id_alumno', idAlumno)
        .order('id_inscripcionets', ascending: false);

    return res.map((e) {
      final ets = e['ets'] as Map<String, dynamic>;
      final salon = ets['salon'] as Map<String, dynamic>;
      final cm = ets['carrera_materia'] as Map<String, dynamic>;
      final fechaInicio = DateTime.parse(ets['fechahorainicio'] as String);

      return InscripcionItem(
        idInscripcion: e['id_inscripcionets'] as String,
        idEts: e['id_ets'] as String,
        materia: cm['materia']['nombre'] as String,
        carrera: cm['carrera']['acronimo'] as String,
        salon: salon['codigo'] as String,
        edificio: salon['edificio']['numero'] as String,
        fechaInicio: fechaInicio,
        hora:
            '${fechaInicio.hour.toString().padLeft(2, '0')}:${fechaInicio.minute.toString().padLeft(2, '0')}',
        turno: ets['turno'] as String? ?? '',
        estado: e['estado'] as String,
        calificacion: (e['calificacion'] as num?)?.toDouble(),
        resultado: e['resultado'] as String?,
      );
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getCarreras() async {
    final res = await client
        .from('carrera')
        .select('id_carrera, nombre, acronimo')
        .eq('activo', true);
    return List<Map<String, dynamic>>.from(res);
  }

  @override
  Future<List<Map<String, dynamic>>> getPlanes() async {
    final res = await client.from('planestudios').select('id_plan, nombre');
    return List<Map<String, dynamic>>.from(res);
  }
}
