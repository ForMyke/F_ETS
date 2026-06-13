import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/alumno/domain/entities/alumno_profile.dart';
import 'package:etsAndroid/features/alumno/domain/entities/inscripcion_item.dart';
import 'package:etsAndroid/features/search/domain/entities/exam.dart';

abstract class AlumnoRepository {
  Future<Either<Failure, void>> register({
    required String boleta,
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String correo,
    required String password,
    required String idCarrera,
    required String idPlan,
  });

  Future<Either<Failure, AlumnoProfile>> login({
    required String correo,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, AlumnoProfile?>> getPerfilActual();

  Future<Either<Failure, List<Exam>>> getExamsDisponibles({
    required String idCarrera,
  });

  Future<Either<Failure, bool>> yaInscrito({
    required String idAlumno,
    required String idEts,
  });

  Future<Either<Failure, void>> inscribirse({
    required String idAlumno,
    required String idEts,
  });

  Future<Either<Failure, List<InscripcionItem>>> getMisInscripciones(
      String idAlumno);

  Future<Either<Failure, List<Map<String, dynamic>>>> getCarreras();

  Future<Either<Failure, List<Map<String, dynamic>>>> getPlanes();
}
