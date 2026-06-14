class QuizResult {
  final DateTime date;
  final int score;
  final int total;
  final String language;

  QuizResult({
    required this.date,
    required this.score,
    required this.total,
    required this.language,
  });

  double get percentage => (score / total) * 100;

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'score': score,
        'total': total,
        'language': language,
      };

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
        date: DateTime.parse(json['date']),
        score: json['score'],
        total: json['total'],
        language: json['language'],
      );
}
