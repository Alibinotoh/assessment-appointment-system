import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../config/theme_config.dart';
import '../../providers/assessment_provider.dart';
import '../../widgets/error_dialog.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  Map<String, dynamic>? _analytics;
  List<dynamic> _assessments = [];
  bool _isLoading = true;
  String _selectedPeriod = '7days';

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ref.read(apiServiceProvider);
      
      final analytics = await apiService.getAnalytics(period: _selectedPeriod);
      final assessments = await apiService.getAdminAssessments(skip: 0, limit: 100);

      setState(() {
        _analytics = analytics;
        _assessments = assessments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ErrorDialog.showNetworkError(context, onRetry: _loadAnalytics);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPeriodSelector(),
                    const SizedBox(height: 24),
                    _buildOverviewCards(),
                    const SizedBox(height: 32),
                    _buildStressLevelChart(),
                    const SizedBox(height: 32),
                    _buildDemographicsSection(),
                    const SizedBox(height: 32),
                    _buildRecentAssessments(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reporting Period', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              _getPeriodLabel(),
              style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
          ],
        ),
        PopupMenuButton<String>(
          initialValue: _selectedPeriod,
          onSelected: (value) {
            setState(() => _selectedPeriod = value);
            _loadAnalytics();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: '7days', child: Text('Last 7 Days')),
            const PopupMenuItem(value: '30days', child: Text('Last 30 Days')),
            const PopupMenuItem(value: '90days', child: Text('Last 90 Days')),
            const PopupMenuItem(value: 'all', child: Text('All Time')),
          ],
          child: const Row(
            children: [
              Text('Change Period'),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ],
    );
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case '7days':
        return 'Last 7 days';
      case '30days':
        return 'Last 30 days';
      case '90days':
        return 'Last 90 days';
      case 'all':
        return 'All time';
      default:
        return 'Custom period';
    }
  }

  Widget _buildOverviewCards() {
    if (_analytics == null) return const SizedBox();

    final totalAssessments = _analytics!['total_assessments'] ?? 0;
    final avgScore = _analytics!['average_score'] ?? 0.0;
    final highStressCount = _analytics!['high_stress_count'] ?? 0;
    final completionRate = _analytics!['completion_rate'] ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 250,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.8,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return _buildMetricCard('Total Assessments', totalAssessments.toString(), Icons.assignment_turned_in_outlined);
              case 1:
                return _buildMetricCard('Average Score', avgScore.toStringAsFixed(2), Icons.analytics_outlined);
              case 2:
                return _buildMetricCard('High Stress', highStressCount.toString(), Icons.sentiment_dissatisfied_outlined);
              case 3:
                return _buildMetricCard('Completion Rate', '${completionRate.toStringAsFixed(1)}%', Icons.check_circle_outline);
              default:
                return const SizedBox();
            }
          },
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              Icon(icon, color: AppTheme.primaryMaroon, size: 28),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStressLevelChart() {
    final lowCount = _analytics?['low_stress'] ?? 0;
    final moderateCount = _analytics?['moderate_stress'] ?? 0;
    final highCount = _analytics?['high_stress'] ?? 0;
    final total = lowCount + moderateCount + highCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Stress Level Distribution', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (total == 0)
          const Card(
            color: Colors.white,
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No data available for this period.')),
            ),
          )
        else
          Card(
            color: Colors.white,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildStressBar('Low Stress', lowCount, total, AppTheme.success),
                  const SizedBox(height: 16),
                  _buildStressBar('Moderate Stress', moderateCount, total, AppTheme.warning),
                  const SizedBox(height: 16),
                  _buildStressBar('High Stress', highCount, total, AppTheme.error),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStressBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total * 100) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              '$count (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDemographicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Demographics Breakdown', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          color: Colors.white,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildDemographicItem('By Course', _getTopCourses()),
                const Divider(height: 32),
                _buildDemographicItem('By Year Level', _getYearLevels()),
                const Divider(height: 32),
                _buildDemographicItem('By Gender', _getGenderDistribution()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDemographicItem(String title, List<MapEntry<String, int>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ...data.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Chip(
                    label: Text(entry.value.toString()),
                    backgroundColor: AppTheme.primaryMaroon.withOpacity(0.1),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  List<MapEntry<String, int>> _getTopCourses() {
    // Analyze assessments by course
    // This would need to be linked to appointments to get course data
    // For now, return sample data
    return [
      const MapEntry('Computer Science', 45),
      const MapEntry('Engineering', 38),
      const MapEntry('Business Admin', 32),
      const MapEntry('Education', 28),
      const MapEntry('Others', 15),
    ];
  }

  List<MapEntry<String, int>> _getYearLevels() {
    return [
      const MapEntry('1st Year', 52),
      const MapEntry('2nd Year', 48),
      const MapEntry('3rd Year', 35),
      const MapEntry('4th Year', 23),
    ];
  }

  List<MapEntry<String, int>> _getGenderDistribution() {
    return [
      const MapEntry('Female', 89),
      const MapEntry('Male', 69),
    ];
  }

  Widget _buildRecentAssessments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Assessments', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (_assessments.isEmpty)
          const Card(
            color: Colors.white,
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No recent assessments.')),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _assessments.length > 10 ? 10 : _assessments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildAssessmentCard(_assessments[index]);
            },
          ),
      ],
    );
  }

  Widget _buildAssessmentCard(Map<String, dynamic> assessment) {
    final stressLevel = assessment['stress_level'] as String;
    final stressColor = AppTheme.getStressLevelColor(stressLevel);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.favorite_border, color: stressColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stress Level: $stressLevel',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Score: ${assessment['overall_score']} - ${_formatTimestamp(assessment['timestamp'])}',
                    style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.visibility_outlined, color: AppTheme.textSecondary),
              onPressed: () { /* View detailed assessment */ },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = DateTime.parse(timestamp.toString());
      return DateFormat('MMM dd, yyyy hh:mm a').format(dt);
    } catch (e) {
      return timestamp.toString();
    }
  }

}
