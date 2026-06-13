import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etsAndroid/core/constants/api_endpoints.dart';
import 'package:etsAndroid/features/jefes/domain/entities/jefe_admin_item.dart';
import 'package:etsAndroid/features/jefes/domain/entities/academia_item.dart';
import 'package:etsAndroid/features/jefes/data/models/jefe_admin_model.dart';
import 'package:etsAndroid/features/jefes/data/models/academia_model.dart';

export 'package:etsAndroid/features/jefes/domain/entities/jefe_admin_item.dart';
export 'package:etsAndroid/features/jefes/domain/entities/academia_item.dart';

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

    final academias = await client
        .from(Tables.academia)
        .select('id_academia, nombre, id_jefeacademia');

    return (res as List).map((e) {
      final idJefe = e['id_jefeacademia'] as String;

      final academiaList = (academias as List)
          .where((a) => a['id_jefeacademia'] == idJefe)
          .toList();
      final academia = academiaList.isNotEmpty ? academiaList.first : null;

      return JefeAdminModel.fromJson(
        e as Map<String, dynamic>,
        idAcademia: academia?['id_academia'] as String?,
        nombreAcademia: academia?['nombre'] as String?,
      );
    }).toList();
  }

  @override
  Future<List<AcademiaItem>> getAcademias() async {
    final res = await client
        .from(Tables.academia)
        .select('id_academia, nombre, acronimo');
    return (res as List)
        .map((e) => AcademiaModel.fromJson(e as Map<String, dynamic>))
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
    final adminSession = client.auth.currentSession;
    final adminEmail = client.auth.currentUser?.email;
    if (adminSession == null || adminEmail == null) {
      throw Exception('No hay sesión de admin activa.');
    }

    final authRes = await client.auth.signUp(
      email: correo,
      password: password,
    );

    final uid = authRes.user?.id;
    if (uid == null) throw Exception('No se pudo crear la cuenta.');

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

    await client.auth.setSession(adminSession.refreshToken!);
  }

  @override
  Future<void> deleteJefe(String idJefe) async {
    await client
        .from(Tables.academia)
        .update({Cols.idJefeAcademiaCol: null}).eq(Cols.idJefeAcademiaCol, idJefe);

    await client.from(Tables.jefeAcademia).delete().eq(Cols.idJefeAcademiaCol, idJefe);

    await client.from(Tables.usuario).delete().eq(Cols.idUsuario, idJefe);
  }
}
