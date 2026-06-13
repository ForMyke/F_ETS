import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/alumno/domain/repositories/alumno_repository.dart';
import 'package:etsAndroid/features/search/domain/entities/exam.dart';

class GetExamsDisponiblesParams extends Equatable {
  final String idCarrera;
  const GetExamsDisponiblesParams({required this.idCarrera});

  @override
  List<Object?> get props => [idCarrera];
}

class GetExamsDisponiblesUseCase
    implements UseCase<List<Exam>, GetExamsDisponiblesParams> {
  final AlumnoRepository repository;
  const GetExamsDisponiblesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Exam>>> call(
          GetExamsDisponiblesParams params) =>
      repository.getExamsDisponibles(idCarrera: params.idCarrera);
}
