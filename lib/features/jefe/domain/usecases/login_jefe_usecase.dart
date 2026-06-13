import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/jefe/domain/entities/jefe_profile.dart';
import 'package:etsAndroid/features/jefe/domain/repositories/jefe_repository.dart';

class LoginJefeParams extends Equatable {
  final String correo;
  final String password;

  const LoginJefeParams({required this.correo, required this.password});

  @override
  List<Object?> get props => [correo, password];
}

class LoginJefeUseCase implements UseCase<JefeProfile, LoginJefeParams> {
  final JefeRepository repository;
  const LoginJefeUseCase(this.repository);

  @override
  Future<Either<Failure, JefeProfile>> call(LoginJefeParams params) =>
      repository.login(correo: params.correo, password: params.password);
}
