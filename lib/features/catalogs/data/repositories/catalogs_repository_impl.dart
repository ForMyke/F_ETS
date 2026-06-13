import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/catalogs/domain/entities/carrera_item.dart';
import 'package:etsAndroid/features/catalogs/domain/entities/edificio_item.dart';
import 'package:etsAndroid/features/catalogs/domain/entities/salon_item.dart';
import 'package:etsAndroid/features/catalogs/domain/repositories/catalogs_repository.dart';
import 'package:etsAndroid/features/catalogs/data/datasources/catalogs_remote_datasource.dart';

class CatalogsRepositoryImpl implements CatalogsRepository {
  final CatalogsRemoteDataSource remoteDataSource;

  const CatalogsRepositoryImpl({required this.remoteDataSource});

  // ── Carreras ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<CarreraItem>>> getCarreras() async {
    try {
      return Right(await remoteDataSource.getCarreras());
    } catch (_) {
      return const Left(ServerFailure('Error al cargar carreras.'));
    }
  }

  @override
  Future<Either<Failure, void>> createCarrera(
      {required String nombre, required String acronimo}) async {
    try {
      await remoteDataSource.createCarrera(nombre: nombre, acronimo: acronimo);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCarrera(
      {required String id,
      required String nombre,
      required String acronimo,
      required bool activo}) async {
    try {
      await remoteDataSource.updateCarrera(
          id: id, nombre: nombre, acronimo: acronimo, activo: activo);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Error al actualizar carrera.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCarrera(String id) async {
    try {
      await remoteDataSource.deleteCarrera(id);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Error al eliminar carrera.'));
    }
  }

  // ── Edificios ─────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<EdificioItem>>> getEdificios() async {
    try {
      return Right(await remoteDataSource.getEdificios());
    } catch (_) {
      return const Left(ServerFailure('Error al cargar edificios.'));
    }
  }

  @override
  Future<Either<Failure, void>> createEdificio(
      {required String numero}) async {
    try {
      await remoteDataSource.createEdificio(numero: numero);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Error al crear edificio.'));
    }
  }

  @override
  Future<Either<Failure, void>> updateEdificio(
      {required String id, required String numero}) async {
    try {
      await remoteDataSource.updateEdificio(id: id, numero: numero);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Error al actualizar edificio.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEdificio(String id) async {
    try {
      await remoteDataSource.deleteEdificio(id);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Error al eliminar edificio.'));
    }
  }

  // ── Salones ───────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<SalonItem>>> getSalones() async {
    try {
      return Right(await remoteDataSource.getSalones());
    } catch (_) {
      return const Left(ServerFailure('Error al cargar salones.'));
    }
  }

  @override
  Future<Either<Failure, void>> createSalon(
      {required String codigo,
      required String piso,
      required String edificioId}) async {
    try {
      await remoteDataSource.createSalon(
          codigo: codigo, piso: piso, edificioId: edificioId);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Error al crear salón.'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSalon(
      {required String id,
      required String codigo,
      required String piso,
      required String edificioId}) async {
    try {
      await remoteDataSource.updateSalon(
          id: id, codigo: codigo, piso: piso, edificioId: edificioId);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Error al actualizar salón.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSalon(String id) async {
    try {
      await remoteDataSource.deleteSalon(id);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Error al eliminar salón.'));
    }
  }
}
