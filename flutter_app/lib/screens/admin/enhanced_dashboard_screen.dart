import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme_config.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/error_dialog.dart';
import 'appointment_detail_screen.dart';

class EnhancedDashboardScreen extends ConsumerStatefulWidget {
  const EnhancedDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EnhancedDashboardScreen> createState() => _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends ConsumerState<EnhancedDashboardScreen> {
  Map<String, dynamic>? _stats;
  List<dynamic> _recentAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ref.read(apiServiceProvider);
      
      final stats = await apiService.getDashboardStats();
      final appointments = await apiService.getAdminAppointments(status: null);

      setState(() {
        _stats = stats;
        _recentAppointments = appointments.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ErrorDialog.showNetworkError(context, onRetry: _loadDashboardData);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(authState),
                      const SizedBox(height: 24),
                      _buildStatisticsCards(),
                      const SizedBox(height: 32),
                      _buildRecentAppointments(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeSection(authState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryMaroon,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${authState.fullName?.split(' ').first ?? 'Counselor'}!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s a summary of your activity.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    if (_stats == null) return const SizedBox();

    final allStats = {
      'Overview': [
        {'title': 'Total Appointments', 'value': _stats!['total_appointments'], 'icon': Icons.event_note},
        {'title': 'Pending', 'value': _stats!['pending_appointments'], 'icon': Icons.hourglass_top},
        {'title': 'Confirmed', 'value': _stats!['confirmed_appointments'], 'icon': Icons.check_circle_outline},
        {'title': 'Total Assessments', 'value': _stats!['total_assessments'], 'icon': Icons.assignment_turned_in_outlined},
      ],
      'Stress Level Distribution': [
        {'title': 'Low Stress', 'value': _stats!['low_stress'], 'icon': Icons.sentiment_satisfied_outlined},
        {'title': 'Moderate Stress', 'value': _stats!['moderate_stress'], 'icon': Icons.sentiment_neutral_outlined},
        {'title': 'High Stress', 'value': _stats!['high_stress'], 'icon': Icons.sentiment_dissatisfied_outlined},
      ],
    };

    return Column(
      children: allStats.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(entry.key, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.8,
              ),
              itemCount: entry.value.length,
              itemBuilder: (context, index) {
                final item = entry.value[index];
                return _buildStatCard(item['title'], item['value'].toString(), item['icon']);
              },
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
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
                style: TextStyle(
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

  Widget _buildRecentAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text('Recent Appointments', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        if (_recentAppointments.isEmpty)
          const Card(
            color: Colors.white,
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No recent appointments to show.', style: TextStyle(fontSize: 16)),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentAppointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildAppointmentCard(_recentAppointments[index]);
            },
          ),
      ],
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final status = appointment['status'] as String;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentDetailScreen(
                appointmentId: appointment['appointment_id'],
              ),
            ),
          ).then((_) => _loadDashboardData());
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryMaroon.withOpacity(0.1),
                child: const Icon(Icons.person_outline, color: AppTheme.primaryMaroon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['client_full_name'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${appointment['scheduled_date']} at ${appointment['scheduled_time']?.substring(0, 5)}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMaroon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: AppTheme.primaryMaroon,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
