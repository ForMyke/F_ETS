import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etsAndroid/core/constants/api_endpoints.dart';
import 'package:etsAndroid/features/alumno/domain/entities/alumno_profile.dart';
import 'package:etsAndroid/features/alumno/domain/entities/inscripcion_item.dart';
import 'package:etsAndroid/features/alumno/data/models/alumno_profile_model.dart';
import 'package:etsAndroid/features/alumno/data/models/inscripcion_model.dart';
import 'package:etsAndroid/features/search/data/models/exam_model.dart';

export 'package:etsAndroid/features/alumno/domain/entities/alumno_profile.dart';
export 'package:etsAndroid/features/alumno/domain/entities/inscripcion_item.dart';

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
    final authRes = await client.auth.signUp(
      email: correo,
      password: password,
    );

    final user = authRes.user;
    if (user == null) {
      throw Exception('No se pudo crear la cuenta. Intenta de nuevo.');
    }

    final uid = user.id;

    await client.from(Tables.usuario).insert({
      Cols.idUsuario: uid,
      Cols.correo: correo,
      Cols.activo: true,
      Cols.passwordHash: '',
      Cols.nombre: nombre,
      Cols.apellidoPaterno: apellidoPaterno,
      Cols.apellidoMaterno: apellidoMaterno,
    });

    await client.from(Tables.alumno).insert({
      Cols.idAlumnoCol: uid,
      Cols.boleta: boleta,
      Cols.idCarrera: idCarrera,
      Cols.idPlan: idPlan,
      Cols.idUsuario: uid,
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

    final alumnoRes = await client
        .from(Tables.alumno)
        .select(
            'id_alumno, boleta, id_carrera, id_plan, usuario(nombre, apellidopaterno, apellidomaterno, correo)')
        .eq(Cols.idAlumno, uid)
        .maybeSingle();

    if (alumnoRes == null) {
      await client.auth.signOut();
      throw Exception('Esta cuenta no corresponde a un alumno registrado.');
    }

    return AlumnoProfileModel.fromJson(alumnoRes as Map<String, dynamic>);
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
        .from(Tables.alumno)
        .select(
            'id_alumno, boleta, id_carrera, id_plan, usuario(nombre, apellidopaterno, apellidomaterno, correo)')
        .eq(Cols.idAlumno, user.id)
        .maybeSingle();

    if (alumnoRes == null) return null;

    return AlumnoProfileModel.fromJson(alumnoRes as Map<String, dynamic>);
  }

  @override
  Future<List<ExamModel>> getExamsDisponibles(
      {required String idCarrera}) async {
    final res = await client
        .from(Tables.ets)
        .select(_selectExams)
        .eq(Cols.estado, ColValues.estadoActivo);

    final filtrados = (res as List).where((json) {
      final cm = json['carrera_materia'] as Map<String, dynamic>;
      return cm['id_carrera'] == idCarrera;
    }).toList();

    return filtrados
        .map((json) => ExamModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<bool> yaInscrito({
    required String idAlumno,
    required String idEts,
  }) async {
    final res = await client
        .from(Tables.inscripcionEts)
        .select('id_inscripcionets')
        .eq(Cols.idAlumno, idAlumno)
        .eq(Cols.idEts, idEts)
        .maybeSingle();
    return res != null;
  }

  @override
  Future<void> inscribirse({
    required String idAlumno,
    required String idEts,
  }) async {
    final id = 'INS${DateTime.now().millisecondsSinceEpoch}';
    await client.from(Tables.inscripcionEts).insert({
      Cols.idInscripcionEts: id,
      Cols.idEts: idEts,
      Cols.idAlumno: idAlumno,
      Cols.estado: ColValues.estadoPendiente,
      Cols.fechaInscripcion:
          DateTime.now().toIso8601String().substring(0, 10),
      Cols.calificacion: null,
      Cols.resultado: null,
    });
  }

  @override
  Future<List<InscripcionItem>> getMisInscripciones(String idAlumno) async {
    final res = await client
        .from(Tables.inscripcionEts)
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
        .eq(Cols.idAlumno, idAlumno)
        .order(Cols.idInscripcionEts, ascending: false);

    return res
        .map((e) => InscripcionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getCarreras() async {
    final res = await client
        .from(Tables.carrera)
        .select('id_carrera, nombre, acronimo')
        .eq(Cols.activo, true);
    return List<Map<String, dynamic>>.from(res);
  }

  @override
  Future<List<Map<String, dynamic>>> getPlanes() async {
    final res =
        await client.from(Tables.planEstudios).select('id_plan, nombre');
    return List<Map<String, dynamic>>.from(res);
  }
}
