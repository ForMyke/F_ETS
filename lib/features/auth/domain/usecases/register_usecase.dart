import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/auth/domain/entities/user.dart';
import 'package:etsAndroid/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<User, RegisterParams> {
  final AuthRepository repository;
  const RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) =>
      repository.register(
        name: params.name,
        email: params.email,
        password: params.password,
      );
}

class RegisterParams extends Equatable {
  final String name;
  final String email;
  final String password;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [name, email, password];
}
