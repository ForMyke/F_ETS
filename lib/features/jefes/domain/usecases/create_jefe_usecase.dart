import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/jefes/domain/repositories/jefes_admin_repository.dart';

class CreateJefeParams extends Equatable {
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String password;
  final String idAcademia;

  const CreateJefeParams({
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.password,
    required this.idAcademia,
  });

  @override
  List<Object?> get props =>
      [nombre, apellidoPaterno, apellidoMaterno, correo, idAcademia];
}

class CreateJefeUseCase implements UseCase<void, CreateJefeParams> {
  final JefesAdminRepository repository;
  const CreateJefeUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateJefeParams params) =>
      repository.createJefe(
        nombre: params.nombre,
        apellidoPaterno: params.apellidoPaterno,
        apellidoMaterno: params.apellidoMaterno,
        correo: params.correo,
        password: params.password,
        idAcademia: params.idAcademia,
      );
}
