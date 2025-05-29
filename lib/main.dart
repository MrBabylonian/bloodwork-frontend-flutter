import 'package:flutter/material.dart';
import 'app/theme/app_theme.dart';
import 'features/upload/upload_screen.dart';
import 'features/loading/loading_screen.dart';
import 'features/result/result_screen.dart';

// @formatter:on
void main() {
  runApp(const BloodworkApp());
}

class BloodworkApp extends StatelessWidget {
  const BloodworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloodwork Analyzer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      initialRoute: '/',
      routes: {
        '/': (context) => const UploadScreen(),
        '/loading': (context) => const LoadingScreen(),
        '/results': (context) => const ResultScreen(), // Placeholder screen
      },
    );
  }
}
