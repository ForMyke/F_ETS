import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/jefe/domain/entities/jefe_profile.dart';
import 'package:etsAndroid/features/jefe/domain/entities/ets_de_jefe_item.dart';
import 'package:etsAndroid/features/jefe/domain/entities/alumno_inscrito_item.dart';
import 'package:etsAndroid/features/jefe/domain/repositories/jefe_repository.dart';
import 'package:etsAndroid/features/jefe/data/datasources/jefe_remote_datasource.dart';

class JefeRepositoryImpl implements JefeRepository {
  final JefeRemoteDataSource remoteDataSource;

  const JefeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, JefeProfile>> login({
    required String correo,
    required String password,
  }) async {
    try {
      final profile =
          await remoteDataSource.login(correo: correo, password: password);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Error al cerrar sesión.'));
    }
  }

  @override
  Future<Either<Failure, List<EtsDeJefeItem>>> getEtsDeJefe(
      String idJefe) async {
    try {
      final items = await remoteDataSource.getEtsDeJefe(idJefe);
      return Right(items);
    } catch (_) {
      return const Left(ServerFailure('Error al cargar los exámenes.'));
    }
  }

  @override
  Future<Either<Failure, List<AlumnoInscritoItem>>> getAlumnosInscritos(
      String idEts) async {
    try {
      final items = await remoteDataSource.getAlumnosInscritos(idEts);
      return Right(items);
    } catch (_) {
      return const Left(ServerFailure('Error al cargar alumnos inscritos.'));
    }
  }

  @override
  Future<Either<Failure, void>> guardarCalificacion({
    required String idInscripcion,
    required double calificacion,
  }) async {
    try {
      await remoteDataSource.guardarCalificacion(
        idInscripcion: idInscripcion,
        calificacion: calificacion,
      );
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Error al guardar la calificación.'));
    }
  }
}
