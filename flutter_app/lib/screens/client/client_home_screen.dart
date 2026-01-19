import 'package:flutter/material.dart';
import 'dart:ui';
import '../../config/theme_config.dart';
import 'assessment_screen.dart';
import 'booking_form_screen.dart';

/// Client home screen - Mobile only
/// Shows two main options: Self-Assessment and Book Appointment
class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // MSU Logo
                    ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.75),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/msu_logo.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Title
                    const Text(
                      'MSU-TCTO \nGuidance & Counseling',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Subtitle
                    Text(
                      'Your mental health matters',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Main Action Cards
                    _buildActionCard(
                      context,
                      icon: Icons.assignment,
                      title: 'Self-Assessment',
                      description: 'Take a quick assessment to understand your mental health',
                      color: Colors.white, // Will be made transparent with blur
                      textColor: const Color(0xFF1B1464), // Navy Blue from logo
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AssessmentScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    _buildActionCard(
                      context,
                      icon: Icons.calendar_today,
                      title: 'Book Appointment',
                      description: 'Schedule a session with our counselors',
                      color: Colors.white, // Will be made transparent with blur
                      textColor: const Color(0xFF8B1538), // Maroon from logo
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BookingFormScreen(
                              submissionId: '',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // Info text
                    Text(
                      'All information is confidential',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    final effectiveTextColor = textColor ?? Colors.white;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.75), // Lighter/brighter background
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: effectiveTextColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 32,
                        color: effectiveTextColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: effectiveTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 13,
                              color: effectiveTextColor.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: effectiveTextColor.withOpacity(0.6),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
