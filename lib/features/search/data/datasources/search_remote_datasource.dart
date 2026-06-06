import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exam_model.dart';

abstract class SearchRemoteDataSource {
  Future<List<ExamModel>> getExams({
    String? carrera,
    int? semestre,
    String? plan,
    String? materia,
  });

  Future<List<String>> getCarreras();
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final SupabaseClient client;

  static const String _selectQuery = '''
    id_ets,
    fechahorainicio,
    fechahorafin,
    turno,
    estado,
    id_periodoets,
    salon (
      id_salon,
      codigo,
      piso,
      edificio (
        numero
      )
    ),
    carrera_materia (
      semestre,
      materia (
        nombre
      ),
      carrera (
        acronimo
      ),
      planestudios (
        nombre
      )
    ),
    jefeacademia (
      usuario (
        nombre,
        apellidopaterno,
        apellidomaterno
      )
    )
  ''';

  const SearchRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ExamModel>> getExams({
    String? carrera,
    int? semestre,
    String? plan,
    String? materia,
  }) async {
    try {
      final response =
          await client.from('ets').select(_selectQuery).eq('estado', 'activo');

      final exams = response.map((json) => ExamModel.fromJson(json)).toList();

      // Filtrado en memoria sobre la lista completa.
      return exams.where((exam) {
        final matchCarrera = carrera == null || exam.carrera == carrera;
        final matchSemestre = semestre == null || exam.semestre == semestre;
        final matchPlan = plan == null || exam.plan == plan;
        final matchMateria = materia == null ||
            exam.materia.toLowerCase().contains(materia.toLowerCase());
        return matchCarrera && matchSemestre && matchPlan && matchMateria;
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<String>> getCarreras() async {
    try {
      final response =
          await client.from('carrera').select('acronimo').eq('activo', true);

      return response.map((row) => row['acronimo'] as String).toList();
    } catch (e) {
      rethrow;
    }
  }
}
