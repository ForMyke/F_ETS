import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  /// Envía un email con el link de recuperación de contraseña.
  Future<Either<Failure, void>> forgotPassword({required String email});

  /// Actualiza la contraseña del usuario autenticado vía deep link de Supabase.
  Future<Either<Failure, void>> resetPassword({required String newPassword});
}
