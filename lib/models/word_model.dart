class WordModel {
  final String id;
  final String word;
  final String translation;
  final String pronunciation;
  final String category;
  final String language;
  int difficulty;
  int correctCount;
  int wrongCount;

  WordModel({
    required this.id,
    required this.word,
    required this.translation,
    required this.pronunciation,
    required this.category,
    required this.language,
    this.difficulty = 1,
    this.correctCount = 0,
    this.wrongCount = 0,
  });

  int get priority => (wrongCount - correctCount).clamp(0, 10) + difficulty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'word': word,
        'translation': translation,
        'pronunciation': pronunciation,
        'category': category,
        'language': language,
        'difficulty': difficulty,
        'correctCount': correctCount,
        'wrongCount': wrongCount,
      };

  factory WordModel.fromJson(Map<String, dynamic> json) => WordModel(
        id: json['id'],
        word: json['word'],
        translation: json['translation'],
        pronunciation: json['pronunciation'],
        category: json['category'],
        language: json['language'],
        difficulty: json['difficulty'] ?? 1,
        correctCount: json['correctCount'] ?? 0,
        wrongCount: json['wrongCount'] ?? 0,
      );
}