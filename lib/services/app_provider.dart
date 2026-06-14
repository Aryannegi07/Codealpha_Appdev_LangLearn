import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../models/quiz_result_model.dart';
import '../data/word_data.dart';
import 'storage_service.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  String _selectedLanguage = 'Spanish';
  List<WordModel> _words = [];
  List<QuizResult> _quizResults = [];
  int _streak = 0;
  bool _isLoading = true;

  String get selectedLanguage => _selectedLanguage;
  List<WordModel> get words => _words;
  List<QuizResult> get quizResults => _quizResults;
  int get streak => _streak;
  bool get isLoading => _isLoading;

  List<WordModel> get vocabularyWords =>
      _words.where((w) => w.category == 'vocabulary').toList();
  List<WordModel> get grammarWords =>
      _words.where((w) => w.category == 'grammar').toList();
  List<WordModel> get phraseWords =>
      _words.where((w) => w.category == 'phrase').toList();

  // SRS Greedy sort: higher priority words come first
  List<WordModel> get srsWords {
    final sorted = List<WordModel>.from(_words);
    sorted.sort((a, b) => b.priority.compareTo(a.priority));
    return sorted;
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final savedLang = await _storage.loadLanguage();
    if (savedLang != null) _selectedLanguage = savedLang;

    await _loadWords();
    _quizResults = await _storage.loadQuizResults();
    _streak = await _storage.loadStreak();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadWords() async {
    final base = sampleWords[_selectedLanguage] ?? [];
    final saved = await _storage.loadWordProgress();

    _words = base.map((w) {
      if (saved.containsKey(w.id)) {
        w.correctCount = saved[w.id]!['correctCount'] ?? 0;
        w.wrongCount = saved[w.id]!['wrongCount'] ?? 0;
        w.difficulty = saved[w.id]!['difficulty'] ?? 1;
      }
      return w;
    }).toList();
  }

  Future<void> changeLanguage(String lang) async {
    _selectedLanguage = lang;
    await _storage.saveLanguage(lang);
    await _loadWords();
    notifyListeners();
  }

  Future<void> markCorrect(WordModel word) async {
    word.correctCount++;
    if (word.difficulty > 1) word.difficulty--;
    await _storage.saveWordProgress(_words);
    notifyListeners();
  }

  Future<void> markWrong(WordModel word) async {
    word.wrongCount++;
    if (word.difficulty < 5) word.difficulty++;
    await _storage.saveWordProgress(_words);
    notifyListeners();
  }

  Future<void> saveQuizResult(QuizResult result) async {
    _quizResults.add(result);
    await _storage.saveQuizResult(result);
    await _storage.incrementStreak();
    _streak++;
    notifyListeners();
  }

  int get totalLearned =>
      _words.where((w) => w.correctCount > 0).length;
}
