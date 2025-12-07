import 'package:flutter/material.dart';
import '../models/quiz_models.dart';
import '../services/gemini_service.dart';

class QuizViewModel extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();

  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = false;

  List<QuizQuestion> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  bool get isLoading => _isLoading;
  bool get isQuizFinished => _currentQuestionIndex >= _questions.length;

  Future<void> generateQuiz(QuizSettings settings) async {
    _isLoading = true;
    _questions = [];
    _currentQuestionIndex = 0;
    _score = 0;
    notifyListeners();

    try {
      _questions = await _geminiService.generateQuiz(settings);
    } catch (e) {
      print(e);
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void answerQuestion(int selectedOptionIndex) {
    if (isQuizFinished) return;

    if (selectedOptionIndex ==
        _questions[_currentQuestionIndex].correctOptionIndex) {
      _score++;
    }
    _currentQuestionIndex++;
    notifyListeners();
  }

  void resetQuiz() {
    _questions = [];
    _currentQuestionIndex = 0;
    _score = 0;
    notifyListeners();
  }
}
