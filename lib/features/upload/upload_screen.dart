import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// @formatter:on
/// UploadScreen allows the user to select and upload a PDF.
/// Works across Web, Mobile, and Desktop.
class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String? _selectedFileName;
  PlatformFile? _pickedFile;
  bool _isUploading = false;

  Future<void> _pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb, // Required on Web
    );

    if (result != null && result.files.isNotEmpty) {
      final picked = result.files.first;

      // Read first 5 bytes (PDF magic number should be '%PDF-')
      final bytes = picked.bytes;
      if (bytes == null || bytes.length < 5) {
        _showInvalidFileSnackBar();
        return;
      }

      final isPdfHeader =
          bytes[0] == 0x25 && // %
          bytes[1] == 0x50 && // P
          bytes[2] == 0x44 && // D
          bytes[3] == 0x46 && // F
          bytes[4] == 0x2D; // -

      if (!isPdfHeader) {
        _showInvalidFileSnackBar();
        return;
      }

      setState(() {
        _pickedFile = picked;
        _selectedFileName = picked.name;
      });
    }
  }

  Future<void> _uploadPdfFile() async {
    if (_pickedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      const String kBaseUrl =
          kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';
      final uri = Uri.parse('$kBaseUrl/analysis/pdf_analysis');

      final request = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            _pickedFile!.bytes!,
            filename: _pickedFile!.name,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      } else {
        final file = File(_pickedFile!.path!);
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String pdfUuid = data['pdf_uuid'];

        if (context.mounted) {
          Navigator.pushNamed(context, '/loading', arguments: pdfUuid);
        }
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore durante il caricamento.')),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showInvalidFileSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Il file selezionato non è un PDF valido.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analisi Referto PDF'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedFileName != null)
                Text(
                  'File selezionato:\n$_selectedFileName',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                Text(
                  'Seleziona un referto PDF da analizzare',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickPdfFile,
                icon: const Icon(Icons.attach_file),
                label: const Text('Scegli File PDF'),
              ),
              const SizedBox(height: 16),
              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                    onPressed:
                        (_pickedFile == null || _isUploading)
                            ? null
                            : _uploadPdfFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Carica e Analizza'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
