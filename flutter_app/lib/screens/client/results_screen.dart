import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme_config.dart';
import '../../providers/assessment_provider.dart';
import '../../widgets/custom_button.dart';
import 'booking_form_screen.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(assessmentResultProvider);

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Results')),
        body: const Center(child: Text('No results available')),
      );
    }

    final stressColor = AppTheme.getStressLevelColor(result.stressLevel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Results'),
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.primaryMaroon,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stress Level Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: stressColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.favorite,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your Stress Level',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.stressLevel.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Overall Score: ${result.overallScore.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOut),
            
            const SizedBox(height: 24),
            
            // Section Scores
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detailed Scores',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryMaroon,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildScoreRow(
                      'Mental Health Quality',
                      result.section1Score,
                    ),
                    const Divider(),
                    _buildScoreRow(
                      'University Life',
                      result.section2Score,
                    ),
                    const Divider(),
                    _buildScoreRow(
                      'Self Assessment',
                      result.section3Score,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
            
            const SizedBox(height: 24),
            
            // Recommendation
            Card(
              color: AppTheme.info.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.lightbulb_outline, color: AppTheme.info),
                        SizedBox(width: 8),
                        Text(
                          'Recommendation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryMaroon,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      result.recommendation,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: AppTheme.primaryMaroon,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            CustomButton(
              text: 'Book an Appointment',
              icon: Icons.calendar_today,
              backgroundColor: AppTheme.primaryMaroon,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingFormScreen(
                      submissionId: result.submissionId,
                    ),
                  ),
                );
              },
            ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
            
            const SizedBox(height: 12),
            
            CustomButton(
              text: 'Return to Home',
              isOutlined: true,
              borderColor: AppTheme.primaryMaroon,
              onPressed: () {
                ref.read(assessmentAnswersProvider.notifier).reset();
                ref.read(assessmentResultProvider.notifier).state = null;
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ).animate().fadeIn(delay: 700.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.primaryMaroon,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryMaroon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              score.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryMaroon,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
