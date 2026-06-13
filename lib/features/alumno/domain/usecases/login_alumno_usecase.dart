import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/alumno/domain/entities/alumno_profile.dart';
import 'package:etsAndroid/features/alumno/domain/repositories/alumno_repository.dart';

class LoginAlumnoParams extends Equatable {
  final String correo;
  final String password;

  const LoginAlumnoParams({required this.correo, required this.password});

  @override
  List<Object?> get props => [correo, password];
}

class LoginAlumnoUseCase implements UseCase<AlumnoProfile, LoginAlumnoParams> {
  final AlumnoRepository repository;
  const LoginAlumnoUseCase(this.repository);

  @override
  Future<Either<Failure, AlumnoProfile>> call(LoginAlumnoParams params) =>
      repository.login(correo: params.correo, password: params.password);
}
