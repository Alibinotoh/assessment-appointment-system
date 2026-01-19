import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/error_dialog.dart';
import 'login_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _notificationsEnabled = true;
  bool _emailAlertsEnabled = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(authState),
            const SizedBox(height: 32),
            _buildSecuritySection(),
            const SizedBox(height: 32),
            _buildNotificationSettings(),
            const SizedBox(height: 32),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Profile Information', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          color: Colors.white,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryMaroon.withOpacity(0.1),
                  child: Text(
                    authState.fullName?.substring(0, 1).toUpperCase() ?? 'C',
                    style: const TextStyle(fontSize: 32, color: AppTheme.primaryMaroon, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(authState.fullName ?? 'N/A', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(authState.email ?? 'N/A', style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
                      const SizedBox(height: 4),
                      const Text('Counselor', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showEditProfileDialog(authState),
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Security', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          color: Colors.white,
          elevation: 0,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.lock_outline, color: AppTheme.primaryMaroon),
                title: const Text('Change Password'),
                subtitle: const Text('Update your account password'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showChangePasswordDialog(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.security_outlined, color: AppTheme.primaryMaroon),
                title: const Text('Two-Factor Authentication'),
                subtitle: const Text('Add an extra layer of security'),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feature coming soon')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notifications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          color: Colors.white,
          elevation: 0,
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined, color: AppTheme.primaryMaroon),
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive app notifications'),
                value: _notificationsEnabled,
                onChanged: (value) => setState(() => _notificationsEnabled = value),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.email_outlined, color: AppTheme.primaryMaroon),
                title: const Text('Email Alerts'),
                subtitle: const Text('Get notified via email'),
                value: _emailAlertsEnabled,
                onChanged: (value) => setState(() => _emailAlertsEnabled = value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('About', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          color: Colors.white,
          elevation: 0,
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.info_outline, color: AppTheme.primaryMaroon),
                title: Text('App Version'),
                subtitle: Text('1.0.0'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.description_outlined, color: AppTheme.primaryMaroon),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () { /* Show terms */ },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: AppTheme.primaryMaroon),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () { /* Show privacy policy */ },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.error),
                title: const Text('Logout', style: TextStyle(color: AppTheme.error)),
                onTap: _confirmLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog(authState) {
    final nameController = TextEditingController(text: authState.fullName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPasswordController,
                decoration: const InputDecoration(labelText: 'Current Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
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
            onPressed: () {
              if (_newPasswordController.text != _confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }
              Navigator.pop(context);
              _changePassword();
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    try {
      // Implement password change API call
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(context, title: 'Error', message: e.toString());
      }
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
