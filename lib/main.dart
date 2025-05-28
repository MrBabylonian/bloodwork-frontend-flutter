import 'package:flutter/material.dart';
import 'app/theme/app_theme.dart';
import 'features/upload/upload_screen.dart';

void main() {
  runApp(const BloodworkApp());
}

/// This is the root of the application.
/// It sets up theming and the initial home screen.
class BloodworkApp extends StatelessWidget {
  const BloodworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloodwork Analyzer',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      // Initial screen: Upload PDF UI
      home: const UploadScreen(),
    );
  }
}
