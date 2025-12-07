import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/quiz_models.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('GEMINI_API_KEY not found in .env');
    }
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }

  Future<List<QuizQuestion>> generateQuiz(QuizSettings settings) async {
    final prompt = '''
      Generate ${settings.numberOfQuestions} multiple choice questions based on the Bible, specifically ${settings.book} Chapter ${settings.chapter}.
      The target audience is ${settings.audience}.
      For kids, use simple language. For adults, use more depth.
      Return strictly a JSON array (no markdown, no code blocks) of objects with this structure:
      {
        "question": "The question string",
        "options": ["Option A", "Option B", "Option C", "Option D"],
        "correctOptionIndex": 0 // integer 0-3
      }
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      String? text = response.text;
      if (text == null) throw Exception('No response from Gemini');

      // Clean up markdown if present
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();

      final List<dynamic> jsonList = jsonDecode(text);
      return jsonList.map((json) => QuizQuestion.fromJson(json)).toList();
    } catch (e) {
      print('Error generating quiz: $e');
      // Return a fallback or rethrow
      return [
        QuizQuestion(
            question: "Error generating quiz. Please check API Key.",
            options: ["Error", "Error", "Error", "Error"],
            correctOptionIndex: 0)
      ];
    }
  }
}
