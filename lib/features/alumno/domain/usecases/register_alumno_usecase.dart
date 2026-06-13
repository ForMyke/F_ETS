import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/alumno/domain/repositories/alumno_repository.dart';

class RegisterAlumnoParams extends Equatable {
  final String boleta;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String password;
  final String idCarrera;
  final String idPlan;

  const RegisterAlumnoParams({
    required this.boleta,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.password,
    required this.idCarrera,
    required this.idPlan,
  });

  @override
  List<Object?> get props =>
      [boleta, nombre, apellidoPaterno, apellidoMaterno, correo, idCarrera, idPlan];
}

class RegisterAlumnoUseCase implements UseCase<void, RegisterAlumnoParams> {
  final AlumnoRepository repository;
  const RegisterAlumnoUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RegisterAlumnoParams params) =>
      repository.register(
        boleta: params.boleta,
        nombre: params.nombre,
        apellidoPaterno: params.apellidoPaterno,
        apellidoMaterno: params.apellidoMaterno,
        correo: params.correo,
        password: params.password,
        idCarrera: params.idCarrera,
        idPlan: params.idPlan,
      );
}
