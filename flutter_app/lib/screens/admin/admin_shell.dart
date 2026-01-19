import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme_config.dart';
import 'enhanced_dashboard_screen.dart';
import 'counselors_screen.dart';
import 'schedule_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const EnhancedDashboardScreen(),
    const CounselorsScreen(),
    const ScheduleScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          labelType: NavigationRailLabelType.all,
          backgroundColor: AppTheme.surface,
          indicatorColor: AppTheme.primaryMaroon.withOpacity(0.1),
          selectedLabelTextStyle: const TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.bold),
          unselectedLabelTextStyle: const TextStyle(color: AppTheme.textSecondary),
          selectedIconTheme: const IconThemeData(color: AppTheme.primaryMaroon),
          unselectedIconTheme: const IconThemeData(color: AppTheme.textSecondary),
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: Text('Dashboard'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: Text('Counselors'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
              label: Text('Calendar'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics),
              label: Text('Analytics'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: Text('Settings'),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _screens,
          ),
        ),
      ],
    );
  }

}
