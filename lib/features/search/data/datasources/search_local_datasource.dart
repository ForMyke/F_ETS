import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exam_model.dart';

abstract class SearchLocalDataSource {
  Future<void> cacheExams(List<ExamModel> exams);
  Future<List<ExamModel>> getCachedExams();
  Future<bool> hasCachedExams();
}

class SearchLocalDataSourceImpl implements SearchLocalDataSource {
  static const String _key = 'cached_exams';
  static const String _timestampKey = 'cached_exams_timestamp';

  @override
  Future<void> cacheExams(List<ExamModel> exams) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = exams.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
    await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<List<ExamModel>> getCachedExams() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList.map((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return ExamModel(
        id: map['id_ets'] as String,
        materia: map['materia'] as String,
        carrera: map['carrera'] as String,
        semestre: map['semestre'] as int,
        plan: map['plan'] as String,
        fechaInicio: DateTime.parse(map['fechaHoraInicio'] as String),
        fechaFin: DateTime.parse(map['fechaHoraFin'] as String),
        turno: map['turno'] as String,
        hora: map['hora'] as String,
        salon: map['salon'] as String,
        edificio: map['edificio'] as String,
        profesor: map['profesor'] as String,
        periodoETS: map['id_periodoETS'] as String,
        estado: map['estado'] as String,
      );
    }).toList();
  }

  @override
  Future<bool> hasCachedExams() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key);
    return jsonList != null && jsonList.isNotEmpty;
  }
}