import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error de servidor. Intenta de nuevo.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet.']);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([super.message = 'Correo o contraseña incorrectos.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error al acceder a datos locales.']);
}

class CachedExamsFailure extends Failure {
  final List<dynamic> exams;
  const CachedExamsFailure(this.exams) : super('Sin conexión. Mostrando datos guardados.');

  @override
  List<Object> get props => [message, exams];
}