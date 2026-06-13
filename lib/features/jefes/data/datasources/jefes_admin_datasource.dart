import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etsAndroid/core/constants/api_endpoints.dart';

class JefeAdminItem {
  final String idJefe;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String? idAcademia;
  final String? nombreAcademia;

  const JefeAdminItem({
    required this.idJefe,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    this.idAcademia,
    this.nombreAcademia,
  });

  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';
}

class AcademiaItem {
  final String idAcademia;
  final String nombre;
  final String acronimo;

  const AcademiaItem({
    required this.idAcademia,
    required this.nombre,
    required this.acronimo,
  });
}

abstract class JefesAdminDataSource {
  Future<List<JefeAdminItem>> getJefes();
  Future<List<AcademiaItem>> getAcademias();
  Future<void> createJefe({
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String correo,
    required String password,
    required String idAcademia,
  });
  Future<void> deleteJefe(String idJefe);
}

class JefesAdminDataSourceImpl implements JefesAdminDataSource {
  final SupabaseClient client;

  const JefesAdminDataSourceImpl({required this.client});

  @override
  Future<List<JefeAdminItem>> getJefes() async {
    final res = await client.from(Tables.jefeAcademia).select('''
      id_jefeacademia,
      usuario ( nombre, apellidopaterno, apellidomaterno, correo )
    ''');

    // También obtenemos las academias para saber a cuál pertenece cada jefe
    final academias = await client
        .from(Tables.academia)
        .select('id_academia, nombre, id_jefeacademia');

    return (res as List).map((e) {
      final u = e['usuario'] as Map<String, dynamic>;
      final idJefe = e['id_jefeacademia'] as String;

      // Buscar academia del jefe
      final academiaList = (academias as List)
          .where((a) => a['id_jefeacademia'] == idJefe)
          .toList();
      final academia = academiaList.isNotEmpty ? academiaList.first : null;

      return JefeAdminItem(
        idJefe: idJefe,
        nombre: u['nombre'] as String,
        apellidoPaterno: u['apellidopaterno'] as String,
        apellidoMaterno: u['apellidomaterno'] as String,
        correo: u['correo'] as String,
        idAcademia: academia?['id_academia'] as String?,
        nombreAcademia: academia?['nombre'] as String?,
      );
    }).toList();
  }

  @override
  Future<List<AcademiaItem>> getAcademias() async {
    final res =
        await client.from(Tables.academia).select('id_academia, nombre, acronimo');
    return (res as List)
        .map((e) => AcademiaItem(
              idAcademia: e['id_academia'] as String,
              nombre: e['nombre'] as String,
              acronimo: e['acronimo'] as String,
            ))
        .toList();
  }

  @override
  Future<void> createJefe({
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String correo,
    required String password,
    required String idAcademia,
  }) async {
    // Guardar credenciales del admin actual antes de crear el nuevo usuario
    final adminSession = client.auth.currentSession;
    final adminEmail = client.auth.currentUser?.email;
    if (adminSession == null || adminEmail == null) {
      throw Exception('No hay sesión de admin activa.');
    }

    // 1. Crear cuenta del jefe con signUp (cierra sesión del admin temporalmente)
    final authRes = await client.auth.signUp(
      email: correo,
      password: password,
    );

    final uid = authRes.user?.id;
    if (uid == null) throw Exception('No se pudo crear la cuenta.');

    // 2. Insertar datos del jefe con el token del nuevo usuario (aún activo)
    await client.from(Tables.usuario).insert({
      Cols.idUsuario: uid,
      Cols.correo: correo,
      Cols.activo: true,
      Cols.passwordHash: '',
      Cols.nombre: nombre,
      Cols.apellidoPaterno: apellidoPaterno,
      Cols.apellidoMaterno: apellidoMaterno,
    });

    await client.from(Tables.jefeAcademia).insert({
      Cols.idJefeAcademiaCol: uid,
      Cols.idUsuario: uid,
    });

    await client
        .from(Tables.academia)
        .update({Cols.idJefeAcademiaCol: uid}).eq(Cols.idAcademiaCol, idAcademia);

    // 3. Restaurar sesión del admin con su token de refresco
    await client.auth.setSession(adminSession.refreshToken!);
  }

  @override
  Future<void> deleteJefe(String idJefe) async {
    // Desasignar de academia
    await client
        .from(Tables.academia)
        .update({Cols.idJefeAcademiaCol: null}).eq(Cols.idJefeAcademiaCol, idJefe);

    // Borrar de jefeacademia y usuario
    await client.from(Tables.jefeAcademia).delete().eq(Cols.idJefeAcademiaCol, idJefe);

    await client.from(Tables.usuario).delete().eq(Cols.idUsuario, idJefe);

    // Nota: la cuenta de Auth queda huérfana pero sin acceso
    // ya que no hay registro en jefeacademia ni usuario.
  }
}
