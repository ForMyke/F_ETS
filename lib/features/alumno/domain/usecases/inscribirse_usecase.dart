import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/alumno/domain/repositories/alumno_repository.dart';

class InscribirseParams extends Equatable {
  final String idAlumno;
  final String idEts;
  const InscribirseParams({required this.idAlumno, required this.idEts});

  @override
  List<Object?> get props => [idAlumno, idEts];
}

class InscribirseUseCase implements UseCase<void, InscribirseParams> {
  final AlumnoRepository repository;
  const InscribirseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(InscribirseParams params) =>
      repository.inscribirse(
          idAlumno: params.idAlumno, idEts: params.idEts);
}
