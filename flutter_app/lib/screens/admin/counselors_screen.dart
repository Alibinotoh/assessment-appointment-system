import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme_config.dart';
import '../../providers/assessment_provider.dart';
import '../../widgets/error_dialog.dart';

class CounselorsScreen extends ConsumerStatefulWidget {
  const CounselorsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CounselorsScreen> createState() => _CounselorsScreenState();
}

class _CounselorsScreenState extends ConsumerState<CounselorsScreen> {
  List<dynamic> _counselors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounselors();
  }

  Future<void> _loadCounselors() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ref.read(apiServiceProvider);
      final counselors = await apiService.getAllCounselors();
      
      setState(() {
        _counselors = counselors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ErrorDialog.showNetworkError(context, onRetry: _loadCounselors);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_counselors.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No counselors found.', style: TextStyle(fontSize: 16)),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _counselors.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildCounselorCard(_counselors[index]);
                      },
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCounselorDialog,
        child: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryMaroon,
      ),
    );
  }

  Widget _buildCounselorCard(Map<String, dynamic> counselor) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () { /* Can navigate to a detail screen if desired */ },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryMaroon.withOpacity(0.1),
                child: Text(
                  counselor['full_name']?.substring(0, 1).toUpperCase() ?? 'C',
                  style: const TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      counselor['full_name'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      counselor['email'] ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditCounselorDialog(counselor);
                  } else if (value == 'delete') {
                    _confirmDelete(counselor);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCounselorDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final employeeIdController = TextEditingController();
    final specializationController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Counselor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: employeeIdController,
                decoration: const InputDecoration(labelText: 'Employee ID'),
              ),
              TextField(
                controller: specializationController,
                decoration: const InputDecoration(labelText: 'Specialization'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _addCounselor(
                nameController.text,
                emailController.text,
                employeeIdController.text,
                specializationController.text,
                passwordController.text,
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCounselorDialog(Map<String, dynamic> counselor) {
    // Similar to add dialog but with pre-filled values
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon')),
    );
  }

  void _confirmDelete(Map<String, dynamic> counselor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Counselor'),
        content: Text('Are you sure you want to delete ${counselor['full_name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCounselor(counselor['counselor_id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCounselor(String name, String email, String employeeId,
      String specialization, String password) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.createCounselor(
        name,
        email,
        employeeId,
        specialization,
        password,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Counselor added successfully')),
        );
        _loadCounselors();
      }
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(context, title: 'Error', message: e.toString());
      }
    }
  }

  Future<void> _deleteCounselor(String counselorId) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.deleteCounselor(counselorId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Counselor deleted successfully')),
        );
        _loadCounselors();
      }
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(context, title: 'Error', message: e.toString());
      }
    }
  }
}
