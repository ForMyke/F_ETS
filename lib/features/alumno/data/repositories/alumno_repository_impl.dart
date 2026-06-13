import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/alumno/domain/entities/alumno_profile.dart';
import 'package:etsAndroid/features/alumno/domain/entities/inscripcion_item.dart';
import 'package:etsAndroid/features/alumno/domain/repositories/alumno_repository.dart';
import 'package:etsAndroid/features/alumno/data/datasources/alumno_remote_datasource.dart';
import 'package:etsAndroid/features/search/domain/entities/exam.dart';

class AlumnoRepositoryImpl implements AlumnoRepository {
  final AlumnoRemoteDataSource remoteDataSource;

  const AlumnoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> register({
    required String boleta,
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String correo,
    required String password,
    required String idCarrera,
    required String idPlan,
  }) async {
    try {
      await remoteDataSource.register(
        boleta: boleta,
        nombre: nombre,
        apellidoPaterno: apellidoPaterno,
        apellidoMaterno: apellidoMaterno,
        correo: correo,
        password: password,
        idCarrera: idCarrera,
        idPlan: idPlan,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AlumnoProfile>> login({
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
  Future<Either<Failure, AlumnoProfile?>> getPerfilActual() async {
    try {
      final profile = await remoteDataSource.getPerfilActual();
      return Right(profile);
    } catch (_) {
      return const Left(ServerFailure('Error al obtener perfil.'));
    }
  }

  @override
  Future<Either<Failure, List<Exam>>> getExamsDisponibles({
    required String idCarrera,
  }) async {
    try {
      final models =
          await remoteDataSource.getExamsDisponibles(idCarrera: idCarrera);
      final List<Exam> exams = models;
      return Right(exams);
    } catch (_) {
      return const Left(ServerFailure('Error al cargar exámenes.'));
    }
  }

  @override
  Future<Either<Failure, bool>> yaInscrito({
    required String idAlumno,
    required String idEts,
  }) async {
    try {
      final result =
          await remoteDataSource.yaInscrito(idAlumno: idAlumno, idEts: idEts);
      return Right(result);
    } catch (_) {
      return const Left(ServerFailure('Error al verificar inscripción.'));
    }
  }

  @override
  Future<Either<Failure, void>> inscribirse({
    required String idAlumno,
    required String idEts,
  }) async {
    try {
      await remoteDataSource.inscribirse(idAlumno: idAlumno, idEts: idEts);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InscripcionItem>>> getMisInscripciones(
      String idAlumno) async {
    try {
      final items = await remoteDataSource.getMisInscripciones(idAlumno);
      return Right(items);
    } catch (_) {
      return const Left(ServerFailure('Error al cargar inscripciones.'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getCarreras() async {
    try {
      final res = await remoteDataSource.getCarreras();
      return Right(res);
    } catch (_) {
      return const Left(ServerFailure('Error al cargar carreras.'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getPlanes() async {
    try {
      final res = await remoteDataSource.getPlanes();
      return Right(res);
    } catch (_) {
      return const Left(ServerFailure('Error al cargar planes.'));
    }
  }
}
