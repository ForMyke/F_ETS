import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/jefe/domain/entities/ets_de_jefe_item.dart';
import 'package:etsAndroid/features/jefe/domain/repositories/jefe_repository.dart';

class GetEtsDeJefeUseCase implements UseCase<List<EtsDeJefeItem>, String> {
  final JefeRepository repository;
  const GetEtsDeJefeUseCase(this.repository);

  @override
  Future<Either<Failure, List<EtsDeJefeItem>>> call(String idJefe) =>
      repository.getEtsDeJefe(idJefe);
}
