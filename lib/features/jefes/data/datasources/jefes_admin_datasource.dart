import 'package:supabase_flutter/supabase_flutter.dart';

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
    final res = await client.from('jefeacademia').select('''
      id_jefeacademia,
      usuario ( nombre, apellidopaterno, apellidomaterno, correo )
    ''');

    // También obtenemos las academias para saber a cuál pertenece cada jefe
    final academias = await client
        .from('academia')
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
        await client.from('academia').select('id_academia, nombre, acronimo');
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
    await client.from('usuario').insert({
      'id_usuario': uid,
      'correo': correo,
      'activo': true,
      'passwordhash': '',
      'nombre': nombre,
      'apellidopaterno': apellidoPaterno,
      'apellidomaterno': apellidoMaterno,
    });

    await client.from('jefeacademia').insert({
      'id_jefeacademia': uid,
      'id_usuario': uid,
    });

    await client
        .from('academia')
        .update({'id_jefeacademia': uid}).eq('id_academia', idAcademia);

    // 3. Restaurar sesión del admin con su token de refresco
    await client.auth.setSession(adminSession.refreshToken!);
  }

  @override
  Future<void> deleteJefe(String idJefe) async {
    // Desasignar de academia
    await client
        .from('academia')
        .update({'id_jefeacademia': null}).eq('id_jefeacademia', idJefe);

    // Borrar de jefeacademia y usuario
    await client.from('jefeacademia').delete().eq('id_jefeacademia', idJefe);

    await client.from('usuario').delete().eq('id_usuario', idJefe);

    // Nota: la cuenta de Auth queda huérfana pero sin acceso
    // ya que no hay registro en jefeacademia ni usuario.
  }
}
