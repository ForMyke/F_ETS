import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/jefes/domain/entities/jefe_admin_item.dart';
import 'package:etsAndroid/features/jefes/domain/repositories/jefes_admin_repository.dart';

class GetJefesUseCase implements UseCase<List<JefeAdminItem>, NoParams> {
  final JefesAdminRepository repository;
  const GetJefesUseCase(this.repository);

  @override
  Future<Either<Failure, List<JefeAdminItem>>> call(NoParams params) =>
      repository.getJefes();
}
