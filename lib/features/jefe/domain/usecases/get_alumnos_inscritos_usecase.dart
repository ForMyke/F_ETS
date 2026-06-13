import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/jefe/domain/entities/alumno_inscrito_item.dart';
import 'package:etsAndroid/features/jefe/domain/repositories/jefe_repository.dart';

class GetAlumnosInscritosUseCase
    implements UseCase<List<AlumnoInscritoItem>, String> {
  final JefeRepository repository;
  const GetAlumnosInscritosUseCase(this.repository);

  @override
  Future<Either<Failure, List<AlumnoInscritoItem>>> call(String idEts) =>
      repository.getAlumnosInscritos(idEts);
}
