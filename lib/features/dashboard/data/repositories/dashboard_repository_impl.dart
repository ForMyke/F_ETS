import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:etsAndroid/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:etsAndroid/features/dashboard/data/datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  const DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DashboardStats>> getStats() async {
    try {
      final stats = await remoteDataSource.getStats();
      return Right(stats);
    } catch (_) {
      return const Left(ServerFailure('Error al cargar el panel.'));
    }
  }
}
