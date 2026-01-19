import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../config/theme_config.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/error_dialog.dart';
import 'appointment_detail_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  List<dynamic> _appointments = [];
  List<dynamic> _assessments = [];
  bool _isLoading = true;
  String _selectedFilter = 'Pending';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ref.read(apiServiceProvider);
      
      final appointments = await apiService.getAdminAppointments(
        status: _selectedFilter,
      );
      final assessments = await apiService.getAdminAssessments(limit: 10);

      setState(() {
        _appointments = appointments;
        _assessments = assessments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ErrorDialog.showNetworkError(context, onRetry: _loadData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counselor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authState.fullName ?? 'Counselor',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      authState.email ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: const Text('Logout'),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(authProvider.notifier).logout();
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Card(
                      color: AppTheme.primaryMaroon,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.waving_hand,
                              color: AppTheme.primaryGold,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome, ${authState.fullName?.split(' ').first ?? 'Counselor'}!',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Manage your appointments and view assessments',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Appointments Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Appointments',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        DropdownButton<String>(
                          value: _selectedFilter,
                          items: ['Pending', 'Confirmed', 'Rejected', 'Completed']
                              .map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedFilter = value!);
                            _loadData();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    if (_appointments.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text('No appointments found'),
                          ),
                        ),
                      )
                    else
                      ..._appointments.map((apt) => _buildAppointmentCard(apt)),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Assessments Section
                    const Text(
                      'Recent Anonymous Assessments',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    if (_assessments.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text('No assessments found'),
                          ),
                        ),
                      )
                    else
                      ..._assessments.map((assessment) => _buildAssessmentCard(assessment)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final status = appointment['status'] as String;
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
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            status == 'Pending' ? Icons.schedule :
            status == 'Confirmed' ? Icons.check_circle :
            status == 'Rejected' ? Icons.cancel :
            Icons.done,
            color: statusColor,
          ),
        ),
        title: Text(
          appointment['client_full_name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appointment['client_email'] ?? ''),
            const SizedBox(height: 4),
            Text(
              '${appointment['scheduled_date']} at ${appointment['scheduled_time']?.substring(0, 5)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            status,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
          backgroundColor: statusColor,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentDetailScreen(
                appointmentId: appointment['appointment_id'],
              ),
            ),
          ).then((_) => _loadData());
        },
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

  Widget _buildAssessmentCard(Map<String, dynamic> assessment) {
    final stressLevel = assessment['stress_level'] as String;
    final stressColor = AppTheme.getStressLevelColor(stressLevel);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: stressColor.withOpacity(0.2),
          child: Icon(
            Icons.favorite,
            color: stressColor,
          ),
        ),
        title: Text(
          'Stress Level: $stressLevel',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score: ${assessment['overall_score']}'),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(assessment['timestamp']),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
