import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../models/word_model.dart';
import '../models/quiz_result_model.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQ = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _quizDone = false;
  late List<_QuizQuestion> _questions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _buildQuiz();
  }

  void _buildQuiz() {
    final provider = context.read<AppProvider>();
    final words = List<WordModel>.from(provider.words)..shuffle(Random());
    final selected = words.take(min(8, words.length)).toList();

    _questions = selected.map((word) {
      // Generate 4 options (1 correct + 3 wrong)
      final wrongWords = List<WordModel>.from(words)
        ..remove(word)
        ..shuffle(Random());
      final options = [word.translation, ...wrongWords.take(3).map((w) => w.translation)]
        ..shuffle(Random());
      return _QuizQuestion(
        question: word.word,
        correctAnswer: word.translation,
        options: options,
        word: word,
      );
    }).toList();
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (_questions[_currentQ].options[index] == _questions[_currentQ].correctAnswer) {
        _score++;
        context.read<AppProvider>().markCorrect(_questions[_currentQ].word);
      } else {
        context.read<AppProvider>().markWrong(_questions[_currentQ].word);
      }
    });
  }

  void _nextQuestion() {
    if (_currentQ < _questions.length - 1) {
      setState(() {
        _currentQ++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    final provider = context.read<AppProvider>();
    final result = QuizResult(
      date: DateTime.now(),
      score: _score,
      total: _questions.length,
      language: provider.selectedLanguage,
    );
    provider.saveQuizResult(result);
    setState(() => _quizDone = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_quizDone) return _ResultScreen(score: _score, total: _questions.length);

    final q = _questions[_currentQ];
    final progress = (_currentQ + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Quiz'),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Question ${_currentQ + 1} of ${_questions.length}',
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                Text('Score: $_score', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF4F46E5)),
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 28),

            // Question
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('What is the translation of:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 12),
                  Text(q.question, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Choose the correct answer', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),

            // Options
            ...q.options.asMap().entries.map((entry) {
              final idx = entry.key;
              final option = entry.value;
              final isCorrect = option == q.correctAnswer;
              final isSelected = _selectedAnswer == idx;

              Color bgColor = Colors.white;
              Color borderColor = Colors.transparent;
              if (_answered) {
                if (isCorrect) {
                  bgColor = Colors.green.shade50;
                  borderColor = Colors.green;
                } else if (isSelected && !isCorrect) {
                  bgColor = Colors.red.shade50;
                  borderColor = Colors.red;
                }
              }

              return GestureDetector(
                onTap: () => _selectAnswer(idx),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _answered ? borderColor : Colors.transparent, width: 2),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      Text(option, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      if (_answered && isCorrect) const Icon(Icons.check_circle, color: Colors.green),
                      if (_answered && isSelected && !isCorrect) const Icon(Icons.cancel, color: Colors.red),
                    ],
                  ),
                ),
              );
            }),

            const Spacer(),
            if (_answered)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_currentQ < _questions.length - 1 ? 'Next Question' : 'Finish Quiz',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuizQuestion {
  final String question;
  final String correctAnswer;
  final List<String> options;
  final WordModel word;
  _QuizQuestion({required this.question, required this.correctAnswer, required this.options, required this.word});
}

class _ResultScreen extends StatelessWidget {
  final int score, total;
  const _ResultScreen({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = ((score / total) * 100).round();
    final emoji = pct >= 80 ? '🎉' : pct >= 50 ? '👍' : '💪';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Quiz Result'),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 20),
              Text('$pct%', style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
              const SizedBox(height: 8),
              Text('$score out of $total correct', style: const TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
