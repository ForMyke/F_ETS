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
        .from(Tables.ets)
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
        .eq(Cols.estado, ColValues.estadoActivo);

    final periodoResponse = await client
        .from(Tables.periodoEts)
        .select(Cols.nombre)
        .eq(Cols.estado, ColValues.estadoActivo)
        .limit(1)
        .maybeSingle();

    final Map<String, int> byCarrera = {};
    final Set<String> salones = {};
    DateTime? proximo;
    final now = DateTime.now();

    for (final exam in examsResponse) {
      final acronimo = exam[Tables.carreraMateria][Tables.carrera]
          [Cols.acronimo] as String;
      byCarrera[acronimo] = (byCarrera[acronimo] ?? 0) + 1;

      salones.add(exam[Cols.idSalon] as String);

      final fecha = DateTime.parse(exam[Cols.fechaHoraInicio] as String);
      if (fecha.isAfter(now)) {
        if (proximo == null || fecha.isBefore(proximo)) {
          proximo = fecha;
        }
      }
    }

    return DashboardStatsModel(
      totalExams: examsResponse.length,
      periodoNombre: periodoResponse?[Cols.nombre] as String? ?? 'Sin periodo activo',
      examsByCarrera: byCarrera,
      proximoExamen: proximo,
      salonesEnUso: salones.length,
    );
  }
}