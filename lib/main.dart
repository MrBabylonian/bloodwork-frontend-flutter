import 'package:flutter/cupertino.dart';
import 'navigation/app_router.dart';

void main() {
  runApp(const VetAnalyticsApp());
}

class VetAnalyticsApp extends StatelessWidget {
  const VetAnalyticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
      title: 'VetAnalytics',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.createRouter(),
    );
  }
}
