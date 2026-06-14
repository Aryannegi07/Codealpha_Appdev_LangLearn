import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';
import 'vocabulary_screen.dart';
import 'progress_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('LangLearn', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 4),
                Text('${provider.streak}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LanguageSelector(selected: provider.selectedLanguage),
                  const SizedBox(height: 20),
                  _StatsRow(provider: provider),
                  const SizedBox(height: 24),
                  const Text('Learn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _MenuGrid(),
                ],
              ),
            ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final String selected;
  const _LanguageSelector({required this.selected});

  @override
  Widget build(BuildContext context) {
    final languages = ['Spanish', 'Japanese', 'French'];
    final provider = context.read<AppProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Learning Language', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            children: languages.map((lang) {
              final isSelected = lang == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => provider.changeLanguage(lang),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      lang,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final AppProvider provider;
  const _StatsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(label: 'Words', value: '${provider.words.length}', icon: Icons.book, color: const Color(0xFF4F46E5)),
        const SizedBox(width: 12),
        _StatCard(label: 'Learned', value: '${provider.totalLearned}', icon: Icons.check_circle, color: Colors.green),
        const SizedBox(width: 12),
        _StatCard(label: 'Quizzes', value: '${provider.quizResults.length}', icon: Icons.quiz, color: Colors.orange),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _MenuGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      {'title': 'Flashcards', 'icon': Icons.style, 'color': const Color(0xFF4F46E5), 'screen': const FlashcardScreen()},
      {'title': 'Quiz', 'icon': Icons.quiz, 'color': Colors.orange, 'screen': const QuizScreen()},
      {'title': 'Vocabulary', 'icon': Icons.menu_book, 'color': Colors.green, 'screen': const VocabularyScreen()},
      {'title': 'Progress', 'icon': Icons.bar_chart, 'color': Colors.purple, 'screen': const ProgressScreen()},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: items.map((item) {
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item['screen'] as Widget)),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'] as IconData, size: 36, color: item['color'] as Color),
                const SizedBox(height: 8),
                Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
