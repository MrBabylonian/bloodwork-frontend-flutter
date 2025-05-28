import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

/// This screen lets the user pick a PDF and upload it to the backend.
class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String? _selectedFileName; // Shows which file was picked
  PlatformFile? _pickedFile; // Stores the actual file object
  bool _isUploading = false; // Toggles loading spinner during upload

  /// Method to open the file picker and allow PDF selection
  Future<void> _pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Accept only PDFs
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
        _selectedFileName = _pickedFile!.name;
      });
    }
  }

  /// Simulates uploading the file to the backend
  Future<void> _uploadPdfFile() async {
    if (_pickedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // TODO: Replace with actual HTTP POST call to backend
      await Future.delayed(const Duration(seconds: 2));

      // Show dialog or navigate to result screen here
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("File caricato con successo!")),
        );
      }

      // TODO: Navigate to result screen and pass UUID or data
    } catch (e) {
      debugPrint("Upload error: $e");
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analisi Referto PDF"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// PDF File Info or Prompt
              if (_selectedFileName != null)
                Text(
                  "File selezionato:\n$_selectedFileName",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                Text(
                  "Seleziona un referto PDF da analizzare",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

              const SizedBox(height: 24),

              /// Select Button
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickPdfFile,
                icon: const Icon(Icons.attach_file),
                label: const Text("Scegli File PDF"),
              ),

              const SizedBox(height: 16),

              /// Upload Button or SpinnerAn
              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                    onPressed: (_pickedFile == null || _isUploading ) ? null : _uploadPdfFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Carica e Analizza"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
