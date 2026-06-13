import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etsAndroid/core/constants/api_endpoints.dart';
import 'package:etsAndroid/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:etsAndroid/features/dashboard/data/models/dashboard_stats_model.dart';

export 'package:etsAndroid/features/dashboard/domain/entities/dashboard_stats.dart' show DashboardStats;

abstract class DashboardRemoteDataSource {
  Future<DashboardStats> getStats();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final SupabaseClient client;

  const DashboardRemoteDataSourceImpl({required this.client});

  @override
  Future<DashboardStats> getStats() async {
    final examsResponse = await client
        .from('ets')
        .select('''
          id_ets,
          fechahorainicio,
          id_salon,
          id_periodoets,
          carrera_materia (
            carrera (
              acronimo
            )
          )
        ''')
        .eq('estado', 'activo');

    final periodoResponse = await client
        .from('periodoets')
        .select('nombre')
        .eq('estado', 'activo')
        .limit(1)
        .single();

    final Map<String, int> byCarrera = {};
    final Set<String> salones = {};
    DateTime? proximo;
    final now = DateTime.now();

    for (final exam in examsResponse) {
      final acronimo = exam['carrera_materia']['carrera']['acronimo'] as String;
      byCarrera[acronimo] = (byCarrera[acronimo] ?? 0) + 1;

      salones.add(exam['id_salon'] as String);

      final fecha = DateTime.parse(exam['fechahorainicio'] as String);
      if (fecha.isAfter(now)) {
        if (proximo == null || fecha.isBefore(proximo)) {
          proximo = fecha;
        }
      }
    }

    return DashboardStatsModel(
      totalExams: examsResponse.length,
      periodoNombre: periodoResponse['nombre'] as String,
      examsByCarrera: byCarrera,
      proximoExamen: proximo,
      salonesEnUso: salones.length,
    );
  }
}