import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme_config.dart';
import 'screens/platform_router_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MSU Guidance & Counseling',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const PlatformRouterScreen(),
    );
  }
}
