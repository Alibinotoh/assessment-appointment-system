import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme_config.dart';
import '../../models/assessment.dart';
import '../../providers/assessment_provider.dart';
import '../../widgets/custom_button.dart';
import 'review_answers_screen.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  int currentSection = 1;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionnaireAsync = ref.watch(assessmentQuestionnaireProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Self-Assessment'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryMaroon, // Maroon for assessment
      ),
      body: questionnaireAsync.when(
        data: (questionnaire) => _buildAssessment(questionnaire),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(assessmentQuestionnaireProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssessment(AssessmentQuestionnaire questionnaire) {
    return Column(
      children: [
        _buildProgressIndicator(),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildSection(questionnaire.section1, 1),
              _buildSection(questionnaire.section2, 2),
              _buildSection(questionnaire.section3, 3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.primaryMaroon.withOpacity(0.05),
      child: Row(
        children: [
          _buildProgressStep(1, 'Mental Health'),
          _buildProgressStep(2, 'University Life'),
          _buildProgressStep(3, 'Self Assessment'),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String label) {
    final isActive = currentSection == step;
    final isCompleted = currentSection > step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive || isCompleted
                  ? AppTheme.primaryMaroon
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      '$step',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? AppTheme.primaryMaroon : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(AssessmentSection section, int sectionNumber) {
    final answers = ref.watch(assessmentAnswersProvider);
    final answersNotifier = ref.read(assessmentAnswersProvider.notifier);

    Map<String, int> currentAnswers;
    switch (sectionNumber) {
      case 1:
        currentAnswers = answers.section1;
        break;
      case 2:
        currentAnswers = answers.section2;
        break;
      case 3:
        currentAnswers = answers.section3;
        break;
      default:
        currentAnswers = {};
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryMaroon,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            section.description,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ...section.questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            return _buildQuestion(
              question,
              index + 1,
              section.options,
              currentAnswers[question.id],
              (value) => answersNotifier.setAnswer(sectionNumber, question.id, value),
            );
          }).toList(),
          const SizedBox(height: 24),
          _buildNavigationButtons(answersNotifier, sectionNumber, section.questions.length),
        ],
      ),
    );
  }

  Widget _buildQuestion(
    Question question,
    int number,
    List<QuestionOption> options,
    int? selectedValue,
    Function(int) onSelect,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                    color: AppTheme.primaryMaroon,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
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
                        question.text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryMaroon,
                        ),
                      ),
                      if (question.note != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          question.note!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.warning,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final isSelected = selectedValue == option.value;
                return ChoiceChip(
                  label: Text(option.label),
                  selected: isSelected,
                  onSelected: (_) => onSelect(option.value),
                  selectedColor: AppTheme.primaryMaroon,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.primaryMaroon,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(
    AssessmentAnswersNotifier answersNotifier,
    int sectionNumber,
    int totalQuestions,
  ) {
    final isComplete = answersNotifier.isSectionComplete(sectionNumber, totalQuestions);

    return Row(
      children: [
        if (currentSection > 1)
          Expanded(
            child: CustomButton(
              text: 'Previous',
              isOutlined: true,
              borderColor: AppTheme.primaryMaroon,
              onPressed: () {
                setState(() => currentSection--);
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        if (currentSection > 1) const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: currentSection == 3 ? 'Review Answers' : 'Next',
            backgroundColor: AppTheme.primaryMaroon,
            onPressed: isComplete
                ? () {
                    if (currentSection == 3) {
                      _goToReview();
                    } else {
                      setState(() => currentSection++);
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  }
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please answer all questions'),
                        backgroundColor: AppTheme.warning,
                      ),
                    );
                  },
          ),
        ),
      ],
    );
  }

  void _goToReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReviewAnswersScreen(),
      ),
    );
  }
}
