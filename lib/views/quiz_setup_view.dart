import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bible_data.dart';
import '../models/quiz_models.dart';
import '../viewmodels/quiz_viewmodel.dart';
import 'quiz_view.dart';

class QuizSetupView extends StatefulWidget {
  const QuizSetupView({super.key});

  @override
  State<QuizSetupView> createState() => _QuizSetupViewState();
}

class _QuizSetupViewState extends State<QuizSetupView> {
  String _selectedBook = BibleData.otBooks.first;
  int _chapter = 1;
  String _audience = 'Kids';
  int _questionCount = 5;

  final List<String> _audiences = ['Kids', 'Teenagers', 'Adults'];

  @override
  Widget build(BuildContext context) {
    // Combine OT and NT books for the dropdown
    final allBooks = [...BibleData.otBooks, ...BibleData.ntBooks];

    // Determine max chapters for selected book to validate input (optional, but good UX)
    final isOt = BibleData.oldTestament.containsKey(_selectedBook);
    final maxChapters = isOt
        ? BibleData.oldTestament[_selectedBook]!
        : BibleData.newTestament[_selectedBook]!;

    return Scaffold(
      appBar: AppBar(title: const Text('New Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedBook,
              decoration: const InputDecoration(labelText: 'Book'),
              items: allBooks
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedBook = val!;
                  _chapter = 1; // Reset chapter when book changes
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _chapter.toString(),
              decoration:
                  InputDecoration(labelText: 'Chapter (Max: $maxChapters)'),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                final n = int.tryParse(val);
                if (n != null) {
                  setState(() => _chapter = n);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _audience,
              decoration: const InputDecoration(labelText: 'Target Audience'),
              items: _audiences
                  .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                  .toList(),
              onChanged: (val) => setState(() => _audience = val!),
            ),
            const SizedBox(height: 16),
            Text('Number of Questions: $_questionCount'),
            Slider(
              value: _questionCount.toDouble(),
              min: 3,
              max: 10,
              divisions: 7,
              label: _questionCount.toString(),
              onChanged: (val) => setState(() => _questionCount = val.toInt()),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                final settings = QuizSettings(
                  book: _selectedBook,
                  chapter: _chapter,
                  audience: _audience,
                  numberOfQuestions: _questionCount,
                );

                // Start generation and navigate
                context.read<QuizViewModel>().generateQuiz(settings);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuizView()),
                );
              },
              child: const Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
