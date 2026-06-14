import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../models/word_model.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFlipped = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _next(List<WordModel> words) {
    if (_currentIndex < words.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
      _controller.reset();
    }
  }

  void _prev(List<WordModel> words) {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final words = provider.srsWords; // SRS sorted

    if (words.isEmpty) {
      return const Scaffold(body: Center(child: Text('No words available')));
    }

    final word = words[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Flashcards (${provider.selectedLanguage})'),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_currentIndex + 1} / ${words.length}',
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                _CategoryBadge(category: word.category),
              ],
            ),
          ),

          // Flashcard
          Expanded(
            child: GestureDetector(
              onTap: _flip,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final angle = _animation.value * 3.14159;
                  final isFront = angle < 1.5708;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(angle),
                    child: isFront
                        ? _CardFace(word: word, isFront: true)
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(3.14159),
                            child: _CardFace(word: word, isFront: false),
                          ),
                  );
                },
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      provider.markWrong(word);
                      _next(words);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Hard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _prev(words),
                  icon: const Icon(Icons.arrow_back_ios),
                  color: Colors.grey,
                ),
                IconButton(
                  onPressed: () => _next(words),
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      provider.markCorrect(word);
                      _next(words);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Easy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      foregroundColor: Colors.green,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final WordModel word;
  final bool isFront;
  const _CardFace({required this.word, required this.isFront});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isFront ? const Color(0xFF4F46E5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isFront) ...[
                Text(word.word, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                Text('[${word.pronunciation}]', style: const TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 12),
                const Text('Tap to reveal', style: TextStyle(color: Colors.white54, fontSize: 13)),
              ] else ...[
                Text(word.translation, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                const SizedBox(height: 16),
                Text(word.word, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 8),
                Text('[${word.pronunciation}]', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'vocabulary': Colors.blue,
      'grammar': Colors.orange,
      'phrase': Colors.green,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (colors[category] ?? Colors.grey).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(color: colors[category] ?? Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
