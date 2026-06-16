import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/alumno/domain/repositories/alumno_admin_repository.dart';

class CreateAlumnoParams extends Equatable {
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String boleta;
  final String password;
  final String idCarrera;
  final String idPlan;

  const CreateAlumnoParams({
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.boleta,
    required this.password,
    required this.idCarrera,
    required this.idPlan,
  });

  @override
  List<Object?> get props => [
        nombre,
        apellidoPaterno,
        apellidoMaterno,
        correo,
        boleta,
        idCarrera,
        idPlan
      ];
}

class CreateAlumnoUseCase implements UseCase<void, CreateAlumnoParams> {
  final AlumnosAdminRepository repository;
  const CreateAlumnoUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateAlumnoParams params) =>
      repository.createAlumno(
        nombre: params.nombre,
        apellidoPaterno: params.apellidoPaterno,
        apellidoMaterno: params.apellidoMaterno,
        correo: params.correo,
        boleta: params.boleta,
        password: params.password,
        idCarrera: params.idCarrera,
        idPlan: params.idPlan,
      );
}
