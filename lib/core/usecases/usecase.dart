import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';

abstract class UseCase<Output, Params> {
  Future<Either<Failure, Output>> call(Params params);
}

class NoParams {}