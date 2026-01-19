import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'client/client_home_screen.dart';
import 'admin/login_screen.dart';

/// Platform-aware router that shows different screens based on platform
/// Mobile: Client interface (Self-Assessment + Book Appointment)
/// Web/Desktop: Admin/Counselor login
class PlatformRouterScreen extends StatelessWidget {
  const PlatformRouterScreen({Key? key}) : super(key: key);

  bool _isMobileDevice(BuildContext context) {
    // If the app is not running on the web, we assume it's a mobile device.
    if (!kIsWeb) {
      return true;
    }
    
    // For web: Check screen size to detect mobile view.
    // This is a simple heuristic and works with browser dev tools.
    final size = MediaQuery.of(context).size;
    final width = size.width;
    
    // If width is less than a certain threshold, treat as mobile view.
    return width < 600;
  }

  @override
  Widget build(BuildContext context) {
    // On a mobile device (or small web screen), show the client interface.
    // On a desktop web browser, show the admin login.
    return _isMobileDevice(context)
        ? const ClientHomeScreen() 
        : const AdminLoginScreen();
  }
}
