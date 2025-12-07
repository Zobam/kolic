import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quiz_viewmodel.dart';
import 'quiz_result_view.dart';

class QuizView extends StatelessWidget {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.isQuizFinished) {
          // Navigate to result only if finished and not already there.
          // Better: Use a listener or just push replacement here.
          // Since build loops can be tricky with nav, let's just return the ResultView or navigate.
          // Using a small delay to avoid build-phase navigation error.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const QuizResultView()),
            );
          });
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (viewModel.questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Quiz')),
            body: const Center(
                child:
                    Text("No questions generated. Check API Key or Internet.")),
          );
        }

        final question = viewModel.questions[viewModel.currentQuestionIndex];

        return Scaffold(
          appBar: AppBar(
            title: Text(
                'Question ${viewModel.currentQuestionIndex + 1}/${viewModel.questions.length}'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  question.question,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ...List.generate(question.options.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ElevatedButton(
                      onPressed: () {
                        viewModel.answerQuestion(index);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(question.options[index],
                            style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
