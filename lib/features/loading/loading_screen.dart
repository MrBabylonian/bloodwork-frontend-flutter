import 'package:flutter/material.dart';

// @formatter:on
/// Full-screen progress screen shown after upload.
/// Expects a UUID to be passed via Navigator arguments.
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String uuid =
        ModalRoute.of(context)?.settings.arguments as String? ?? "UNKNOWN";

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LinearProgressIndicator(minHeight: 8),
              const SizedBox(height: 32),
              Text(
                'Analisi in corso...',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Stiamo analizzando il referto PDF.\nAttendi qualche secondo.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'UUID: $uuid',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
