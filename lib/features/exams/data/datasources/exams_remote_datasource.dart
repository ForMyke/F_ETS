import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ExamFormData {
  final List<Map<String, dynamic>> carreras;
  final List<Map<String, dynamic>> planes;
  final List<Map<String, dynamic>> materias;
  final List<Map<String, dynamic>> salones;
  final List<Map<String, dynamic>> periodos;
  final List<Map<String, dynamic>> jefes;

  const ExamFormData({
    required this.carreras,
    required this.planes,
    required this.materias,
    required this.salones,
    required this.periodos,
    required this.jefes,
  });
}

class ExamListItem {
  final String id;
  final String materia;
  final String carrera;
  final String salon;
  final String salonId;
  final String edificio;
  final String turno;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String estado;
  final String periodo;
  final String profesor;
  final String jefeId;
  final String carreraMateriaId;
  final String carreraId;
  final String planId;
  final int semestre;

  const ExamListItem({
    required this.id,
    required this.materia,
    required this.carrera,
    required this.salon,
    required this.salonId,
    required this.edificio,
    required this.turno,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.periodo,
    required this.profesor,
    required this.jefeId,
    required this.carreraMateriaId,
    required this.carreraId,
    required this.planId,
    required this.semestre,
  });
}

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
    final response = await client.from('ets').select('''
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
    ''').order('fechahorainicio', ascending: true);

    return response.map((e) {
      final salon = e['salon'] as Map<String, dynamic>;
      final cm = e['carrera_materia'] as Map<String, dynamic>;
      final jefe = e['jefeacademia'] as Map<String, dynamic>;
      final usuario = jefe['usuario'] as Map<String, dynamic>;
      return ExamListItem(
        id: e['id_ets'] as String,
        materia: cm['materia']['nombre'] as String,
        carrera: cm['carrera']['acronimo'] as String,
        salon: salon['codigo'] as String,
        salonId: e['id_salon'] as String,
        edificio: salon['edificio']['numero'] as String,
        turno: e['turno'] as String? ?? '',
        fechaInicio: DateTime.parse(e['fechahorainicio'] as String),
        fechaFin: DateTime.parse(e['fechahorafin'] as String),
        estado: e['estado'] as String,
        periodo: e['id_periodoets'] as String,
        profesor: '${usuario['nombre']} ${usuario['apellidopaterno']} ${usuario['apellidomaterno']}',
        jefeId: e['id_jefeacademia'] as String,
        carreraMateriaId: e['id_carrera_materia'] as String,
        carreraId: cm['id_carrera'] as String,
        planId: cm['id_plan'] as String,
        semestre: cm['semestre'] as int,
      );
    }).toList();
  }

  @override
  Future<ExamFormData> getFormData(
      String? carreraId,
      String? planId,
      String? semestre,
      ) async {
    final carrerasRes = await client
        .from('carrera')
        .select('id_carrera, nombre, acronimo')
        .eq('activo', true);

    List<Map<String, dynamic>> planesRes = [];
    if (carreraId != null) {
      final raw = await client
          .from('carrera_materia')
          .select('planestudios ( id_plan, nombre )')
          .eq('id_carrera', carreraId);
      final seen = <String>{};
      for (final r in raw) {
        final p = r['planestudios'] as Map<String, dynamic>;
        if (seen.add(p['id_plan'] as String)) planesRes.add(p);
      }
    }

    List<Map<String, dynamic>> materiasRes = [];
    if (carreraId != null && planId != null && semestre != null) {
      materiasRes = await client
          .from('carrera_materia')
          .select('id_carrera_materia, materia ( nombre )')
          .eq('id_carrera', carreraId)
          .eq('id_plan', planId)
          .eq('semestre', int.parse(semestre));
    }

    final salonesRes = await client
        .from('salon')
        .select('id_salon, codigo, edificio ( numero )');

    final periodosRes = await client
        .from('periodoets')
        .select('id_periodoets, nombre');

    final jefesRes = await client.from('jefeacademia').select('''
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
    final turno = fechaInicio.hour < 14 ? 'Matutino' : 'Vespertino';
    await client.from('ets').insert({
      'id_ets': const Uuid().v4(),
      'fechahorainicio': fechaInicio.toIso8601String(),
      'fechahorafin': fechaFin.toIso8601String(),
      'estado': 'activo',
      'turno': turno,
      'id_periodoets': periodoId,
      'id_salon': salonId,
      'id_carrera_materia': carreraeMateriaId,
      'id_jefeacademia': jefeId,
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
    final turno = fechaInicio.hour < 14 ? 'Matutino' : 'Vespertino';
    await client.from('ets').update({
      'fechahorainicio': fechaInicio.toIso8601String(),
      'fechahorafin': fechaFin.toIso8601String(),
      'turno': turno,
      'id_periodoets': periodoId,
      'id_salon': salonId,
      'id_carrera_materia': carreraMateriaId,
      'id_jefeacademia': jefeId,
    }).eq('id_ets', id);
  }

  @override
  Future<void> deleteExam(String id) async {
    await client.from('ets').delete().eq('id_ets', id);
  }
}