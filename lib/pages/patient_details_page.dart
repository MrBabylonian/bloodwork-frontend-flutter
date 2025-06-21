import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';
import '../components/buttons/index.dart';
import '../components/navigation/app_header.dart';
import '../components/navigation/app_tabs.dart';
import '../components/cards/info_card.dart';
import '../components/display/badge.dart';
import '../core/providers/patient_provider.dart';
import '../core/models/patient_models.dart';
import '../core/services/logout_service.dart';
import '../utils/auth_utils.dart';

/// Blood work finding model
class BloodworkFinding {
  final String parameter;
  final String value;
  final String unit;
  final String range;
  final String status;

  const BloodworkFinding({
    required this.parameter,
    required this.value,
    required this.unit,
    required this.range,
    required this.status,
  });
}

/// Blood work result model
class BloodworkResult {
  final String id;
  final DateTime date;
  final String type;
  final String status;
  final String summary;
  final List<BloodworkFinding> findings;

  const BloodworkResult({
    required this.id,
    required this.date,
    required this.type,
    required this.status,
    required this.summary,
    required this.findings,
  });
}

/// Medical history entry model
class MedicalHistoryEntry {
  final String title;
  final DateTime date;
  final String description;

  const MedicalHistoryEntry({
    required this.title,
    required this.date,
    required this.description,
  });
}

/// Patient Details page showing comprehensive patient information
class PatientDetailsPage extends StatefulWidget {
  final String patientId;

