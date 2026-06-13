import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/catalogs/domain/entities/salon_item.dart';
import 'package:etsAndroid/features/catalogs/domain/repositories/catalogs_repository.dart';

class GetSalonesUseCase implements UseCase<List<SalonItem>, NoParams> {
  final CatalogsRepository repository;
  const GetSalonesUseCase(this.repository);

  @override
  Future<Either<Failure, List<SalonItem>>> call(NoParams params) =>
      repository.getSalones();
}
