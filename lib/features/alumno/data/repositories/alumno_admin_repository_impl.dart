import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/alumno/domain/repositories/alumno_admin_repository.dart';
import 'package:etsAndroid/features/alumno/data/datasources/alumno_admin_datasource.dart';

class AlumnosAdminRepositoryImpl implements AlumnosAdminRepository {
  final AlumnosAdminDataSource dataSource;

  const AlumnosAdminRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<AlumnoAdminItem>>> getAlumnos() async {
    try {
      return Right(await dataSource.getAlumnos());
    } catch (_) {
      return const Left(ServerFailure('Error al cargar los alumnos.'));
    }
  }

  @override
  Future<Either<Failure, void>> createAlumno({
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String correo,
    required String boleta,
    required String password,
    required String idCarrera,
    required String idPlan,
  }) async {
    try {
      await dataSource.createAlumno(
        nombre: nombre,
        apellidoPaterno: apellidoPaterno,
        apellidoMaterno: apellidoMaterno,
        correo: correo,
        boleta: boleta,
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
  Future<Either<Failure, void>> toggleActivo({
    required String idAlumno,
    required bool activo,
  }) async {
    try {
      await dataSource.toggleActivo(idAlumno: idAlumno, activo: activo);
      return const Right(null);
    } catch (_) {
      return const Left(
          ServerFailure('Error al actualizar el estado del alumno.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAlumno(String idAlumno) async {
    try {
      await dataSource.deleteAlumno(idAlumno);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Error al eliminar el alumno.'));
    }
  }
}
