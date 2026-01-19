import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme_config.dart';
import '../../widgets/custom_button.dart';
import 'assessment_screen.dart';
import '../admin/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/msu_logo.png',
                      width: 120,
                      height: 120,
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOut),
                  
                  const SizedBox(height: 32),
                  
                  // Title
                  Text(
                    'Mindanao State University',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Guidance and Counseling',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Self-Assessment & Appointment System',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
                  
                  const SizedBox(height: 48),
                  
                  // Card with buttons
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.psychology,
                            size: 64,
                            color: AppTheme.primaryMaroon,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Welcome!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Take a moment to assess your mental health and well-being. Your responses are anonymous.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Start Assessment',
                            icon: Icons.arrow_forward,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AssessmentScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminLoginScreen(),
                                ),
                              );
                            },
                            child: const Text('Counselor Login'),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms, duration: 600.ms).slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 600.ms,
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
