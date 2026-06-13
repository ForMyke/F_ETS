import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/auth/domain/entities/user.dart';
import 'package:etsAndroid/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase implements UseCase<User, LoginParams> {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) =>
      repository.login(email: params.email, password: params.password);
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}