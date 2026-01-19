import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme_config.dart';
import '../../models/assessment.dart';
import '../../providers/assessment_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/error_dialog.dart';
import 'results_screen.dart';

class ReviewAnswersScreen extends ConsumerWidget {
  const ReviewAnswersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionnaireAsync = ref.watch(assessmentQuestionnaireProvider);
    final answers = ref.watch(assessmentAnswersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Your Answers'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryMaroon,
      ),
      body: questionnaireAsync.when(
        data: (questionnaire) => _buildReview(context, ref, questionnaire, answers),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildReview(
    BuildContext context,
    WidgetRef ref,
    AssessmentQuestionnaire questionnaire,
    AssessmentAnswers answers,
  ) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(),
                const SizedBox(height: 24),
                _buildSectionReview(
                  'Section 1: Mental Health Indicators',
                  questionnaire.section1.questions,
                  questionnaire.section1.options,
                  answers.section1,
                ),
                const SizedBox(height: 24),
                _buildSectionReview(
                  'Section 2: University Life Stressors',
                  questionnaire.section2.questions,
                  questionnaire.section2.options,
                  answers.section2,
                ),
                const SizedBox(height: 24),
                _buildSectionReview(
                  'Section 3: Self-Assessment',
                  questionnaire.section3.questions,
                  questionnaire.section3.options,
                  answers.section3,
                ),
                const SizedBox(height: 80), // Space for bottom buttons
              ],
            ),
          ),
        ),
        _buildBottomButtons(context, ref),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: AppTheme.info.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppTheme.info),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Review Your Responses',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryMaroon,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Please review your answers carefully. You can go back to edit them or submit to see your results.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionReview(
    String title,
    List<Question> questions,
    List<QuestionOption> options,
    Map<String, int> answers,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryMaroon,
          ),
        ),
        const SizedBox(height: 12),
        ...questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          final questionKey = 'q${index + 1}';
          final selectedValue = answers[questionKey];
          final selectedOption = options.firstWhere(
            (opt) => opt.value == selectedValue,
            orElse: () => options.first,
          );

          return _buildAnswerCard(
            index + 1,
            question.text,
            selectedOption.label,
          );
        }),
      ],
    );
  }

  Widget _buildAnswerCard(
    int number,
    String question,
    String answer,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryMaroon.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: AppTheme.primaryMaroon,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryMaroon,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.success.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppTheme.success,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                answer,
                                style: const TextStyle(
                                  color: AppTheme.primaryMaroon,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Edit Answers',
              isOutlined: true,
              borderColor: AppTheme.primaryMaroon,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: 'Submit Assessment',
              backgroundColor: AppTheme.primaryMaroon,
              onPressed: () => _submitAssessment(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAssessment(BuildContext context, WidgetRef ref) async {
    LoadingDialog.show(context, message: 'Submitting assessment...');

    try {
      final apiService = ref.read(apiServiceProvider);
      final answers = ref.read(assessmentAnswersProvider);

      final result = await apiService.submitAssessment(answers);
      ref.read(assessmentResultProvider.notifier).state = result;

      if (context.mounted) {
        LoadingDialog.hide(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ResultsScreen(),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        LoadingDialog.hide(context);
        ErrorDialog.showNetworkError(context, onRetry: () => _submitAssessment(context, ref));
      }
    }
  }
}
