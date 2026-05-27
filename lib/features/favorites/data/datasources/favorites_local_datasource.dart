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
        .map((s) => ExamModel.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addFavorite(ExamModel exam) async {
    final prefs = await _prefs;
    final jsonList = prefs.getStringList(_key) ?? [];
    if (!jsonList.any((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return map['id'] == exam.id;
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
      return map['id'] == examId;
    });
    await prefs.setStringList(_key, jsonList);
  }

  @override
  Future<bool> isFavorite(String examId) async {
    final prefs = await _prefs;
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList.any((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return map['id'] == examId;
    });
  }
}
