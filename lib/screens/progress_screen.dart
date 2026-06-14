import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../models/quiz_result_model.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final results = provider.quizResults.reversed.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Progress'),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProgressSummary(provider: provider),
            const SizedBox(height: 24),
            const Text('Quiz History', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (results.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No quizzes taken yet!', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...results.map((r) => _QuizResultCard(result: r)),
          ],
        ),
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  final AppProvider provider;
  const _ProgressSummary({required this.provider});

  @override
  Widget build(BuildContext context) {
    final totalWords = provider.words.length;
    final learned = provider.totalLearned;
    final pct = totalWords > 0 ? learned / totalWords : 0.0;

    final avgScore = provider.quizResults.isEmpty
        ? 0.0
        : provider.quizResults.map((r) => r.percentage).reduce((a, b) => a + b) /
            provider.quizResults.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(provider.selectedLanguage,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
          const SizedBox(height: 16),
          Row(
            children: [
              _SummaryItem(label: 'Words Learned', value: '$learned / $totalWords'),
              const SizedBox(width: 16),
              _SummaryItem(label: 'Avg Quiz Score', value: '${avgScore.round()}%'),
              const SizedBox(width: 16),
              _SummaryItem(label: 'Day Streak', value: '🔥 ${provider.streak}'),
            ],
          ),
          const SizedBox(height: 16),
          Text('Completion: ${(pct * 100).round()}%', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation(Color(0xFF4F46E5)),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label, value;
  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _QuizResultCard extends StatelessWidget {
  final QuizResult result;
  const _QuizResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final pct = result.percentage.round();
    final color = pct >= 80 ? Colors.green : pct >= 50 ? Colors.orange : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Center(child: Text('$pct%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${result.language} Quiz', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${result.score} / ${result.total} correct',
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Text(
            '${result.date.day}/${result.date.month}/${result.date.year}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
