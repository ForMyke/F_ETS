import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:etsAndroid/core/constants/api_endpoints.dart';
import 'package:etsAndroid/features/catalogs/domain/entities/carrera_item.dart';
import 'package:etsAndroid/features/catalogs/domain/entities/edificio_item.dart';
import 'package:etsAndroid/features/catalogs/domain/entities/salon_item.dart';
import 'package:etsAndroid/features/catalogs/data/models/carrera_model.dart';
import 'package:etsAndroid/features/catalogs/data/models/edificio_model.dart';
import 'package:etsAndroid/features/catalogs/data/models/salon_model.dart';

export 'package:etsAndroid/features/catalogs/domain/entities/carrera_item.dart';
export 'package:etsAndroid/features/catalogs/domain/entities/edificio_item.dart';
export 'package:etsAndroid/features/catalogs/domain/entities/salon_item.dart';

abstract class CatalogsRemoteDataSource {
  Future<List<CarreraItem>> getCarreras();
  Future<void> createCarrera(
      {required String nombre, required String acronimo});
  Future<void> updateCarrera(
      {required String id,
      required String nombre,
      required String acronimo,
      required bool activo});
  Future<void> deleteCarrera(String id);

  Future<List<EdificioItem>> getEdificios();
  Future<void> createEdificio({required String numero});
  Future<void> updateEdificio({required String id, required String numero});
  Future<void> deleteEdificio(String id);

  Future<List<SalonItem>> getSalones();
  Future<void> createSalon(
      {required String codigo,
      required String piso,
      required String edificioId});
  Future<void> updateSalon(
      {required String id,
      required String codigo,
      required String piso,
      required String edificioId});
  Future<void> deleteSalon(String id);
}

class CatalogsRemoteDataSourceImpl implements CatalogsRemoteDataSource {
  final SupabaseClient client;

  const CatalogsRemoteDataSourceImpl({required this.client});

  // Carreras
  @override
  Future<List<CarreraItem>> getCarreras() async {
    final res = await client
        .from(Tables.carrera)
        .select('id_carrera, nombre, acronimo, activo');
    return res
        .map((e) => CarreraModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> createCarrera(
      {required String nombre, required String acronimo}) async {
    await client.from(Tables.carrera).insert({
      Cols.idCarreraCol: const Uuid().v4(),
      Cols.nombre: nombre,
      Cols.acronimo: acronimo,
      Cols.activo: true,
    });
  }

  @override
  Future<void> updateCarrera(
      {required String id,
      required String nombre,
      required String acronimo,
      required bool activo}) async {
    await client.from(Tables.carrera).update({
      Cols.nombre: nombre,
      Cols.acronimo: acronimo,
      Cols.activo: activo,
    }).eq(Cols.idCarreraCol, id);
  }

  @override
  Future<void> deleteCarrera(String id) async {
    await client.from(Tables.carrera).delete().eq(Cols.idCarreraCol, id);
  }

  // Edificios
  @override
  Future<List<EdificioItem>> getEdificios() async {
    final res =
        await client.from(Tables.edificio).select('id_edificio, numero');
    return res
        .map((e) => EdificioModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> createEdificio({required String numero}) async {
    await client.from(Tables.edificio).insert({
      Cols.idEdificio: const Uuid().v4(),
      Cols.numero: numero,
    });
  }

  @override
  Future<void> updateEdificio(
      {required String id, required String numero}) async {
    await client
        .from(Tables.edificio)
        .update({Cols.numero: numero}).eq(Cols.idEdificio, id);
  }

  @override
  Future<void> deleteEdificio(String id) async {
    await client.from(Tables.edificio).delete().eq(Cols.idEdificio, id);
  }

  // Salones
  @override
  Future<List<SalonItem>> getSalones() async {
    final res = await client.from(Tables.salon).select('''
      id_salon, codigo, piso, id_edificio,
      edificio ( numero )
    ''');
    return res
        .map((e) => SalonModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> createSalon(
      {required String codigo,
      required String piso,
      required String edificioId}) async {
    await client.from(Tables.salon).insert({
      Cols.idSalonCol: const Uuid().v4(),
      Cols.codigo: codigo,
      Cols.piso: piso,
      Cols.idEdificio: edificioId,
    });
  }

  @override
  Future<void> updateSalon(
      {required String id,
      required String codigo,
      required String piso,
      required String edificioId}) async {
    await client.from(Tables.salon).update({
      Cols.codigo: codigo,
      Cols.piso: piso,
      Cols.idEdificio: edificioId,
    }).eq(Cols.idSalonCol, id);
  }

  @override
  Future<void> deleteSalon(String id) async {
    await client.from(Tables.salon).delete().eq(Cols.idSalonCol, id);
  }
}
