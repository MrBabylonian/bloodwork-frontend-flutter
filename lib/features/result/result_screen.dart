import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final String pdfUuid;
  String? rawResponse;
  List<Map<String, dynamic>> sections = [];
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

        // Extract text content from the response - handle different possible formats
        String textContent = '';
        if (data is Map) {
          // Try to get from 'model_output' or 'result' fields
          textContent = data['model_output'] ?? data['result'] ?? '';

          // If the content is a JSON string, parse it
          if (textContent.startsWith('{') && textContent.endsWith('}')) {
            try {
              final jsonContent = json.decode(textContent);
              if (jsonContent is Map && jsonContent.containsKey('result')) {
                textContent = jsonContent['result'] ?? '';
              }
            } catch (e) {
              // Keep the original text if parsing fails
            }
          }
        } else if (data is String) {
          textContent = data;
        }

        setState(() {
          rawResponse = textContent;
          sections = _processContent(textContent);
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

  List<Map<String, dynamic>> _processContent(String content) {
    // Clean up the content by normalizing newlines and handling escaped characters
    content = content.replaceAll('\\n', '\n').replaceAll('\\t', '    ');

    final List<Map<String, dynamic>> result = [];

    // First try to extract by numbered sections
    final sectionRegex = RegExp(r'(\d+\.\s+[^\n]+)([\s\S]*?)(?=\d+\.\s+|$)');
    final matches = sectionRegex.allMatches(content);

    if (matches.isNotEmpty) {
      for (final match in matches) {
        final title = match.group(1)?.trim() ?? '';
        String sectionContent = match.group(2)?.trim() ?? '';

        // Remove leading newlines
        while (sectionContent.startsWith('\n')) {
          sectionContent = sectionContent.substring(1);
        }

        final section = <String, dynamic>{
          'title': title,
          'content': sectionContent,
        };

        // Detect section type
        if (title.toLowerCase().contains('tabella') ||
            sectionContent.contains('|') && sectionContent.contains('\n')) {
          section['type'] = 'table';
          section['tableData'] = _extractTableData(sectionContent);
        } else {
          section['type'] = 'text';
        }

        // Check for urgency indicators
        if (title.toLowerCase().contains('urgenza') ||
            title.toLowerCase().contains('priorità')) {
          section['isUrgency'] = true;
          section['urgencyLevel'] = _determineUrgencyLevel(sectionContent);
        }

        result.add(section);
      }
    } else {
      // If no sections found, treat as single text block
      result.add({
        'title': 'Risultato Analisi',
        'content': content,
        'type': 'text'
      });
    }

    return result;
  }

  Map<String, dynamic> _extractTableData(String content) {
    final lines = content.split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return {'valid': false};
    }

    // Try to identify header row
    int headerRowIndex = 0;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('|') && lines[i].split('|').length > 2) {
        headerRowIndex = i;
        break;
      }
    }

    // Extract headers from the header row
    final headers = lines[headerRowIndex]
        .split('|')
        .map((cell) => cell.trim())
        .where((cell) => cell.isNotEmpty)
        .toList();

    // Find separator line or assume it's the next line
    int separatorIndex = headerRowIndex + 1;
    while (separatorIndex < lines.length &&
        (lines[separatorIndex].contains('---') || lines[separatorIndex].trim().isEmpty)) {
      separatorIndex++;
    }

    // Extract data rows
    final rows = <List<String>>[];
    for (int i = separatorIndex; i < lines.length; i++) {
      if (!lines[i].contains('|')) continue;

      final row = lines[i]
          .split('|')
          .map((cell) => cell.trim())
          .where((cell) => cell.isNotEmpty)
          .toList();

      if (row.isNotEmpty) {
        rows.add(row);
      }
    }

    return {
      'valid': headers.isNotEmpty && rows.isNotEmpty,
      'headers': headers.length > 5 ? headers.take(5).toList() : headers,
      'rows': rows,
    };
  }

  String _determineUrgencyLevel(String content) {
    final lowerContent = content.toLowerCase();

    if (lowerContent.contains('alta') ||
        lowerContent.contains('high') ||
        lowerContent.contains('emergenza') ||
        lowerContent.contains('emergency')) {
      return 'high';
    } else if (lowerContent.contains('media') ||
        lowerContent.contains('medium')) {
      return 'medium';
    }
    return 'low';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Risultato Analisi'),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Text(
          errorMessage!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      )
          : _buildResultContent(),
    );
  }

  Widget _buildResultContent() {
    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            if (sections.isEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SelectableText(
                    rawResponse ?? 'Nessun risultato disponibile.',
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              )
            else
              ...sections.map((section) => _buildDynamicSection(section)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Analisi automatica basata su referto. Non sostituisce visita clinica veterinaria.',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riepilogo Analisi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: $pdfUuid',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Data: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicSection(Map<String, dynamic> section) {
    final title = section['title'] as String;
    final content = section['content'] as String;
    final type = section['type'] as String? ?? 'text';

    if (type == 'table' && section['tableData'] != null && section['tableData']['valid'] == true) {
      return _buildTableSection(title, section['tableData']);
    }

    if (section['isUrgency'] == true) {
      return _buildUrgencySection(title, content, section['urgencyLevel'] ?? 'low');
    }

    return _buildTextSection(title, content);
  }

  Widget _buildTextSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SelectableText(
                content,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableSection(String title, Map<String, dynamic> tableData) {
    final headers = tableData['headers'] as List<String>;
    final rows = tableData['rows'] as List<List<String>>;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  headingRowHeight: 48,
                  dataRowMinHeight: 48,
                  headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                  border: TableBorder.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                  columns: headers.map((header) =>
                      DataColumn(
                          label: Text(
                            header,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                      )
                  ).toList(),
                  rows: rows.map((row) {
                    return DataRow(
                      cells: List.generate(
                        headers.length,
                            (i) {
                          final cell = i < row.length ? row[i] : '';

                          // Check for status indicators in the last column
                          if (i == headers.length - 1 &&
                              (cell.contains('normale') || cell.contains('anomalo') ||
                                  cell.contains('✅') || cell.contains('❌'))) {

                            bool isNormal = cell.contains('normale') ||
                                cell.contains('✅') ||
                                !cell.contains('anomalo');

                            Color textColor = isNormal ? Colors.green : Colors.red;
                            IconData icon = isNormal ? Icons.check_circle : Icons.warning;

                            return DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(icon, color: textColor, size: 16),
                                  const SizedBox(width: 4),
                                  Text(cell, style: TextStyle(color: textColor)),
                                ],
                              ),
                            );
                          }

                          return DataCell(Text(cell));
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrgencySection(String title, String content, String urgencyLevel) {
    Color urgencyColor;
    IconData urgencyIcon;

    switch (urgencyLevel) {
      case 'high':
        urgencyColor = Colors.red;
        urgencyIcon = Icons.warning_amber_rounded;
        break;
      case 'medium':
        urgencyColor = Colors.orange;
        urgencyIcon = Icons.info_outline;
        break;
      default:
        urgencyColor = Colors.green;
        urgencyIcon = Icons.check_circle_outline;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: urgencyColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(urgencyIcon, color: urgencyColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      content,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: urgencyColor.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}