  const PatientDetailsPage({super.key, required this.patientId});

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  PatientModel? _patient;
  bool _isLoading = true;
  String? _errorMessage;
  late List<BloodworkResult> _bloodworkResults;
  late List<MedicalHistoryEntry> _medicalHistory;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );
      final patient = await patientProvider.getPatientById(widget.patientId);

      if (patient != null) {
        setState(() {
          _patient = patient;
          _isLoading = false;
        });
        _loadMockAnalysisData(); // For now, keep mock analysis data
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Patient not found';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading patient: $e';
      });
    }
  }

  void _loadMockAnalysisData() {
    // Mock bloodwork results (keep for now until we connect to analysis API)
    _bloodworkResults = [
      // Check if diagnostic summary exists and has data
      if (_patient!.diagnosticSummary.isNotEmpty)
        BloodworkResult(
          id: "1",
          date: _patient!.updatedAt,
          type: "Analisi Disponibile",
          status: "normal",
          summary: "Dati di analisi salvati nel sistema",
          findings: [
            const BloodworkFinding(
              parameter: "Stato Analisi",
              value: "Disponibile",
              unit: "",
              range: "",
              status: "normal",
            ),
          ],
        ),
    ];

    // Real medical history from patient data
    _medicalHistory = [
      MedicalHistoryEntry(
        title: "Creazione Paziente",
        date: _patient!.createdAt,
        description:
            "Paziente registrato nel sistema${_patient!.diagnosticSummary.isNotEmpty ? ' con dati di analisi.' : '. In attesa di analisi.'}",
      ),
      if (_patient!.medicalHistory.isNotEmpty)
        ...(_patient!.medicalHistory.entries.map(
          (entry) => MedicalHistoryEntry(
            title: entry.key,
            date: _patient!.updatedAt, // Use updated date as fallback
            description: entry.value.toString(),
          ),
        )),
    ];
  }

  AppBadgeVariant _getStatusVariant(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return AppBadgeVariant.success;
      case 'attention':
        return AppBadgeVariant.warning;
      case 'high':
        return AppBadgeVariant.destructive;
      case 'healthy':
        return AppBadgeVariant.success;
      default:
        return AppBadgeVariant.secondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return CupertinoIcons.checkmark_circle_fill;
      case 'attention':
        return CupertinoIcons.exclamationmark_triangle_fill;
      case 'high':
        return CupertinoIcons.arrow_up_circle_fill;
      case 'healthy':
        return CupertinoIcons.heart_fill;
      default:
        return CupertinoIcons.circle_fill;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return 'Normale';
      case 'attention':
        return 'Attenzione';
      case 'high':
        return 'Alto';
      case 'healthy':
        return 'Sano';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
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
            title: Text("Dettagli Paziente", style: AppTextStyles.title2),
            showAuth: true,
            onProfileTap: () => context.go('/profile'),
            onLogoutTap: () => LogoutService.showLogoutDialog(context),
          ),

          // Content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(),
            SizedBox(height: 16),
            Text('Caricamento paziente...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 48,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: CupertinoColors.systemRed),
            ),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              child: const Text('Riprova'),
              onPressed: () => _loadPatientData(),
            ),
          ],
        ),
      );
    }

    if (_patient == null) {
      return const Center(child: Text('Paziente non trovato'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back to Dashboard button
            SecondaryButton(
              onPressed: () => context.go('/dashboard'),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.back, size: 16),
                  SizedBox(width: AppDimensions.spacingXs),
                  Text("Torna alla Dashboard"),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // Patient Header Card
            _buildPatientHeader(),

            const SizedBox(height: AppDimensions.spacingL),

            // Tabs
            SizedBox(
              height: 800, // Fixed height for tabs content
              child: AppTabs(
                tabAlignment: Alignment.center,
                tabs: const [
                  AppTab(
                    id: 'results',
                    label: 'Risultati Analisi',
                    icon: CupertinoIcons.doc_text,
                  ),
                  AppTab(
                    id: 'history',
                    label: 'Storia Medica',
                    icon: CupertinoIcons.time,
                  ),
                  AppTab(
                    id: 'trends',
                    label: 'Tendenze',
                    icon: CupertinoIcons.graph_square,
                  ),
                ],
                children: [
                  _buildResultsTab(),
                  _buildHistoryTab(),
                  _buildTrendsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with name, status, and actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and status
                    Row(
                      children: [
                        Text(_patient!.name, style: AppTextStyles.title1),
                        const SizedBox(width: AppDimensions.spacingM),
                        AppBadge(
                          label: _patient!.isActive ? 'Attivo' : 'Inattivo',
                          variant:
                              _patient!.isActive
                                  ? AppBadgeVariant.success
                                  : AppBadgeVariant.secondary,
                          icon:
                              _patient!.isActive
                                  ? CupertinoIcons.checkmark_circle_fill
                                  : CupertinoIcons.circle_fill,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingL),
                  ],
                ),
              ),
              // Upload button
              PrimaryButton(
                onPressed: () => context.go('/upload/${widget.patientId}'),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.cloud_upload, size: 16),
                    SizedBox(width: AppDimensions.spacingXs),
                    Text("Carica Nuovo Test"),
                  ],
                ),
              ),
            ],
          ),

          // Patient details grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 768;

              if (isWide) {
                // Three-column layout for desktop
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildOwnerInfo()),
                    const SizedBox(width: AppDimensions.spacingL),
                    Expanded(child: _buildPatientInfo()),
                    const SizedBox(width: AppDimensions.spacingL),
                    Expanded(child: _buildVisitInfo()),
                  ],
                );
              } else {
                // Stacked layout for mobile
                return Column(
                  children: [
                    _buildOwnerInfo(),
                    const SizedBox(height: AppDimensions.spacingL),
                    _buildPatientInfo(),
                    const SizedBox(height: AppDimensions.spacingL),
                    _buildVisitInfo(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Informazioni Proprietario",
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        _buildInfoRow("Nome", _patient!.ownerInfo.name),
        _buildInfoRow("Telefono", _patient!.ownerInfo.phone),
        _buildInfoRow("Email", _patient!.ownerInfo.email),
      ],
    );
  }

  Widget _buildPatientInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Dettagli Paziente",
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        _buildInfoRow("Specie", _patient!.species),
        _buildInfoRow("Razza", _patient!.breed),
        _buildInfoRow("Età", _patient!.age.toString()),
        _buildInfoRow("Sesso", _patient!.sex),
        _buildInfoRow(
          "Peso",
          _patient!.weight != null
              ? "${_patient!.weight!.toStringAsFixed(1)} kg"
              : "Non specificato",
        ),
      ],
    );
  }

  Widget _buildVisitInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Informazioni Visite",
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        _buildInfoRow("Data Creazione", _formatDate(_patient!.createdAt)),
        _buildInfoRow("Ultimo Aggiornamento", _formatDate(_patient!.updatedAt)),
        _buildInfoRow("ID Paziente", _patient!.patientId),
        _buildInfoRow("Totale Test", "${_bloodworkResults.length}"),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.body)),
        ],
      ),
    );
  }

  Widget _buildResultsTab() {
    if (_bloodworkResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              child: const Icon(
                CupertinoIcons.doc_text,
                color: AppColors.primaryBlue,
                size: 40,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Text("Nessuna Analisi Disponibile", style: AppTextStyles.title3),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              "Non ci sono ancora risultati di analisi per questo paziente.",
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingL),
            PrimaryButton(
              onPressed: () => context.go('/upload/${widget.patientId}'),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.cloud_upload, size: 16),
                  SizedBox(width: AppDimensions.spacingXs),
                  Text("Carica Prima Analisi"),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Column(
        children:
            _bloodworkResults.asMap().entries.map((entry) {
              final index = entry.key;
              final result = entry.value;
              return Container(
                margin: EdgeInsets.only(
                  bottom:
                      index < _bloodworkResults.length - 1
                          ? AppDimensions.spacingL
                          : 0,
                ),
                child: _buildResultCard(result),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildResultCard(BloodworkResult result) {
    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                ),
                child: const Icon(
                  CupertinoIcons.doc_text,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.type, style: AppTextStyles.title3),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.calendar,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppDimensions.spacingXs),
                        Text(
                          _formatDate(result.date),
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppBadge(
                label: _getStatusLabel(result.status),
                variant: _getStatusVariant(result.status),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              SecondaryButton(
                size: ButtonSize.small,
                onPressed: () {
                  // TODO: Implement download functionality
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.cloud_download, size: 14),
                    SizedBox(width: AppDimensions.spacingXs),
                    Text("Scarica"),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingL),

          // Summary
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Riepilogo",
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                result.summary,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingL),

          // Detailed Results Table
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Risultati Dettagliati",
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppDimensions.spacingM),
              _buildResultsTable(result.findings),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTable(List<BloodworkFinding> findings) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusMedium),
                topRight: Radius.circular(AppDimensions.radiusMedium),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Parametro",
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Valore",
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Range",
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Stato",
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table rows
          ...findings.asMap().entries.map((entry) {
            final index = entry.key;
            final finding = entry.value;
            return Container(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              decoration: BoxDecoration(
                border:
                    index < findings.length - 1
                        ? const Border(
                          bottom: BorderSide(color: AppColors.borderGray),
                        )
                        : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      finding.parameter,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${finding.value} ${finding.unit}",
                      style: AppTextStyles.body,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      finding.range,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(finding.status),
                          size: 16,
                          color: _getStatusColor(finding.status),
                        ),
                        const SizedBox(width: AppDimensions.spacingXs),
                        Text(
                          _getStatusLabel(finding.status),
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return AppColors.successGreen;
      case 'attention':
        return AppColors.warningOrange;
      case 'high':
        return AppColors.destructiveRed;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: InfoCard(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Storia Medica", style: AppTextStyles.title3),
            const SizedBox(height: AppDimensions.spacingL),
            ..._medicalHistory.map(
              (entry) => Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                padding: const EdgeInsets.all(AppDimensions.spacingM),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.title,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatDate(entry.date),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      entry.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsTab() {
    return Center(
      child: InfoCard(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.graph_square,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text("Analisi Tendenze", style: AppTextStyles.title3),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              "L'analisi delle tendenze sarà disponibile con più risultati di test nel tempo.",
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
