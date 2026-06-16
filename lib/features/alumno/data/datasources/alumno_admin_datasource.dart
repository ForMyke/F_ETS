import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etsAndroid/core/constants/api_endpoints.dart';
import 'package:etsAndroid/features/alumno/domain/entities/alumno_admin_item.dart';
import 'package:etsAndroid/features/alumno/data/models/alumno_admin_model.dart';

export 'package:etsAndroid/features/alumno/domain/entities/alumno_admin_item.dart';

abstract class AlumnosAdminDataSource {
  Future<List<AlumnoAdminItem>> getAlumnos();

  Future<void> createAlumno({
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String correo,
    required String boleta,
    required String password,
    required String idCarrera,
    required String idPlan,
  });

  Future<void> toggleActivo({
    required String idAlumno,
    required bool activo,
  });

  Future<void> deleteAlumno(String idAlumno);
}

class AlumnosAdminDataSourceImpl implements AlumnosAdminDataSource {
  final SupabaseClient client;

  const AlumnosAdminDataSourceImpl({required this.client});

  @override
  Future<List<AlumnoAdminItem>> getAlumnos() async {
    final res = await client.from(Tables.alumno).select('''
      id_alumno,
      boleta,
      id_carrera,
      id_plan,
      usuario (
        nombre,
        apellidopaterno,
        apellidomaterno,
        correo,
        activo
      )
    ''').order(Cols.boleta, ascending: true);

    return (res as List)
        .map((e) => AlumnoAdminModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> createAlumno({
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String correo,
    required String boleta,
    required String password,
    required String idCarrera,
    required String idPlan,
  }) async {
    final adminSession = client.auth.currentSession;
    if (adminSession == null) throw Exception('No hay sesión de admin activa.');

    final authRes = await client.auth.signUp(
      email: correo,
      password: password,
    );

    final uid = authRes.user?.id;
    if (uid == null)
      throw Exception('No se pudo crear la cuenta de autenticación.');

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
      Cols.idUsuario: uid,
      Cols.boleta: boleta,
      Cols.idCarrera: idCarrera,
      Cols.idPlan: idPlan,
    });

    // Restaurar sesión del admin
    await client.auth.setSession(adminSession.refreshToken!);
  }

  @override
  Future<void> toggleActivo({
    required String idAlumno,
    required bool activo,
  }) async {
    await client
        .from(Tables.usuario)
        .update({Cols.activo: activo}).eq(Cols.idUsuario, idAlumno);
  }

  @override
  Future<void> deleteAlumno(String idAlumno) async {
    await client.from(Tables.alumno).delete().eq(Cols.idAlumnoCol, idAlumno);

    await client.from(Tables.usuario).delete().eq(Cols.idUsuario, idAlumno);
  }
}
