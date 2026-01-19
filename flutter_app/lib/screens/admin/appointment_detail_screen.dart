import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../config/theme_config.dart';
import '../../models/assessment.dart';
import '../../providers/assessment_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/error_dialog.dart';

class AppointmentDetailScreen extends ConsumerStatefulWidget {
  final String appointmentId;

  const AppointmentDetailScreen({Key? key, required this.appointmentId}) : super(key: key);

  @override
  ConsumerState<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends ConsumerState<AppointmentDetailScreen> {
  Map<String, dynamic>? _appointmentDetail;
  AssessmentQuestionnaire? _questionnaire;
  bool _isLoading = true;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadAppointmentDetail(),
      _loadQuestionnaire(),
    ]);
  }

  Future<void> _loadQuestionnaire() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getQuestions();
      setState(() {
        _questionnaire = response;
      });
    } catch (e) {
      // Questionnaire is optional for viewing
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointmentDetail() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ref.read(apiServiceProvider);
      final detail = await apiService.getAppointmentDetail(widget.appointmentId);
      
      setState(() {
        _appointmentDetail = detail;
        _notesController.text = detail['counselor_notes'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ErrorDialog.showNetworkError(context, onRetry: _loadAppointmentDetail);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appointmentDetail == null
              ? const Center(child: Text('No data available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusCard(),
                      const SizedBox(height: 16),
                      _buildClientInfoCard(),
                      const SizedBox(height: 16),
                      _buildAssessmentResultsCard(),
                      const SizedBox(height: 16),
                      _buildAssessmentDetailsCard(),
                      const SizedBox(height: 16),
                      _buildNotesCard(),
                      const SizedBox(height: 16),
                      if (_appointmentDetail!['status'] == 'Pending')
                        _buildActionButtons(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatusCard() {
    final status = _appointmentDetail!['status'] as String;
    Color statusColor;
    
    switch (status) {
      case 'Pending':
        statusColor = AppTheme.warning;
        break;
      case 'Confirmed':
        statusColor = AppTheme.success;
        break;
      case 'Rejected':
        statusColor = AppTheme.error;
        break;
      default:
        statusColor = AppTheme.textSecondary;
    }

    return Card(
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              status == 'Pending' ? Icons.schedule :
              status == 'Confirmed' ? Icons.check_circle :
              Icons.cancel,
              color: statusColor,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: $status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scheduled: ${_appointmentDetail!['scheduled_date']} at ${_appointmentDetail!['scheduled_time']?.substring(0, 5)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Client Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryMaroon,
              ),
            ),
            const Divider(),
            _buildInfoRow('Name', _appointmentDetail!['client_full_name']),
            _buildInfoRow('Email', _appointmentDetail!['client_email']),
            if (_appointmentDetail!['client_student_id'] != null)
              _buildInfoRow('Student ID', _appointmentDetail!['client_student_id']),
            _buildInfoRow('Course', _appointmentDetail!['client_course']),
            _buildInfoRow('Year Level', _appointmentDetail!['client_year_level']),
            _buildInfoRow('Gender', _appointmentDetail!['client_gender']),
            _buildInfoRow('Age', _appointmentDetail!['client_age'].toString()),
            if (_appointmentDetail!['client_contact_number'] != null)
              _buildInfoRow('Contact', _appointmentDetail!['client_contact_number']),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentResultsCard() {
    final stressLevel = _appointmentDetail!['stress_level'] as String;
    final stressColor = AppTheme.getStressLevelColor(stressLevel);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assessment Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryMaroon,
              ),
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: stressColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.favorite, color: stressColor, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stress Level: $stressLevel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: stressColor,
                          ),
                        ),
                        Text(
                          'Overall Score: ${_appointmentDetail!['overall_score']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Section 1 Score', _appointmentDetail!['section1_score'].toString()),
            _buildInfoRow('Section 2 Score', _appointmentDetail!['section2_score'].toString()),
            _buildInfoRow('Section 3 Score', _appointmentDetail!['section3_score'].toString()),
            const SizedBox(height: 8),
            Text(
              _appointmentDetail!['recommendation'],
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentDetailsCard() {
    if (_questionnaire == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Loading assessment questions...'),
        ),
      );
    }

    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: const Text(
            'View Detailed Assessment Answers',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailedAnswersSection(
                    'Section 1: Mental Health Quality',
                    _questionnaire!.section1.questions,
                    _questionnaire!.section1.options,
                    _parseAnswers(_appointmentDetail!['section1_raw_answers']),
                  ),
                  const Divider(height: 24),
                  _buildDetailedAnswersSection(
                    'Section 2: University Life',
                    _questionnaire!.section2.questions,
                    _questionnaire!.section2.options,
                    _parseAnswers(_appointmentDetail!['section2_raw_answers']),
                  ),
                  const Divider(height: 24),
                  _buildDetailedAnswersSection(
                    'Section 3: Self Assessment',
                    _questionnaire!.section3.questions,
                    _questionnaire!.section3.options,
                    _parseAnswers(_appointmentDetail!['section3_raw_answers']),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _parseAnswers(dynamic rawAnswers) {
    if (rawAnswers is String) {
      try {
        final decoded = json.decode(rawAnswers);
        return Map<String, int>.from(decoded);
      } catch (e) {
        return {};
      }
    } else if (rawAnswers is Map) {
      return Map<String, int>.from(rawAnswers);
    }
    return {};
  }

  Widget _buildDetailedAnswersSection(
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryMaroon,
          ),
        ),
        const SizedBox(height: 12),
        ...questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          final questionKey = 'q${index + 1}';
          final selectedValue = answers[questionKey] ?? 0;
          
          // Q8 is stored reversed in database (1="Very Much", 5="Not at all")
          // Reverse back to show original answer user selected
          final isSection3Q8 = title.contains('Self Assessment') && 
                               question.valence == 'positive';
          final displayValue = isSection3Q8 
              ? (6 - selectedValue) 
              : selectedValue;
          
          final selectedOption = options.firstWhere(
            (opt) => opt.value == displayValue,
            orElse: () => options.first,
          );

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryMaroon,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          question.text,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.success.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: AppTheme.success,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedOption.label,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryMaroon,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Score: $selectedValue',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Counselor Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryMaroon,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Add notes about this appointment...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        CustomButton(
          text: 'Confirm Appointment',
          icon: Icons.check_circle,
          onPressed: () => _updateStatus('Confirmed'),
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Reject Appointment',
          icon: Icons.cancel,
          isOutlined: true,
          onPressed: () => _showRejectDialog(),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog() {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus('Rejected', rejectionReason: reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String status, {String? rejectionReason}) async {
    LoadingDialog.show(context, message: 'Updating status...');

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.updateAppointmentStatus(
        widget.appointmentId,
        status,
        notes: _notesController.text,
        rejectionReason: rejectionReason,
      );

      if (mounted) {
        LoadingDialog.hide(context);
        SuccessDialog.show(
          context,
          title: 'Success',
          message: 'Appointment status updated successfully',
          onClose: () => Navigator.pop(context),
        );
      }
    } catch (e) {
      if (mounted) {
        LoadingDialog.hide(context);
        ErrorDialog.show(
          context,
          title: 'Update Failed',
          message: e.toString(),
        );
      }
    }
  }
}
