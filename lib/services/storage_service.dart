import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_model.dart';
import '../models/quiz_result_model.dart';

class StorageService {
  static const _progressKey = 'word_progress';
  static const _quizResultsKey = 'quiz_results';
  static const _selectedLanguageKey = 'selected_language';
  static const _streakKey = 'streak_count';

  // Save word progress (correct/wrong counts)
  Future<void> saveWordProgress(List<WordModel> words) async {
    final prefs = await SharedPreferences.getInstance();
    final data = words.map((w) => w.toJson()).toList();
    await prefs.setString(_progressKey, jsonEncode(data));
  }

  // Load saved word progress
  Future<Map<String, Map<String, dynamic>>> loadWordProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressKey);
    if (raw == null) return {};
    final List list = jsonDecode(raw);
    return {for (var item in list) item['id']: item as Map<String, dynamic>};
  }

  // Save quiz result
  Future<void> saveQuizResult(QuizResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await loadQuizResults();
    existing.add(result);
    final data = existing.map((r) => r.toJson()).toList();
    await prefs.setString(_quizResultsKey, jsonEncode(data));
  }

  // Load all quiz results
  Future<List<QuizResult>> loadQuizResults() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_quizResultsKey);
    if (raw == null) return [];
    final List list = jsonDecode(raw);
    return list.map((item) => QuizResult.fromJson(item)).toList();
  }

  // Save selected language
  Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedLanguageKey, language);
  }

  Future<String?> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedLanguageKey);
  }

  // Streak
  Future<int> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  Future<void> incrementStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_streakKey) ?? 0;
    await prefs.setInt(_streakKey, current + 1);
  }
}
