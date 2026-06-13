import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etsAndroid/core/constants/api_endpoints.dart';
import 'package:etsAndroid/features/jefe/domain/entities/jefe_profile.dart';
import 'package:etsAndroid/features/jefe/domain/entities/ets_de_jefe_item.dart';
import 'package:etsAndroid/features/jefe/domain/entities/alumno_inscrito_item.dart';
import 'package:etsAndroid/features/jefe/data/models/jefe_profile_model.dart';
import 'package:etsAndroid/features/jefe/data/models/ets_de_jefe_model.dart';
import 'package:etsAndroid/features/jefe/data/models/alumno_inscrito_model.dart';

export 'package:etsAndroid/features/jefe/domain/entities/jefe_profile.dart';
export 'package:etsAndroid/features/jefe/domain/entities/ets_de_jefe_item.dart';
export 'package:etsAndroid/features/jefe/domain/entities/alumno_inscrito_item.dart';

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

    return JefeProfileModel.fromJson(jefeRes);
  }

  @override
  Future<void> logout() async {
    await client.auth.signOut();
  }

  @override
  Future<List<EtsDeJefeItem>> getEtsDeJefe(String idJefe) async {
    final academiaRes = await client
        .from(Tables.academia)
        .select('id_academia')
        .eq(Cols.idJefeAcademiaCol, idJefe)
        .maybeSingle();

    if (academiaRes == null) return [];

    final idAcademia = academiaRes['id_academia'] as String;

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

    final filtrados = res.where((e) {
      final cm = e['carrera_materia'] as Map<String, dynamic>;
      return cm['id_academia'] == idAcademia;
    }).toList();

    return filtrados
        .map((e) => EtsDeJefeModel.fromJson(e))
        .toList();
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

    return res
        .map((e) => AlumnoInscritoModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> guardarCalificacion({
    required String idInscripcion,
    required double calificacion,
  }) async {
    final resultado = calificacion >= 6.0
        ? ColValues.resultadoAprobado
        : ColValues.resultadoReprobado;
    await client.from(Tables.inscripcionEts).update({
      Cols.calificacion: calificacion,
      Cols.resultado: resultado,
      Cols.estado: ColValues.estadoCalificado,
    }).eq(Cols.idInscripcionEts, idInscripcion);
  }
}
