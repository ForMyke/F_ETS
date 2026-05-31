import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../search/data/models/exam_model.dart';

abstract class FavoritesLocalDataSource {
  Future<List<ExamModel>> getFavorites();
  Future<void> addFavorite(ExamModel exam);
  Future<void> removeFavorite(String examId);
  Future<bool> isFavorite(String examId);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  static const String _key = 'favorites';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<List<ExamModel>> getFavorites() async {
    final prefs = await _prefs;
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList
        .map((s) => _fromCachedJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addFavorite(ExamModel exam) async {
    final prefs = await _prefs;
    final jsonList = prefs.getStringList(_key) ?? [];
    if (!jsonList.any((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return map['id_ets'] == exam.id;
    })) {
      jsonList.add(jsonEncode(exam.toJson()));
      await prefs.setStringList(_key, jsonList);
    }
  }

  @override
  Future<void> removeFavorite(String examId) async {
    final prefs = await _prefs;
    final jsonList = prefs.getStringList(_key) ?? [];
    jsonList.removeWhere((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return map['id_ets'] == examId;
    });
    await prefs.setStringList(_key, jsonList);
  }

  @override
  Future<bool> isFavorite(String examId) async {
    final prefs = await _prefs;
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList.any((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return map['id_ets'] == examId;
    });
  }

  // Reconstruye ExamModel desde el JSON plano guardado en cache local.
  ExamModel _fromCachedJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id_ets'] as String,
      materia: json['materia'] as String,
      carrera: json['carrera'] as String,
      semestre: json['semestre'] as int,
      plan: json['plan'] as String,
      fechaInicio: DateTime.parse(json['fechaHoraInicio'] as String),
      fechaFin: DateTime.parse(json['fechaHoraFin'] as String),
      turno: json['turno'] as String,
      hora: json['hora'] as String,
      salon: json['salon'] as String,
      edificio: json['edificio'] as String,
      profesor: json['profesor'] as String,
      periodoETS: json['id_periodoETS'] as String,
      estado: json['estado'] as String,
    );
  }
}