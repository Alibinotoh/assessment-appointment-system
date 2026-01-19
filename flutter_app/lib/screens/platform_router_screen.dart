import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'client/client_home_screen.dart';
import 'admin/login_screen.dart';

/// Platform-aware router that shows different screens based on platform
/// Mobile: Client interface (Self-Assessment + Book Appointment)
/// Web/Desktop: Admin/Counselor login
class PlatformRouterScreen extends StatelessWidget {
  const PlatformRouterScreen({Key? key}) : super(key: key);

  bool _isMobileDevice(BuildContext context) {
    // Check if running on actual mobile device
    if (!kIsWeb) {
      try {
        return Platform.isAndroid || Platform.isIOS;
      } catch (e) {
        return false;
      }
    }
    
    // For web: Check screen size to detect mobile view
    // This works with Chrome DevTools mobile emulation
    final size = MediaQuery.of(context).size;
    final width = size.width;
    
    // If width is less than 600px, treat as mobile
    return width < 600;
  }

  @override
  Widget build(BuildContext context) {
    // Mobile (real device or small screen) → Client Home
    // Desktop/Web (large screen) → Admin Login
    return _isMobileDevice(context)
        ? const ClientHomeScreen() 
        : const AdminLoginScreen();
  }
}
