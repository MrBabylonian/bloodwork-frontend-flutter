// ignore_for_file: prefer_final_fields

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../buttons/secondary_button.dart';
import '../buttons/app_button.dart';

/// A file upload component that allows users to select PDF files and images.
///
/// This component provides a user-friendly interface for selecting
/// PDF files and images for analysis, with drag & drop support on web and
/// file picker support on all platforms.
class FileUploadField extends StatefulWidget {
  /// Creates a file upload field with the specified properties.
  const FileUploadField({
    super.key,
    required this.onFileSelected,
    this.label,
    this.errorText,
    this.maxFileSizeMB = 50,
    this.isLoading = false,
  });

  /// Called when files are selected.
  final Function(List<PlatformFile>) onFileSelected;

  /// Optional label displayed above the upload area.
  final String? label;

  /// Error text to display when there's an issue with the file selection.
  final String? errorText;

  /// Maximum allowed file size in MB
  final int maxFileSizeMB;

  /// Whether file upload is in progress.
  final bool isLoading;

  @override
  State<FileUploadField> createState() => _FileUploadFieldState();
}

class _FileUploadFieldState extends State<FileUploadField> {
  List<PlatformFile> _selectedFiles = [];

  bool _isDragging = false;

  /// Returns the appropriate icon based on file extension
  IconData _getIconForFile(PlatformFile file) {
    final extension = file.extension?.toLowerCase() ?? '';

    if (extension == 'pdf') {
      return CupertinoIcons.doc_fill;
    } else if ([
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'heic',
    ].contains(extension)) {
      return CupertinoIcons.photo_fill;
    } else {
      return CupertinoIcons.doc;
    }
  }

  /// Determines if a file is an image based on its extension
  bool _isImageFile(String? extension) {
    return [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'heic',
    ].contains(extension?.toLowerCase() ?? '');
  }

  Future<void> _pickFiles(FileType fileType) async {
    try {
      // Determine allowed extensions and multiple selection based on file type
      List<String> extensions;
      bool allowMultiple;

      if (fileType == FileType.image) {
        extensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'];
        allowMultiple = true;
      } else {
        extensions = ['pdf'];
        allowMultiple = false;
      }

      // Use FilePicker to select files at their original quality
      // No compression is applied to maintain highest possible resolution
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
        allowMultiple: allowMultiple,
      );

      if (result != null) {
        // Check file size
        final validFiles =
            result.files.where((file) {
              final fileSizeInMB = file.size / (1024 * 1024);
              return fileSizeInMB <= widget.maxFileSizeMB;
            }).toList();

        if (validFiles.isNotEmpty) {
          setState(() {
            if (fileType == FileType.image) {
              // For images: add to existing selection
              _selectedFiles = [..._selectedFiles, ...validFiles];
            } else {
              // For PDF: replace any existing PDF with the new one
              // Remove existing PDFs first
              _selectedFiles =
                  _selectedFiles
                      .where((file) => _isImageFile(file.extension))
                      .toList();
              // Then add the new PDF
              _selectedFiles = [..._selectedFiles, ...validFiles];
            }
          });
          widget.onFileSelected(_selectedFiles);
        }
      }
    } catch (e) {
      debugPrint('Errore nella selezione dei file: $e');
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
    widget.onFileSelected(_selectedFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingXs),
            child: Text(widget.label!, style: AppTextStyles.formLabel),
          ),
        ],

        // Upload area
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(
              color:
                  widget.errorText != null
                      ? AppColors.destructiveRed
                      : _isDragging
                      ? AppColors.primaryBlue
                      : AppColors.borderGray,
              width:
                  _isDragging
                      ? AppDimensions.borderWidthLarge
                      : AppDimensions.borderWidth,
            ),
          ),
          child:
              widget.isLoading
                  ? const SizedBox(
                    height: 150,
                    child: Center(child: CupertinoActivityIndicator()),
                  )
                  : Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacingM),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // File selection buttons
                        if (_selectedFiles.isEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SecondaryButton(
                                onPressed: () => _pickFiles(FileType.image),
                                child: Row(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.photo_fill,
                                      color: AppColors.primaryBlue,
                                      size: AppDimensions.iconSizeSmall,
                                    ),
                                    const SizedBox(
                                      width: AppDimensions.spacingXs,
                                    ),
                                    const Text('Seleziona Immagini'),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spacingM),
                              SecondaryButton(
                                onPressed: () => _pickFiles(FileType.any),
                                child: Row(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.doc_fill,
                                      color: AppColors.primaryBlue,
                                      size: AppDimensions.iconSizeSmall,
                                    ),
                                    const SizedBox(
                                      width: AppDimensions.spacingXs,
                                    ),
                                    const Text('Seleziona PDF'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.spacingM),
                          Text(
                            'Puoi selezionare più immagini o un singolo PDF',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.mediumGray,
                            ),
                          ),
                        ],

                        // Selected files list
                        if (_selectedFiles.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'File Selezionati (${_selectedFiles.length})',
                                style: AppTextStyles.title3,
                              ),
                              Row(
                                children: [
                                  SecondaryButton(
                                    size: AppButtonSize.small,
                                    onPressed: () => _pickFiles(FileType.image),
                                    child: const Text('Aggiungi Immagini'),
                                  ),
                                  if (!_selectedFiles.any(
                                    (f) => f.extension?.toLowerCase() == 'pdf',
                                  )) ...[
                                    const SizedBox(
                                      width: AppDimensions.spacingS,
                                    ),
                                    SecondaryButton(
                                      size: AppButtonSize.small,
                                      onPressed: () => _pickFiles(FileType.any),
                                      child: const Text('Aggiungi PDF'),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.spacingM),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _selectedFiles.length,
                              itemBuilder: (context, index) {
                                final file = _selectedFiles[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppDimensions.spacingS,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getIconForFile(file),
                                        color: AppColors.primaryBlue,
                                      ),
                                      const SizedBox(
                                        width: AppDimensions.spacingS,
                                      ),
                                      Expanded(
                                        child: Text(
                                          file.name,
                                          style: AppTextStyles.body,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${(file.size / (1024 * 1024)).toStringAsFixed(1)} MB',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.mediumGray,
                                        ),
                                      ),
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () => _removeFile(index),
                                        child: const Icon(
                                          CupertinoIcons.xmark_circle_fill,
                                          color: AppColors.mediumGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
        ),

        if (widget.errorText != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.spacingXs),
            child: Text(
              widget.errorText!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.destructiveRed,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
