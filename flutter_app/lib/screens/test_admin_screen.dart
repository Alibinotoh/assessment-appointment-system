import 'package:flutter/material.dart';
import 'admin/login_screen.dart';

/// Temporary screen for testing admin interface on web
/// Navigate to this manually when you need to test admin features
class TestAdminScreen extends StatelessWidget {
  const TestAdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AdminLoginScreen();
  }
}
