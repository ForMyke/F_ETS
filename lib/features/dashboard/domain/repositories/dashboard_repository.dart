import 'package:dartz/dartz.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/dashboard/domain/entities/dashboard_stats.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardStats>> getStats();
}
