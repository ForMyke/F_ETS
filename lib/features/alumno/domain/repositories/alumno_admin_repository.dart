import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/alumno/domain/entities/alumno_admin_item.dart';

abstract class AlumnosAdminRepository {
  Future<Either<Failure, List<AlumnoAdminItem>>> getAlumnos();

  Future<Either<Failure, void>> createAlumno({
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String correo,
    required String boleta,
    required String password,
    required String idCarrera,
    required String idPlan,
  });

  Future<Either<Failure, void>> toggleActivo({
    required String idAlumno,
    required bool activo,
  });

  Future<Either<Failure, void>> deleteAlumno(String idAlumno);
}
