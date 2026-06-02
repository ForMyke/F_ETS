import 'dart:io';
import 'failures.dart';

class NetworkErrorHandler {
  NetworkErrorHandler._();

  static Failure handle(dynamic error) {
    if (error is SocketException) {
      return const NetworkFailure('Sin conexión a internet. Verifica tu red.');
    }

    if (error is HttpException) {
      return const NetworkFailure('Error de conexión. Intenta de nuevo.');
    }

    if (error.toString().contains('TimeoutException') ||
        error.toString().contains('timeout')) {
      return const ServerFailure(
          'La solicitud tardó demasiado. Intenta de nuevo.');
    }

    if (error is ServerFailure) return error;
    if (error is NetworkFailure) return error;
    if (error is CacheFailure) return error;
    if (error is InvalidCredentialsFailure) return error;

    return const ServerFailure('Ocurrió un error inesperado.');
  }

  static String messageFor(Failure failure) {
    if (failure is NetworkFailure) return failure.message;
    if (failure is ServerFailure) return failure.message;
    if (failure is InvalidCredentialsFailure) return failure.message;
    if (failure is CacheFailure) return failure.message;
    return 'Ocurrió un error inesperado.';
  }

  static NetworkErrorType typeFor(Failure failure) {
    if (failure is NetworkFailure) return NetworkErrorType.noConnection;
    if (failure is InvalidCredentialsFailure) return NetworkErrorType.auth;
    if (failure is ServerFailure) return NetworkErrorType.server;
    if (failure is CacheFailure) return NetworkErrorType.cache;
    return NetworkErrorType.unknown;
  }
}

enum NetworkErrorType {
  noConnection,
  timeout,
  server,
  auth,
  cache,
  unknown,
}
