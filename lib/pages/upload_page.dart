import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';
import '../components/buttons/index.dart';
import '../components/navigation/app_header.dart';
import '../components/cards/info_card.dart';
import '../components/forms/file_upload.dart';
import '../components/feedback/app_progress_indicator.dart';

/// Upload page for analyzing bloodwork files
class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  List<PlatformFile> _selectedFiles = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  Timer? _progressTimer;

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  void _handleFileSelected(List<PlatformFile> files) {
    setState(() {
      _selectedFiles = files;
    });
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _clearAllFiles() {
    setState(() {
      _selectedFiles.clear();
    });
  }

  void _handleUpload() {
    if (_selectedFiles.isEmpty) {
      _showErrorDialog("Seleziona dei file da caricare");
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    // Simulate upload progress
    _progressTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        _uploadProgress += 0.1;
        if (_uploadProgress >= 1.0) {
          _uploadProgress = 1.0;
          timer.cancel();
          _isUploading = false;
          _showSuccessDialog("File caricati e analizzati con successo!");
          // Navigate to dashboard after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              context.go('/dashboard');
            }
          });
        }
      });
    });
  }

  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => _buildCustomDialog(
            context: context,
            title: 'Successo',
            message: message,
            isError: false,
          ),
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => _buildCustomDialog(
            context: context,
            title: 'Errore',
            message: message,
            isError: true,
          ),
    );
  }

  /// Custom dialog that matches the desktop web design
  Widget _buildCustomDialog({
    required BuildContext context,
    required String title,
    required String message,
    required bool isError,
  }) {
    return Center(
      child: Container(
        width: 400,
        margin: const EdgeInsets.all(AppDimensions.spacingL),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppColors.foregroundDark.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingL),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color:
                          isError
                              ? AppColors.destructiveRed.withValues(alpha: 0.1)
                              : AppColors.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                    ),
                    child: Icon(
                      isError
                          ? CupertinoIcons.xmark_circle_fill
                          : CupertinoIcons.checkmark_circle_fill,
                      color:
                          isError
                              ? AppColors.destructiveRed
                              : AppColors.successGreen,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Text(
                    title,
                    style: AppTextStyles.title2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    message,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              height: 1,
              color: AppColors.borderGray.withValues(alpha: 0.3),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingL),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundWhite,
      child: Column(
        children: [
          // Header
          AppHeader(
            title: const Text("Carica File", style: AppTextStyles.title2),
            showBackButton: true,
            onLogoutTap: () => context.go('/login'),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacingL),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1024),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Page Title
                    Text(
                      "Carica File Analisi Sangue",
                      style: AppTextStyles.title1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      "Carica report PDF o immagini per analisi alimentata da IA",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppDimensions.spacingXl),

                    // Upload Area
                    InfoCard(
                      padding: const EdgeInsets.all(AppDimensions.spacingXl),
                      child: FileUploadField(
                        onFileSelected: _handleFileSelected,
                        label: "Trascina e rilascia i tuoi file qui",
                        maxFileSizeMB: 10,
                        isLoading: _isUploading,
                      ),
                    ),

                    if (_selectedFiles.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.spacingL),

                      // Selected Files List
                      InfoCard(
                        padding: const EdgeInsets.all(AppDimensions.spacingL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.doc_text,
                                      size: 20,
                                      color: AppColors.primaryBlue,
                                    ),
                                    const SizedBox(
                                      width: AppDimensions.spacingS,
                                    ),
                                    Text(
                                      "File Selezionati (${_selectedFiles.length})",
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                if (!_isUploading)
                                  GhostButton(
                                    size: ButtonSize.small,
                                    onPressed: _clearAllFiles,
                                    child: const Text("Rimuovi Tutti"),
                                  ),
                              ],
                            ),

                            const SizedBox(height: AppDimensions.spacingM),

                            // File list
                            ..._selectedFiles.asMap().entries.map((entry) {
                              final index = entry.key;
                              final file = entry.value;
                              return Container(
                                margin: EdgeInsets.only(
                                  bottom:
                                      index < _selectedFiles.length - 1
                                          ? AppDimensions.spacingS
                                          : 0,
                                ),
                                padding: const EdgeInsets.all(
                                  AppDimensions.spacingM,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundSecondary
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMedium,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getFileIcon(file.extension ?? ''),
                                      size: 20,
                                      color: AppColors.primaryBlue,
                                    ),
                                    const SizedBox(
                                      width: AppDimensions.spacingM,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            file.name,
                                            style: AppTextStyles.body.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            _formatFileSize(file.size),
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!_isUploading)
                                      GhostButton(
                                        size: ButtonSize.small,
                                        onPressed: () => _removeFile(index),
                                        child: const Icon(
                                          CupertinoIcons.xmark,
                                          size: 16,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],

                    if (_isUploading) ...[
                      const SizedBox(height: AppDimensions.spacingL),

                      // Upload Progress
                      InfoCard(
                        padding: const EdgeInsets.all(AppDimensions.spacingL),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Caricamento file...",
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "${(_uploadProgress * 100).toInt()}%",
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.spacingM),
                            AppProgressIndicator(
                              value: _uploadProgress,
                              height: 8,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppDimensions.spacingXl),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SecondaryButton(
                          onPressed:
                              _isUploading
                                  ? null
                                  : () => context.go('/dashboard'),
                          child: const Text("Annulla"),
                        ),
                        const SizedBox(width: AppDimensions.spacingM),
                        PrimaryButton(
                          onPressed:
                              (_selectedFiles.isEmpty || _isUploading)
                                  ? null
                                  : _handleUpload,
                          child: Text(
                            _isUploading ? "Caricamento..." : "Analizza File",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spacingXxl),

                    // Info Cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 600;

                        if (isWide) {
                          return Row(
                            children: [
                              Expanded(child: _buildSupportedFormatsCard()),
                              const SizedBox(width: AppDimensions.spacingL),
                              Expanded(child: _buildProcessingTimeCard()),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              _buildSupportedFormatsCard(),
                              const SizedBox(height: AppDimensions.spacingL),
                              _buildProcessingTimeCard(),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return CupertinoIcons.doc_text;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return CupertinoIcons.photo;
      default:
        return CupertinoIcons.doc;
    }
  }

  Widget _buildSupportedFormatsCard() {
    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: const Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: AppColors.successGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Formati Supportati",
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  "Report PDF, immagini JPEG/PNG. Massimo 10MB per file.",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingTimeCard() {
    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.warningOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: const Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              color: AppColors.warningOrange,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tempi di Elaborazione",
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  "L'analisi si completa tipicamente entro 30-60 secondi.",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
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
