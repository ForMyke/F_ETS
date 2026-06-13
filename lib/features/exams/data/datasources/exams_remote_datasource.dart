import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:etsAndroid/core/constants/api_endpoints.dart';
import 'package:etsAndroid/features/exams/domain/entities/exam_admin.dart';
import 'package:etsAndroid/features/exams/data/models/exam_admin_model.dart';

export 'package:etsAndroid/features/exams/domain/entities/exam_admin.dart' show ExamListItem, ExamFormData;

abstract class ExamsRemoteDataSource {
  Future<List<ExamListItem>> getExams();
  Future<ExamFormData> getFormData(String? carreraId, String? planId, String? semestre);
  Future<void> createExam({
    required String carreraeMateriaId,
    required String salonId,
    required String periodoId,
    required String jefeId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  });
  Future<void> updateExam({
    required String id,
    required String carreraMateriaId,
    required String salonId,
    required String periodoId,
    required String jefeId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  });
  Future<void> deleteExam(String id);
}

class ExamsRemoteDataSourceImpl implements ExamsRemoteDataSource {
  final SupabaseClient client;

  const ExamsRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ExamListItem>> getExams() async {
    final response = await client.from(Tables.ets).select('''
      id_ets,
      fechahorainicio,
      fechahorafin,
      turno,
      estado,
      id_periodoets,
      id_salon,
      id_jefeacademia,
      id_carrera_materia,
      salon (
        codigo,
        edificio ( numero )
      ),
      carrera_materia (
        id_carrera,
        id_plan,
        semestre,
        materia ( nombre ),
        carrera ( acronimo )
      ),
      jefeacademia (
        usuario ( nombre, apellidopaterno, apellidomaterno )
      )
    ''').order(Cols.fechaHoraInicio, ascending: true);

    return response
        .map((e) => ExamListItemModel.fromJson(e))
        .toList();
  }

  @override
  Future<ExamFormData> getFormData(
      String? carreraId,
      String? planId,
      String? semestre,
      ) async {
    final carrerasRes = await client
        .from(Tables.carrera)
        .select('id_carrera, nombre, acronimo')
        .eq(Cols.activo, true);

    List<Map<String, dynamic>> planesRes = [];
    if (carreraId != null) {
      final raw = await client
          .from(Tables.carreraMateria)
          .select('planestudios ( id_plan, nombre )')
          .eq(Cols.idCarrera, carreraId);
      final seen = <String>{};
      for (final r in raw) {
        final p = r[Tables.planEstudios] as Map<String, dynamic>;
        if (seen.add(p[Cols.idPlan] as String)) planesRes.add(p);
      }
    }

    List<Map<String, dynamic>> materiasRes = [];
    if (carreraId != null && planId != null && semestre != null) {
      materiasRes = await client
          .from(Tables.carreraMateria)
          .select('id_carrera_materia, materia ( nombre )')
          .eq(Cols.idCarrera, carreraId)
          .eq(Cols.idPlan, planId)
          .eq(Cols.semestre, int.parse(semestre));
    }

    final salonesRes = await client
        .from(Tables.salon)
        .select('id_salon, codigo, edificio ( numero )');

    final periodosRes = await client
        .from(Tables.periodoEts)
        .select('id_periodoets, nombre');

    final jefesRes = await client.from(Tables.jefeAcademia).select('''
      id_jefeacademia,
      usuario ( nombre, apellidopaterno, apellidomaterno )
    ''');

    return ExamFormData(
      carreras: List<Map<String, dynamic>>.from(carrerasRes),
      planes: planesRes,
      materias: List<Map<String, dynamic>>.from(materiasRes),
      salones: List<Map<String, dynamic>>.from(salonesRes),
      periodos: List<Map<String, dynamic>>.from(periodosRes),
      jefes: List<Map<String, dynamic>>.from(jefesRes),
    );
  }

  @override
  Future<void> createExam({
    required String carreraeMateriaId,
    required String salonId,
    required String periodoId,
    required String jefeId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    final turno =
        fechaInicio.hour < 14 ? ColValues.turnoMatutino : ColValues.turnoVespertino;
    await client.from(Tables.ets).insert({
      Cols.idEts: const Uuid().v4(),
      Cols.fechaHoraInicio: fechaInicio.toIso8601String(),
      Cols.fechaHoraFin: fechaFin.toIso8601String(),
      Cols.estado: ColValues.estadoActivo,
      Cols.turno: turno,
      Cols.idPeriodoEts: periodoId,
      Cols.idSalon: salonId,
      Cols.idCarreraMateria: carreraeMateriaId,
      Cols.idJefeAcademia: jefeId,
    });
  }

  @override
  Future<void> updateExam({
    required String id,
    required String carreraMateriaId,
    required String salonId,
    required String periodoId,
    required String jefeId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    final turno =
        fechaInicio.hour < 14 ? ColValues.turnoMatutino : ColValues.turnoVespertino;
    await client.from(Tables.ets).update({
      Cols.fechaHoraInicio: fechaInicio.toIso8601String(),
      Cols.fechaHoraFin: fechaFin.toIso8601String(),
      Cols.turno: turno,
      Cols.idPeriodoEts: periodoId,
      Cols.idSalon: salonId,
      Cols.idCarreraMateria: carreraMateriaId,
      Cols.idJefeAcademia: jefeId,
    }).eq(Cols.idEts, id);
  }

  @override
  Future<void> deleteExam(String id) async {
    await client.from(Tables.ets).delete().eq(Cols.idEts, id);
  }
}