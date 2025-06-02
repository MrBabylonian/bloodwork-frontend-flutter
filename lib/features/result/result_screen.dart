// @formatter:on

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_theme.dart';

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

    final args = ModalRoute
        .of(context)
        ?.settings
        .arguments;
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
    // Keep all existing logic here
    final uri = Uri.parse(
      'http://13.62.43.40:8000/analysis/pdf_analysis_result/$uuid',
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
    // Keep existing content processing logic
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
    // Keep existing table extraction logic
    final lines = content.split('\n')
        .where((line) =>
    line
        .trim()
        .isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return {'valid': false};
    }

    // Try to identify header row
    int headerRowIndex = 0;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('|') && lines[i]
          .split('|')
          .length > 2) {
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
        (lines[separatorIndex].contains('---') || lines[separatorIndex]
            .trim()
            .isEmpty)) {
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
    // Keep existing urgency logic
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
        title: Text(
          'Risultato Analisi',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? _buildLoadingUI()
          : errorMessage != null
          ? _buildErrorUI()
          : _buildResultContent(),
    );
  }

  Widget _buildLoadingUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            "Elaborazione dei risultati in corso...",
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w500,
              color: AppTheme.neutralDarkColor,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildErrorUI() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Si è verificato un errore',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: GoogleFonts.workSans(
                fontSize: 14,
                color: Colors.red.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultContent() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        image: DecorationImage(
          image: const NetworkImage(
              'https://www.transparenttextures.com/patterns/subtle-white-feathers.png'),
          repeat: ImageRepeat.repeat,
          opacity: 0.05,
        ),
      ),
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              if (sections.isEmpty)
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SelectableText(
                      rawResponse ?? 'Nessun risultato disponibile.',
                      style: GoogleFonts.workSans(
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),
                )
              else
                ...sections
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final section = entry.value;
                  return _buildDynamicSectionWithAnimation(section, index);
                }),
              const SizedBox(height: 24),
              const Divider(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                      size: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Analisi automatica basata su referto. Non sostituisce visita clinica veterinaria.',
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicSectionWithAnimation(Map<String, dynamic> section,
      int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: _buildDynamicSection(section),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Riepilogo Analisi',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildHeaderInfoItem(
                    'ID Referto',
                    pdfUuid,
                    Icons.article_outlined,
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildHeaderInfoItem(
                    'Data',
                    '${DateTime
                        .now()
                        .day}/${DateTime
                        .now()
                        .month}/${DateTime
                        .now()
                        .year}',
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int min(int a, int b) => a < b ? a : b;

  Widget _buildHeaderInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicSection(Map<String, dynamic> section) {
    final title = section['title'] as String;
    final content = section['content'] as String;
    final type = section['type'] as String? ?? 'text';

    if (type == 'table' && section['tableData'] != null &&
        section['tableData']['valid'] == true) {
      return _buildTableSection(title, section['tableData']);
    }

    if (section['isUrgency'] == true) {
      return _buildUrgencySection(
          title, content, section['urgencyLevel'] ?? 'low');
    }

    return _buildTextSection(title, content);
  }

  Widget _buildTextSection(String title, String content) {
    final sectionNumber = _extractSectionNumber(title);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title, sectionNumber),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SelectableText(
              content,
              style: GoogleFonts.workSans(
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String sectionNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.neutralLightColor.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                sectionNumber,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _removeSectionNumber(title),
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _getSectionIcon(title),
        ],
      ),
    );
  }

  Icon _getSectionIcon(String title) {
    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('tabella') || lowerTitle.contains('parametri')) {
      return Icon(Icons.table_chart_outlined, color: AppTheme.primaryColor);
    } else if (lowerTitle.contains('analisi mat')) {
      return Icon(Icons.functions, color: AppTheme.primaryColor);
    } else if (lowerTitle.contains('interpretazione clinica')) {
      return Icon(
          Icons.medical_information_outlined, color: AppTheme.primaryColor);
    } else if (lowerTitle.contains('istologica') ||
        lowerTitle.contains('citologica')) {
      return Icon(Icons.biotech_outlined, color: AppTheme.primaryColor);
    } else if (lowerTitle.contains('urgenza')) {
      return Icon(Icons.priority_high, color: AppTheme.primaryColor);
    } else if (lowerTitle.contains('piano')) {
      return Icon(Icons.checklist_outlined, color: AppTheme.primaryColor);
    }

    return Icon(Icons.article_outlined, color: AppTheme.primaryColor);
  }

  String _extractSectionNumber(String title) {
    final match = RegExp(r'^\d+').firstMatch(title);
    return match != null ? match.group(0)! : '';
  }

  String _removeSectionNumber(String title) {
    return title.replaceAll(RegExp(r'^\d+\.\s*'), '');
  }

  Widget _buildTableSection(String title, Map<String, dynamic> tableData) {
    final headers = tableData['headers'] as List<String>;
    final rows = tableData['rows'] as List<List<String>>;
    final sectionNumber = _extractSectionNumber(title);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title, sectionNumber),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header row
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.neutralLightColor.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    border: Border.all(color: AppTheme.neutralLightColor),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: headers.map((header) => Container(
                        width: 120,
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          header,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )).toList(),
                    ),
                  ),
                ),
                // Data rows
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.neutralLightColor),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: rows.map((row) => Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppTheme.neutralLightColor),
                          ),
                        ),
                        child: Row(
                          children: List.generate(headers.length, (i) {
                            final cell = i < row.length ? row[i] : '';

                            // Check for status indicators in the last column
                            if (i == headers.length - 1 &&
                                (cell.toLowerCase().contains('normale') ||
                                    cell.toLowerCase().contains('anomalo'))) {

                              bool isNormal = cell.toLowerCase().contains('normale');
                              Color textColor = isNormal ? AppTheme.successColor : AppTheme.dangerColor;
                              IconData icon = isNormal ? Icons.check_circle : Icons.warning;

                              return Container(
                                width: 120,
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(icon, color: textColor, size: 18),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        cell,
                                        style: GoogleFonts.workSans(
                                          color: textColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Container(
                              width: 120,
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                cell,
                                style: GoogleFonts.workSans(
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildUrgencySection(String title, String content, String urgencyLevel) {
    final sectionNumber = _extractSectionNumber(title);

    Color urgencyColor;
    Color bgColor;
    IconData urgencyIcon;
    String urgencyText = '';

    switch (urgencyLevel) {
      case 'high':
        urgencyColor = AppTheme.dangerColor;
        bgColor = AppTheme.dangerColor.withOpacity(0.08);
        urgencyIcon = Icons.warning_amber_rounded;
        urgencyText = 'Alta';
        break;
      case 'medium':
        urgencyColor = AppTheme.warningColor;
        bgColor = AppTheme.warningColor.withOpacity(0.08);
        urgencyIcon = Icons.info_outline;
        urgencyText = 'Media';
        break;
      default:
        urgencyColor = AppTheme.successColor;
        bgColor = AppTheme.successColor.withOpacity(0.08);
        urgencyIcon = Icons.check_circle_outline;
        urgencyText = 'Routine';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title, sectionNumber),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: urgencyColor.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(urgencyIcon, color: urgencyColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: urgencyColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: urgencyColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              urgencyText,
                              style: GoogleFonts.montserrat(
                                color: urgencyColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (content.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          content,
                          style: GoogleFonts.workSans(
                            fontSize: 15,
                            height: 1.5,
                            color: AppTheme.neutralDarkColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Add this extension method to support truncation of UUID if needed
extension StringExtensions on String {
  String truncateWithEllipsis(int maxLength) {
    return (length <= maxLength)
        ? this
        : '${substring(0, maxLength)}...';
  }
}