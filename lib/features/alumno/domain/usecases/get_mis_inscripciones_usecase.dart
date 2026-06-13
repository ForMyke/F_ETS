import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/alumno/domain/entities/inscripcion_item.dart';
import 'package:etsAndroid/features/alumno/domain/repositories/alumno_repository.dart';

class GetMisInscripcionesUseCase
    implements UseCase<List<InscripcionItem>, String> {
  final AlumnoRepository repository;
  const GetMisInscripcionesUseCase(this.repository);

  @override
  Future<Either<Failure, List<InscripcionItem>>> call(String idAlumno) =>
      repository.getMisInscripciones(idAlumno);
}
