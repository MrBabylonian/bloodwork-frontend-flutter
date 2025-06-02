import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// This screen polls the backend every 2 seconds until the analysis is ready.
/// Once ready, it redirects to the result screen with the same UUID.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late final String uuid;
  Timer? _pollingTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        uuid = args;
        _startPolling(uuid);
      } else {
        _showError("UUID mancante o non valido.");
      }
    });
  }

  void _startPolling(String uuid) {
    const pollingInterval = Duration(seconds: 2);
    _pollingTimer = Timer.periodic(pollingInterval, (_) async {
      final uri = Uri.parse(
        'http://13.62.43.40:8000/analysis/pdf_analysis_result/$uuid',
      );

      try {
        final response = await http.get(uri);

        if (response.statusCode == 200) {
          _pollingTimer?.cancel();
          if (!_hasNavigated && context.mounted) {
            _hasNavigated = true;
            Navigator.pushReplacementNamed(
              context,
              '/results',
              arguments: uuid,
            );
          }
        } else if (response.statusCode == 404) {
          // Analysis still in progress — wait
        } else if (response.statusCode == 202) {
          // Analysis still in progress — wait
        } else {
          _showError("Errore server: ${response.statusCode}");
        }
      } catch (e) {
        _showError("Errore connessione: $e");
      }
    });
  }

  void _showError(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                'Stiamo elaborando il tuo referto.\nAttendi qualche minuto.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
