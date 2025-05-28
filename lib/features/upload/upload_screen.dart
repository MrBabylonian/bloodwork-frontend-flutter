import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// UploadScreen allows the user to select and (mock) upload a PDF.
/// This version works on all platforms and simulates the upload step.
class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String? _selectedFileName;
  PlatformFile? _pickedFile;
  bool _isUploading = false;

  /// Opens a native file picker restricted to PDF files.
  Future<void> _pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb, // For Web: load file bytes into memory
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
        _selectedFileName = _pickedFile!.name;
      });
    }
  }

  /// Simulates uploading the PDF file.
  /// After a fake delay, navigates to /loading with a mock UUID.
  Future<void> _uploadPdfFile() async {
    if (_pickedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Simulate a network call delay (2 seconds)
      await Future.delayed(const Duration(seconds: 2));

      // Use a fake UUID for mocking
      const String fakeUuid = 'mock-uuid-1234567890';

      // Navigate to the loading screen, passing the fake UUID
      if (context.mounted) {
        debugPrint('Navigating to /loading');
        Navigator.pushNamed(
          context,
          '/loading',
          arguments: fakeUuid,
        );
      }
    } catch (e) {
      debugPrint('Mock upload error: $e');
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

  /// Main UI layout
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
              // Display file name or prompt
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

              // "Scegli File PDF" button
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickPdfFile,
                icon: const Icon(Icons.attach_file),
                label: const Text('Scegli File PDF'),
              ),

              const SizedBox(height: 16),

              // Show spinner or "Carica e Analizza" button
              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                onPressed: (_pickedFile == null || _isUploading)
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
