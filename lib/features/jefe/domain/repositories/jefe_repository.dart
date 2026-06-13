import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/jefe/domain/entities/jefe_profile.dart';
import 'package:etsAndroid/features/jefe/domain/entities/ets_de_jefe_item.dart';
import 'package:etsAndroid/features/jefe/domain/entities/alumno_inscrito_item.dart';

abstract class JefeRepository {
  Future<Either<Failure, JefeProfile>> login({
    required String correo,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, List<EtsDeJefeItem>>> getEtsDeJefe(String idJefe);

  Future<Either<Failure, List<AlumnoInscritoItem>>> getAlumnosInscritos(
      String idEts);

  Future<Either<Failure, void>> guardarCalificacion({
    required String idInscripcion,
    required double calificacion,
  });
}
