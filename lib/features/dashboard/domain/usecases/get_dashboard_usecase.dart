import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/core/usecases/usecase.dart';
import 'package:etsAndroid/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:etsAndroid/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardUseCase implements UseCase<DashboardStats, NoParams> {
  final DashboardRepository repository;
  const GetDashboardUseCase(this.repository);

  @override
  Future<Either<Failure, DashboardStats>> call(NoParams params) =>
      repository.getStats();
}
