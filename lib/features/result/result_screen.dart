import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// This screen displays the final result fetched from the backend.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final String pdfUuid;
  String? modelOutput;
  String? errorMessage;
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      pdfUuid = args;
      _fetchAnalysisResult(pdfUuid);
    } else {
      setState(() {
        errorMessage = 'UUID non valido.';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAnalysisResult(String uuid) async {
    final uri = Uri.parse(
      'http://127.0.0.1:8000/analysis/pdf_analysis_result/$uuid',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          modelOutput = data['model_output'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Errore del server: codice ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Errore di connessione: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Risultato Analisi'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(
                  child: Text(
                    errorMessage!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
                : Scrollbar(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      modelOutput ?? 'Nessun risultato disponibile.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
      ),
    );
  }
}
