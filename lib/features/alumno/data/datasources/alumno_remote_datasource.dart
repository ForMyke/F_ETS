import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etsAndroid/core/constants/api_endpoints.dart';
import 'package:etsAndroid/features/alumno/domain/entities/alumno_profile.dart';
import 'package:etsAndroid/features/alumno/domain/entities/inscripcion_item.dart';
import 'package:etsAndroid/features/alumno/data/models/alumno_profile_model.dart';
import 'package:etsAndroid/features/alumno/data/models/inscripcion_model.dart';
import 'package:etsAndroid/features/search/data/models/exam_model.dart';
import 'package:etsAndroid/features/notificaciones/data/datasources/notificaciones_datasource.dart';

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

  Future<void> solicitarBaja(String idInscripcion);

  Future<void> solicitarRevision(String idInscripcion);

  Future<void> solicitarEtsEspecial(String idInscripcion);
  Future<void> solicitarBajaEtsEspecial(String idEtsEspecial);
  Future<void> solicitarRevisionEtsEspecial(String idEtsEspecial);

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

    // Si signUp no devuelve sesión (confirmación pendiente a nivel config),
    // hacemos signIn para obtenerla antes de insertar en tablas propias.
    if (authRes.session == null) {
      await client.auth.signInWithPassword(email: correo, password: password);
    }

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

    return AlumnoProfileModel.fromJson(alumnoRes);
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

    return AlumnoProfileModel.fromJson(alumnoRes);
  }

  @override
  Future<List<ExamModel>> getExamsDisponibles(
      {required String idCarrera}) async {
    final res = await client
        .from(Tables.ets)
        .select(_selectExams)
        .eq(Cols.estado, ColValues.estadoActivo);

    final filtrados = res.where((json) {
      final cm = json['carrera_materia'] as Map<String, dynamic>;
      return cm['id_carrera'] == idCarrera;
    }).toList();

    return filtrados
        .map((json) => ExamModel.fromJson(json))
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
    // Notificar al admin
    String materia = 'ETS';
    try {
      final res = await client
          .from(Tables.ets)
          .select('carrera_materia(materia(nombre))')
          .eq(Cols.idEts, idEts)
          .maybeSingle();
      materia = (res?['carrera_materia']?['materia']?['nombre'] as String?) ?? materia;
    } catch (_) {}
    await crearNotificacion(client,
        paraAdmin: true,
        tipo: 'inscripcion_nueva',
        mensaje: 'Nueva inscripción: $materia',
        refId: id);
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

    return res.map((e) => InscripcionModel.fromJson(e)).toList();
  }

  // Carga inscripciones con datos de revisión y ETS especial.
  // Requiere ejecutar scripts/add_revision_flow.sql y add_ets_especial_flow.sql
  // en Supabase antes de usar este método.
  Future<List<InscripcionItem>> getMisInscripcionesConRevisiones(
      String idAlumno) async {
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
          ),
          revisionets (
            id_revision,
            estado,
            fecha_revision,
            lugar,
            calificacion
          ),
          etsespecial (
            id_ets_especial,
            estado,
            calificacion,
            resultado,
            revisionetsespecial (
              id_revision_esp,
              estado,
              fecha_revision,
              lugar,
              calificacion
            )
          )
        ''')
        .eq(Cols.idAlumno, idAlumno)
        .order(Cols.idInscripcionEts, ascending: false);

    return res.map((e) => InscripcionModel.fromJson(e)).toList();
  }

  @override
  Future<void> solicitarBaja(String idInscripcion) async {
    await client
        .from(Tables.inscripcionEts)
        .update({Cols.estado: ColValues.estadoBajaSolicitada})
        .eq(Cols.idInscripcionEts, idInscripcion);
    String materia = 'ETS';
    try {
      final res = await client
          .from(Tables.inscripcionEts)
          .select('ets(carrera_materia(materia(nombre)))')
          .eq(Cols.idInscripcionEts, idInscripcion)
          .maybeSingle();
      materia = (res?['ets']?['carrera_materia']?['materia']?['nombre'] as String?) ?? materia;
    } catch (_) {}
    await crearNotificacion(client,
        paraAdmin: true,
        tipo: 'baja_solicitada',
        mensaje: 'Solicitud de baja: $materia',
        refId: idInscripcion);
  }

  @override
  Future<void> solicitarRevision(String idInscripcion) async {
    final id = 'REV${DateTime.now().millisecondsSinceEpoch}';
    await client.from(Tables.revisionEts).insert({
      'id_revision': id,
      'id_inscripcion': idInscripcion,
      'estado': ColValues.revisionSolicitada,
      'fecha_solicitud': DateTime.now().toIso8601String().substring(0, 10),
    });
    // Notificar al jefe de academia del ETS
    try {
      final res = await client
          .from(Tables.inscripcionEts)
          .select('ets(id_jefeacademia, carrera_materia(materia(nombre)))')
          .eq(Cols.idInscripcionEts, idInscripcion)
          .maybeSingle();
      final jefeId = res?['ets']?['id_jefeacademia'] as String?;
      final materia = (res?['ets']?['carrera_materia']?['materia']?['nombre'] as String?) ?? 'ETS';
      if (jefeId != null) {
        await crearNotificacion(client,
            receptorId: jefeId,
            tipo: 'revision_solicitada',
            mensaje: 'Solicitud de revisión: $materia',
            refId: idInscripcion);
      }
    } catch (_) {}
  }

  @override
  Future<void> solicitarEtsEspecial(String idInscripcion) async {
    final id = 'ESP${DateTime.now().millisecondsSinceEpoch}';
    await client.from('etsespecial').insert({
      'id_ets_especial': id,
      'id_inscripcion_orig': idInscripcion,
      'estado': ColValues.estadoPendiente,
      'fecha_solicitud': DateTime.now().toIso8601String().substring(0, 10),
    });
    String materia = 'ETS';
    try {
      final res = await client
          .from(Tables.inscripcionEts)
          .select('ets(carrera_materia(materia(nombre)))')
          .eq(Cols.idInscripcionEts, idInscripcion)
          .maybeSingle();
      materia = (res?['ets']?['carrera_materia']?['materia']?['nombre'] as String?) ?? materia;
    } catch (_) {}
    await crearNotificacion(client,
        paraAdmin: true,
        tipo: 'ets_especial_solicitado',
        mensaje: 'Solicitud de ETS especial: $materia',
        refId: idInscripcion);
  }

  @override
  Future<void> solicitarBajaEtsEspecial(String idEtsEspecial) async {
    await client.from('etsespecial').update({
      'estado': ColValues.estadoBajaSolicitada,
    }).eq('id_ets_especial', idEtsEspecial);
    await crearNotificacion(client,
        paraAdmin: true,
        tipo: 'baja_especial_solicitada',
        mensaje: 'Solicitud de baja de ETS especial',
        refId: idEtsEspecial);
  }

  @override
  Future<void> solicitarRevisionEtsEspecial(String idEtsEspecial) async {
    final id = 'REVE${DateTime.now().millisecondsSinceEpoch}';
    await client.from('revisionetsespecial').insert({
      'id_revision_esp': id,
      'id_ets_especial': idEtsEspecial,
      'estado': ColValues.revisionSolicitada,
      'fecha_solicitud': DateTime.now().toIso8601String().substring(0, 10),
    });
    // Notificar al jefe de academia del ETS especial
    try {
      final res = await client
          .from('etsespecial')
          .select('inscripcionets(ets(id_jefeacademia, carrera_materia(materia(nombre))))')
          .eq('id_ets_especial', idEtsEspecial)
          .maybeSingle();
      final ets = res?['inscripcionets']?['ets'];
      final jefeId = ets?['id_jefeacademia'] as String?;
      final materia = (ets?['carrera_materia']?['materia']?['nombre'] as String?) ?? 'ETS';
      if (jefeId != null) {
        await crearNotificacion(client,
            receptorId: jefeId,
            tipo: 'revision_especial_solicitada',
            mensaje: 'Solicitud de revisión ETS especial: $materia',
            refId: idEtsEspecial);
      }
    } catch (_) {}
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
