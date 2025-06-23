import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';
import '../components/buttons/index.dart';
import '../components/navigation/app_header.dart';
import '../components/cards/info_card.dart';
import '../components/forms/file_upload.dart';
import '../components/feedback/app_progress_indicator.dart';
import '../core/providers/analysis_provider.dart';
import '../components/dialogs/app_custom_dialog.dart';
import '../core/services/logout_service.dart';
import '../utils/auth_utils.dart';

/// Upload page for analyzing bloodwork files
class UploadPage extends StatefulWidget {
  final String? patientId;

  const UploadPage({super.key, this.patientId});

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

    // Show warning if non-PDF files are selected
    final nonPdfFiles =
        files.where((file) => file.extension?.toLowerCase() != 'pdf').toList();

    if (nonPdfFiles.isNotEmpty) {
      final fileNames = nonPdfFiles.map((f) => f.name).join(', ');
      _showErrorDialog(
        "Attenzione: I file non-PDF ($fileNames) non possono essere caricati al momento. Solo i file PDF sono supportati per l'analisi.",
      );
    }
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

  void _handleUpload() async {
    if (_selectedFiles.isEmpty) {
      _showErrorDialog("Seleziona dei file da caricare");
      return;
    }

    // Filter only PDF files for upload
    final pdfFiles =
        _selectedFiles
            .where((file) => file.extension?.toLowerCase() == 'pdf')
            .toList();

    if (pdfFiles.isEmpty) {
      _showErrorDialog(
        "Nessun file PDF selezionato. Solo i file PDF possono essere caricati al momento.",
      );
      return;
    }

    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      final analysisProvider = Provider.of<AnalysisProvider>(
        context,
        listen: false,
      );

      // Upload each PDF file
      bool allUploadsSuccessful = true;

      for (final platformFile in pdfFiles) {
        final response = await analysisProvider.uploadPdfFile(
          file: platformFile,
          patientId: widget.patientId,
        );

        if (response == null) {
          allUploadsSuccessful = false;
          break;
        }

        // Update progress for each file
        setState(() {
          _uploadProgress += 1.0 / pdfFiles.length;
        });
      }

      setState(() {
        _isUploading = false;
        _uploadProgress = 1.0;
      });

      if (allUploadsSuccessful) {
        _showSuccessDialog("File PDF caricati e analizzati con successo!");
        // Navigate back to patient details or dashboard
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            if (widget.patientId != null) {
              context.go('/patient/${widget.patientId}');
            } else {
              context.go('/dashboard');
            }
          }
        });
      } else {
        _showErrorDialog(
          analysisProvider.errorMessage ?? "Errore durante il caricamento",
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      _showErrorDialog("Errore durante il caricamento: $e");
    }
  }

  void _showSuccessDialog(String message) {
    showSuccessDialog(context: context, message: message);
  }

  void _showErrorDialog(String message) {
    showErrorDialog(context: context, message: message);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  @override
  Widget build(BuildContext context) {
    // Simple auth check - show login screen if not authenticated
    if (!AuthUtils.isAuthenticated(context)) {
      return AuthUtils.buildLoginRequiredScreen(context);
    }

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundWhite,
      child: Column(
        children: [
          // Header
          AppHeader(
            title: const Text("Carica File", style: AppTextStyles.title2),
            showAuth: true,
            onProfileTap: () => context.go('/profile'),
            onLogoutTap: () => LogoutService.showLogoutDialog(context),
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
                      "Carica report PDF per analisi alimentata da IA",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingM,
                        vertical: AppDimensions.spacingS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSmall,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.info_circle,
                            size: 16,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: AppDimensions.spacingXs),
                          Text(
                            "Al momento supportiamo solo file PDF. Upload immagini in arrivo!",
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingXl),

                    // Upload Area
                    InfoCard(
                      padding: const EdgeInsets.all(AppDimensions.spacingXl),
                      child: FileUploadField(
                        onFileSelected: _handleFileSelected,
                        label: "Trascina e rilascia i tuoi file PDF qui",
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
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "File Selezionati (${_selectedFiles.length})",
                                          style: AppTextStyles.body.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Builder(
                                          builder: (context) {
                                            final pdfCount =
                                                _selectedFiles
                                                    .where(
                                                      (f) =>
                                                          f.extension
                                                              ?.toLowerCase() ==
                                                          'pdf',
                                                    )
                                                    .length;
                                            return Text(
                                              "$pdfCount PDF pronti per il caricamento",
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                            );
                                          },
                                        ),
                                      ],
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

                            // File list with PDF/non-PDF indicators
                            ..._selectedFiles.asMap().entries.map((entry) {
                              final index = entry.key;
                              final file = entry.value;
                              final isPdf =
                                  file.extension?.toLowerCase() == 'pdf';

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
                                  color:
                                      isPdf
                                          ? AppColors.backgroundSecondary
                                              .withValues(alpha: 0.5)
                                          : AppColors.destructiveRed.withValues(
                                            alpha: 0.1,
                                          ),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMedium,
                                  ),
                                  border:
                                      !isPdf
                                          ? Border.all(
                                            color: AppColors.destructiveRed
                                                .withValues(alpha: 0.3),
                                            width: 1,
                                          )
                                          : null,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getFileIcon(file.extension ?? ''),
                                      size: 20,
                                      color:
                                          isPdf
                                              ? AppColors.primaryBlue
                                              : AppColors.destructiveRed,
                                    ),
                                    const SizedBox(
                                      width: AppDimensions.spacingM,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  file.name,
                                                  style: AppTextStyles.body
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            isPdf
                                                                ? null
                                                                : AppColors
                                                                    .destructiveRed,
                                                      ),
                                                ),
                                              ),
                                              if (!isPdf) ...[
                                                const SizedBox(
                                                  width:
                                                      AppDimensions.spacingXs,
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal:
                                                            AppDimensions
                                                                .spacingXs,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        AppColors
                                                            .destructiveRed,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          AppDimensions
                                                              .radiusSmall,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'NON SUPPORTATO',
                                                    style: AppTextStyles.caption
                                                        .copyWith(
                                                          color:
                                                              AppColors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          Text(
                                            _formatFileSize(file.size),
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color:
                                                      isPdf
                                                          ? AppColors
                                                              .textSecondary
                                                          : AppColors
                                                              .destructiveRed
                                                              .withValues(
                                                                alpha: 0.8,
                                                              ),
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
