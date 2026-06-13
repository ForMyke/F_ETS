import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/jefe/domain/repositories/jefe_repository.dart';

class GuardarCalificacionParams extends Equatable {
  final String idInscripcion;
  final double calificacion;

  const GuardarCalificacionParams({
    required this.idInscripcion,
    required this.calificacion,
  });

  @override
  List<Object?> get props => [idInscripcion, calificacion];
}

class GuardarCalificacionUseCase
    implements UseCase<void, GuardarCalificacionParams> {
  final JefeRepository repository;
  const GuardarCalificacionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(GuardarCalificacionParams params) =>
      repository.guardarCalificacion(
        idInscripcion: params.idInscripcion,
        calificacion: params.calificacion,
      );
}
