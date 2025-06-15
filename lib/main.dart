import 'package:flutter/cupertino.dart';
import 'pages/landing_page.dart';

void main() {
  runApp(const VetAnalyticsApp());
}

class VetAnalyticsApp extends StatelessWidget {
  const VetAnalyticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'VetAnalytics',
      home: LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
