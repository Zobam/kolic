import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quiz_viewmodel.dart';

class QuizResultView extends StatelessWidget {
  const QuizResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<QuizViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Quiz Completed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Score: ${viewModel.score} / ${viewModel.questions.length}',
              style: const TextStyle(fontSize: 32, color: Colors.blueAccent),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                viewModel.resetQuiz();
                Navigator.pop(context); // Go back to Setup
              },
              child: const Text('Play Again'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                viewModel.resetQuiz();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Back to Home'),
            )
          ],
        ),
      ),
    );
  }
}
