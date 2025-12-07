class QuizSettings {
  final String book;
  final int chapter;
  final String audience; // Kids, Teenagers, Adults
  final int numberOfQuestions;

  QuizSettings({
    required this.book,
    required this.chapter,
    required this.audience,
    required this.numberOfQuestions,
  });
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctOptionIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctOptionIndex: json['correctOptionIndex'] ?? 0,
    );
  }
}
