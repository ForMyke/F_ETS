import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase implements UseCase<void, ForgotPasswordParams> {
  final AuthRepository repository;
  const ForgotPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ForgotPasswordParams params) =>
      repository.forgotPassword(email: params.email);
}

class ForgotPasswordParams extends Equatable {
  final String email;
  const ForgotPasswordParams({required this.email});

  @override
  List<Object> get props => [email];
}
