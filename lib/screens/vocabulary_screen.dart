import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../models/word_model.dart';

class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('Vocabulary'),
          backgroundColor: const Color(0xFF4F46E5),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: 'Vocabulary'),
              Tab(text: 'Grammar'),
              Tab(text: 'Phrases'),
            ],
          ),
        ),
        body: Consumer<AppProvider>(
          builder: (context, provider, _) => TabBarView(
            children: [
              _WordList(words: provider.vocabularyWords),
              _WordList(words: provider.grammarWords),
              _WordList(words: provider.phraseWords),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordList extends StatelessWidget {
  final List<WordModel> words;
  const _WordList({required this.words});

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return const Center(child: Text('No words in this category', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(word.word, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(word.translation, style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('[${word.pronunciation}]', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              Column(
                children: [
                  _DifficultyDots(level: word.difficulty),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 14, color: Colors.green.shade400),
                      Text(' ${word.correctCount}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(width: 6),
                      Icon(Icons.close, size: 14, color: Colors.red.shade300),
                      Text(' ${word.wrongCount}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DifficultyDots extends StatelessWidget {
  final int level;
  const _DifficultyDots({required this.level});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < level ? Colors.orange : Colors.grey.shade200,
          ),
        );
      }),
    );
  }
}
