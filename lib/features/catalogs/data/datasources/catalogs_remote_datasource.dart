import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etsAndroid/core/constants/api_endpoints.dart';
import 'package:uuid/uuid.dart';

class CarreraItem {
  final String id;
  final String nombre;
  final String acronimo;
  final bool activo;

  const CarreraItem({
    required this.id,
    required this.nombre,
    required this.acronimo,
    required this.activo,
  });
}

class EdificioItem {
  final String id;
  final String numero;

  const EdificioItem({required this.id, required this.numero});
}

class SalonItem {
  final String id;
  final String codigo;
  final String piso;
  final String edificioId;
  final String edificioNumero;

  const SalonItem({
    required this.id,
    required this.codigo,
    required this.piso,
    required this.edificioId,
    required this.edificioNumero,
  });
}

abstract class CatalogsRemoteDataSource {
  Future<List<CarreraItem>> getCarreras();
  Future<void> createCarrera({required String nombre, required String acronimo});
  Future<void> updateCarrera({required String id, required String nombre, required String acronimo, required bool activo});
  Future<void> deleteCarrera(String id);

  Future<List<EdificioItem>> getEdificios();
  Future<void> createEdificio({required String numero});
  Future<void> updateEdificio({required String id, required String numero});
  Future<void> deleteEdificio(String id);

  Future<List<SalonItem>> getSalones();
  Future<void> createSalon({required String codigo, required String piso, required String edificioId});
  Future<void> updateSalon({required String id, required String codigo, required String piso, required String edificioId});
  Future<void> deleteSalon(String id);
}

class CatalogsRemoteDataSourceImpl implements CatalogsRemoteDataSource {
  final SupabaseClient client;

  const CatalogsRemoteDataSourceImpl({required this.client});

  // Carreras
  @override
  Future<List<CarreraItem>> getCarreras() async {
    final res = await client.from(Tables.carrera).select('id_carrera, nombre, acronimo, activo');
    return res.map((e) => CarreraItem(
      id: e['id_carrera'] as String,
      nombre: e['nombre'] as String,
      acronimo: e['acronimo'] as String,
      activo: e['activo'] as bool,
    )).toList();
  }

  @override
  Future<void> createCarrera({required String nombre, required String acronimo}) async {
    await client.from(Tables.carrera).insert({
      Cols.idCarreraCol: const Uuid().v4(),
      Cols.nombre: nombre,
      Cols.acronimo: acronimo,
      Cols.activo: true,
    });
  }

  @override
  Future<void> updateCarrera({required String id, required String nombre, required String acronimo, required bool activo}) async {
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
    final res = await client.from(Tables.edificio).select('id_edificio, numero');
    return res.map((e) => EdificioItem(
      id: e['id_edificio'] as String,
      numero: e['numero'] as String,
    )).toList();
  }

  @override
  Future<void> createEdificio({required String numero}) async {
    await client.from(Tables.edificio).insert({
      Cols.idEdificio: const Uuid().v4(),
      Cols.numero: numero,
    });
  }

  @override
  Future<void> updateEdificio({required String id, required String numero}) async {
    await client.from(Tables.edificio).update({Cols.numero: numero}).eq(Cols.idEdificio, id);
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
    return res.map((e) => SalonItem(
      id: e['id_salon'] as String,
      codigo: e['codigo'] as String,
      piso: e['piso'] as String,
      edificioId: e['id_edificio'] as String,
      edificioNumero: e['edificio']['numero'] as String,
    )).toList();
  }

  @override
  Future<void> createSalon({required String codigo, required String piso, required String edificioId}) async {
    await client.from(Tables.salon).insert({
      Cols.idSalonCol: const Uuid().v4(),
      Cols.codigo: codigo,
      Cols.piso: piso,
      Cols.idEdificio: edificioId,
    });
  }

  @override
  Future<void> updateSalon({required String id, required String codigo, required String piso, required String edificioId}) async {
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