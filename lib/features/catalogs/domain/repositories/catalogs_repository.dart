import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/catalogs/domain/entities/carrera_item.dart';
import 'package:etsAndroid/features/catalogs/domain/entities/edificio_item.dart';
import 'package:etsAndroid/features/catalogs/domain/entities/salon_item.dart';

abstract class CatalogsRepository {
  // Carreras
  Future<Either<Failure, List<CarreraItem>>> getCarreras();
  Future<Either<Failure, void>> createCarrera(
      {required String nombre, required String acronimo});
  Future<Either<Failure, void>> updateCarrera(
      {required String id,
      required String nombre,
      required String acronimo,
      required bool activo});
  Future<Either<Failure, void>> deleteCarrera(String id);

  // Edificios
  Future<Either<Failure, List<EdificioItem>>> getEdificios();
  Future<Either<Failure, void>> createEdificio({required String numero});
  Future<Either<Failure, void>> updateEdificio(
      {required String id, required String numero});
  Future<Either<Failure, void>> deleteEdificio(String id);

  // Salones
  Future<Either<Failure, List<SalonItem>>> getSalones();
  Future<Either<Failure, void>> createSalon(
      {required String codigo,
      required String piso,
      required String edificioId});
  Future<Either<Failure, void>> updateSalon(
      {required String id,
      required String codigo,
      required String piso,
      required String edificioId});
  Future<Either<Failure, void>> deleteSalon(String id);
}
