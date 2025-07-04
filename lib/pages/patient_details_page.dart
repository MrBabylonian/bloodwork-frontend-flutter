import 'package:flutter/material.dart' hide IconButton;
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
import '../core/providers/analysis_provider.dart';
import '../core/models/analysis_models.dart';
import '../core/services/logout_service.dart';
import '../utils/auth_utils.dart';
import '../components/dialogs/update_patient_modal.dart';

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

/// Diagnostic plan item
class DiagnosticPlanItem {
  final String exam;
  final String priority;
  final String invasiveness;

  const DiagnosticPlanItem({
    required this.exam,
    required this.priority,
    required this.invasiveness,
  });
}

/// Treatment item
class TreatmentItem {
  final String name;
  final String? dosage;
  final String? route;
  final String? duration;
  final String type; // 'farmaco', 'supplemento', 'supporto'

  const TreatmentItem({
    required this.name,
    this.dosage,
    this.route,
    this.duration,
    required this.type,
  });
}

/// Differential diagnosis
class DifferentialDiagnosis {
  final String diagnosis;
  final String confidence;

  const DifferentialDiagnosis({
    required this.diagnosis,
    required this.confidence,
  });
}

/// Mathematical analysis result
class MathematicalAnalysis {
  final String name;
  final String value;
  final String interpretation;

  const MathematicalAnalysis({
    required this.name,
    required this.value,
    required this.interpretation,
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

  static String? getUrgencyLevel(Map<String, dynamic>? aiDiagnostic) {
    if (aiDiagnostic != null) {
      final classificazioneUrgenza =
          aiDiagnostic['classificazione_urgenza'] as Map<String, dynamic>?;
      if (classificazioneUrgenza != null) {
        return classificazioneUrgenza['livello'];
      }
    }
    return null;
  }

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  PatientModel? _patient;
  AnalysisResult? _latestAnalysis;
  bool _isLoading = true;
  bool _isLoadingAnalysis = true;
  String? _errorMessage;

  bool _isUpdatePatientModalOpen = false;

  // Processed data for display
  List<BloodworkFinding> _bloodworkFindings = [];
  List<MathematicalAnalysis> _mathematicalAnalyses = [];
  List<String> _clinicalAlterations = [];
  List<DifferentialDiagnosis> _differentialDiagnoses = [];
  Map<String, String> _compatiblePatterns = {};
  List<DiagnosticPlanItem> _diagnosticPlan = [];
  List<TreatmentItem> _treatments = [];
  List<String> _redFlags = [];
  List<MedicalHistoryEntry> _medicalHistory = [];

  String? _diagnosticSummary;
  String? _cytologyReport;
  String? _urgencyLevel;
  String? _urgencyReason;
  String? _followUpPeriod;
  List<String> _monitoringParameters = [];
  String? _ownerEducation;
  String? _prognosis;

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
        _loadAnalysisData();
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

  Future<void> _loadAnalysisData() async {
    try {
      setState(() {
        _isLoadingAnalysis = true;
      });

      final analysisProvider = Provider.of<AnalysisProvider>(
        context,
        listen: false,
      );

      final latestAnalysis = await analysisProvider.getLatestAnalysisForPatient(
        widget.patientId,
      );

      // Always check for pending analysis, regardless of whether there's a latest analysis
      await analysisProvider.checkPendingAnalysis(widget.patientId);

      setState(() {
        _latestAnalysis = latestAnalysis;
        _isLoadingAnalysis = false;
      });

      if (latestAnalysis != null) {
        _processAnalysisData();
      }
    } catch (e) {
      setState(() {
        _isLoadingAnalysis = false;
      });
    }
  }

  void _processAnalysisData() {
    if (_latestAnalysis == null) {
      debugPrint('❌ No analysis found');
      return;
    }

    debugPrint('📊 Processing analysis data for ${_latestAnalysis!.id}');

    // The AI diagnostic data is in the aiDiagnostic field
    final aiDiagnostic = _latestAnalysis!.aiDiagnostic;

    if (aiDiagnostic == null) {
      debugPrint('❌ No aiDiagnostic found in analysis');
      return;
    }

    debugPrint('🔍 AI Diagnostic data keys: ${aiDiagnostic.keys}');

    // Process parameters
    final parametri = aiDiagnostic['parametri'] as List<dynamic>?;
    debugPrint('📋 Parameters found: ${parametri?.length ?? 0}');

    if (parametri != null) {
      _bloodworkFindings =
          parametri.map((param) {
            return BloodworkFinding(
              parameter: param['parametro'] ?? '',
              value: param['valore'] ?? '',
              unit: param['unita'] ?? '',
              range: param['range'] ?? '',
              status: param['stato'] ?? 'normale',
            );
          }).toList();
      debugPrint('✅ Processed ${_bloodworkFindings.length} bloodwork findings');
    } else {
      debugPrint('❌ No parametri found in ai_diagnostic');
    }

    // Process mathematical analysis
    final analisiMatematica =
        aiDiagnostic['analisi_matematica'] as Map<String, dynamic>?;
    if (analisiMatematica != null) {
      _mathematicalAnalyses =
          analisiMatematica.entries.map((entry) {
            final data = entry.value as Map<String, dynamic>;
            return MathematicalAnalysis(
              name: _formatMathAnalysisName(entry.key),
              value: data['valore'] ?? '',
              interpretation: data['interpretazione'] ?? '',
            );
          }).toList();
      debugPrint(
        '✅ Processed ${_mathematicalAnalyses.length} mathematical analyses',
      );
    }

    // Process clinical interpretation
    final interpretazioneClinica =
        aiDiagnostic['interpretazione_clinica'] as Map<String, dynamic>?;
    if (interpretazioneClinica != null) {
      _clinicalAlterations = List<String>.from(
        interpretazioneClinica['alterazioni'] ?? [],
      );

      final diagnosiDifferenziali =
          interpretazioneClinica['diagnosi_differenziali'] as List<dynamic>?;
      if (diagnosiDifferenziali != null) {
        _differentialDiagnoses =
            diagnosiDifferenziali.map((diag) {
              return DifferentialDiagnosis(
                diagnosis: diag['diagnosi'] ?? '',
                confidence: diag['confidenza'] ?? '',
              );
            }).toList();
      }

      // Process compatible patterns
      final patternCompatibili =
          interpretazioneClinica['pattern_compatibili']
              as Map<String, dynamic>?;
      if (patternCompatibili != null) {
        _compatiblePatterns = Map<String, String>.from(patternCompatibili);
      }
    }

    // Process diagnostic plan
    final pianoDiagnostico =
        aiDiagnostic['piano_diagnostico'] as List<dynamic>?;
    if (pianoDiagnostico != null) {
      _diagnosticPlan =
          pianoDiagnostico.map((plan) {
            return DiagnosticPlanItem(
              exam: plan['esame'] ?? '',
              priority: plan['priorita'] ?? '',
              invasiveness: plan['invasivita'] ?? '',
            );
          }).toList();
    }

    // Process treatments
    final terapia = aiDiagnostic['terapia'] as Map<String, dynamic>?;
    if (terapia != null) {
      _treatments = [];

      // Add medications
      final farmaci = terapia['farmaci'] as List<dynamic>?;
      if (farmaci != null) {
        _treatments.addAll(
          farmaci.map((farmaco) {
            return TreatmentItem(
              name: farmaco['nome'] ?? '',
              dosage: farmaco['dosaggio'],
              route: farmaco['via'],
              duration: farmaco['durata'],
              type: 'farmaco',
            );
          }),
        );
      }

      // Add supplements
      final supplementi = terapia['supplementi'] as List<dynamic>?;
      if (supplementi != null) {
        _treatments.addAll(
          supplementi.map((supp) {
            return TreatmentItem(name: supp.toString(), type: 'supplemento');
          }),
        );
      }

      // Add supports
      final supporti = terapia['supporti'] as List<dynamic>?;
      if (supporti != null) {
        _treatments.addAll(
          supporti.map((supp) {
            return TreatmentItem(name: supp.toString(), type: 'supporto');
          }),
        );
      }
    }

    // Process other fields
    _diagnosticSummary = aiDiagnostic['sintesi_diagnostica'];
    _cytologyReport = aiDiagnostic['referto_citologico'];
    _ownerEducation = aiDiagnostic['educazione_proprietario'];

    final classificazioneUrgenza =
        aiDiagnostic['classificazione_urgenza'] as Map<String, dynamic>?;
    if (classificazioneUrgenza != null) {
      _urgencyLevel = classificazioneUrgenza['livello'];
      _urgencyReason = classificazioneUrgenza['motivazione'];
    }

    final followUp = aiDiagnostic['follow_up'] as Map<String, dynamic>?;
    if (followUp != null) {
      _followUpPeriod = followUp['ripetere_esami'];
      _monitoringParameters = List<String>.from(followUp['monitorare'] ?? []);
      _prognosis = followUp['prognosi'];
    }

    _redFlags = List<String>.from(aiDiagnostic['bandierine_rosse'] ?? []);

    // Process medical history
    _medicalHistory = [
      MedicalHistoryEntry(
        title: "Creazione Paziente",
        date: _patient!.createdAt,
        description:
            "Paziente registrato nel sistema${_latestAnalysis != null ? ' con dati di analisi.' : '. In attesa di analisi.'}",
      ),
      if (_latestAnalysis != null)
        MedicalHistoryEntry(
          title: "Ultima Analisi",
          date: _latestAnalysis!.completedAt ?? _latestAnalysis!.createdAt,
          description: _diagnosticSummary ?? "Analisi completata",
        ),
      if (_patient!.medicalHistory.isNotEmpty)
        ...(_patient!.medicalHistory.entries.map(
          (entry) => MedicalHistoryEntry(
            title: entry.key,
            date: _patient!.updatedAt,
            description: entry.value.toString(),
          ),
        )),
    ];

    debugPrint(
      '✅ Data processing complete. Findings: ${_bloodworkFindings.length}, Summary: ${_diagnosticSummary != null}',
    );
  }

  String _formatMathAnalysisName(String key) {
    switch (key) {
      case 'bun_creatinina':
        return 'BUN/Creatinina';
      case 'calcio_fosforo':
        return 'Calcio/Fosforo';
      case 'neutrofili_linfociti':
        return 'Neutrofili/Linfociti';
      case 'na_k':
        return 'Na/K';
      case 'albumina_globuline':
        return 'Albumina/Globuline';
      default:
        return key;
    }
  }

  String _formatPatternName(String key) {
    // Convert snake_case to title case
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'normale':
        return Icons.check_circle;
      case 'alterato_lieve':
        return Icons.warning;
      case 'alterato_grave':
        return Icons.cancel;
      default:
        return Icons.circle;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'normale':
        return 'Normale';
      case 'alterato_lieve':
        return 'Alterato Lieve';
      case 'alterato_grave':
        return 'Alterato Grave';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normale':
        return AppColors.successGreen;
      case 'alterato_lieve':
        return AppColors.warningOrange;
      case 'alterato_grave':
        return AppColors.destructiveRed;
      default:
        return AppColors.textSecondary;
    }
  }

  AppBadgeVariant _getUrgencyVariant(String? urgency) {
    switch (urgency?.toUpperCase()) {
      case 'EMERGENZA':
        return AppBadgeVariant.destructive;
      case 'URGENZA A BREVE':
        return AppBadgeVariant.warning;
      case 'ROUTINE':
        return AppBadgeVariant.success;
      default:
        return AppBadgeVariant.secondary;
    }
  }

  AppBadgeVariant _getPriorityVariant(String priority) {
    switch (priority.toLowerCase()) {
      case 'alta':
        return AppBadgeVariant.destructive;
      case 'media':
        return AppBadgeVariant.warning;
      case 'bassa':
        return AppBadgeVariant.success;
      default:
        return AppBadgeVariant.secondary;
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

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.backgroundWhite,
          body: Column(
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
        ),

        // Update Patient Modal
        if (_patient != null)
          UpdatePatientModal(
            isOpen: _isUpdatePatientModalOpen,
            onClose: () => setState(() => _isUpdatePatientModalOpen = false),
            patient: _patient!,
            onPatientUpdated: () async {
              await _loadPatientData();
            },
          ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
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
            const Icon(Icons.warning, size: 48, color: AppColors.errorRed),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.errorRed),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              onPressed: () => _loadPatientData(),
              child: const Text('Riprova'),
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
                  Icon(Icons.arrow_back, size: 16),
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
                    icon: Icons.description,
                  ),
                  AppTab(
                    id: 'treatment',
                    label: 'Piano Terapeutico',
                    icon: Icons.healing,
                  ),
                  AppTab(
                    id: 'history',
                    label: 'Storia Medica',
                    icon: Icons.schedule,
                  ),
                ],
                children: [
                  _buildResultsTab(),
                  _buildTreatmentTab(),
                  _buildHistoryTab(),
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
                                  ? Icons.check_circle
                                  : Icons.circle,
                        ),
                        if (_urgencyLevel != null) ...[
                          const SizedBox(width: AppDimensions.spacingM),
                          AppBadge(
                            label: _urgencyLevel!,
                            variant: _getUrgencyVariant(_urgencyLevel),
                            icon: Icons.warning,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingL),
                  ],
                ),
              ),
              // Action buttons
              Row(
                children: [
                  PrimaryButton(
                    onPressed: () => context.go('/upload/${widget.patientId}'),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_upload, size: 16),
                        SizedBox(width: AppDimensions.spacingXs),
                        Text("Carica Nuovo Test"),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  SecondaryButton(
                    onPressed:
                        () => setState(() => _isUpdatePatientModalOpen = true),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: AppDimensions.spacingXs),
                        Text("Aggiorna Paziente"),
                      ],
                    ),
                  ),
                ],
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
        _buildInfoRow("Data di nascita", _formatDate(_patient!.birthdate)),
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
        _buildInfoRow("Totale Test", _bloodworkFindings.isNotEmpty ? "1" : "0"),
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
            width: 100,
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
    if (_isLoadingAnalysis) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Caricamento analisi...'),
          ],
        ),
      );
    }

    // Get the analysis provider to check for pending analysis
    final analysisProvider = Provider.of<AnalysisProvider>(
      context,
      listen: false,
    );
    final hasPendingAnalysis = analysisProvider.hasPendingAnalysis;

    // Show "Analisi in Corso" if there's a pending analysis
    if (hasPendingAnalysis) {
      // Start polling in the background
      _startPolling(analysisProvider);

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.warningOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              child: const Icon(
                Icons.hourglass_empty,
                color: AppColors.warningOrange,
                size: 40,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Text("Analisi in Corso", style: AppTextStyles.title3),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              "L'analisi del campione è in corso. I risultati saranno disponibili a breve.",
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Show "Nessuna Analisi Disponibile" if there's no analysis and no pending analysis
    if (_bloodworkFindings.isEmpty && _diagnosticSummary == null) {
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
                Icons.description,
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
                  Icon(Icons.cloud_upload, size: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Classificazione Urgenza
          if (_urgencyLevel != null) ...[
            _buildUrgencyClassificationCard(),
            const SizedBox(height: AppDimensions.spacingL),
          ],

          // 2. Sintesi Diagnostica
          if (_diagnosticSummary != null) ...[
            _buildDiagnosticSummaryCard(),
            const SizedBox(height: AppDimensions.spacingL),
          ],

          // 3. Educazione Al Proprietario
          if (_ownerEducation != null) ...[
            _buildOwnerEducationCard(),
            const SizedBox(height: AppDimensions.spacingL),
          ],

          // 4. Diagnosi Differenziali
          if (_differentialDiagnoses.isNotEmpty) ...[
            _buildDifferentialDiagnosesCard(),
            const SizedBox(height: AppDimensions.spacingL),
          ],

          // 5. Alterazioni Cliniche
          if (_clinicalAlterations.isNotEmpty) ...[
            _buildClinicalAlterationsCard(),
            const SizedBox(height: AppDimensions.spacingL),
          ],

          // 6. Pattern Compatibili
          if (_compatiblePatterns.isNotEmpty) ...[
            _buildCompatiblePatternsCard(),
            const SizedBox(height: AppDimensions.spacingL),
          ],

          // 7. Riferimento Citologico
          if (_cytologyReport != null) ...[
            _buildCytologyReportCard(),
            const SizedBox(height: AppDimensions.spacingL),
          ],

          // 8. Analisi Matematica
          if (_mathematicalAnalyses.isNotEmpty) ...[
            _buildMathematicalAnalysisCard(),
            const SizedBox(height: AppDimensions.spacingL),
          ],

          // 9. Bandierine Rosse
          if (_redFlags.isNotEmpty) ...[
            _buildRedFlagsCard(),
            const SizedBox(height: AppDimensions.spacingL),
          ],

          // 10. Parametri Analizzati
          if (_bloodworkFindings.isNotEmpty) ...[_buildParametersCard()],
        ],
      ),
    );
  }

  // Simple polling function using a while loop
  Future<void> _startPolling(AnalysisProvider provider) async {
    // Run in a separate isolate to avoid blocking the UI
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('Starting polling for pending analysis');

      // Poll every 15 seconds until analysis is no longer pending
      while (mounted && provider.hasPendingAnalysis) {
        await Future.delayed(const Duration(seconds: 15));

        if (!mounted) return; // Safety check

        debugPrint('Polling for pending analysis status');
        await provider.checkPendingAnalysis(widget.patientId);

        // If analysis is no longer pending, reload data and break
        if (!provider.hasPendingAnalysis) {
          debugPrint('Analysis completed, reloading data');
          await _loadAnalysisData();
          break;
        }
      }
    });
  }

  Widget _buildDiagnosticSummaryCard() {
    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  Icons.manage_search,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Sintesi Diagnostica", style: AppTextStyles.title3),
                    if (_latestAnalysis != null) ...[
                      const SizedBox(height: AppDimensions.spacingXs),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppDimensions.spacingXs),
                          Text(
                            _formatDate(
                              _latestAnalysis!.completedAt ??
                                  _latestAnalysis!.createdAt,
                            ),
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Text(_diagnosticSummary!, style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _buildUrgencyClassificationCard() {
    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning,
                color: AppColors.destructiveRed,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                "Classificazione Urgenza",
                style: AppTextStyles.title3.copyWith(
                  color: AppColors.destructiveRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Row(
            children: [
              AppBadge(
                label: _urgencyLevel!,
                variant: _getUrgencyVariant(_urgencyLevel),
                icon: Icons.warning,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                _urgencyReason ?? "Motivazione non disponibile",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParametersCard() {
    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Parametri Analizzati", style: AppTextStyles.title3),
          const SizedBox(height: AppDimensions.spacingL),
          _buildResultsTable(_bloodworkFindings),
        ],
      ),
    );
  }

  Widget _buildMathematicalAnalysisCard() {
    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Analisi Matematica", style: AppTextStyles.title3),
          const SizedBox(height: AppDimensions.spacingL),
          ..._mathematicalAnalyses.map((analysis) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        analysis.name,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        analysis.value,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    analysis.interpretation,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
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

  Widget _buildClinicalAlterationsCard() {
    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning,
                color: AppColors.destructiveRed,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                "Alterazioni Cliniche",
                style: AppTextStyles.title3.copyWith(
                  color: AppColors.destructiveRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          ..._clinicalAlterations.map((alteration) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              decoration: BoxDecoration(
                color: AppColors.destructiveRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(
                  color: AppColors.destructiveRed.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error,
                    color: AppColors.destructiveRed,
                    size: 16,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Text(
                      alteration,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.destructiveRed,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildDifferentialDiagnosesCard() {
    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning,
                color: AppColors.destructiveRed,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                "Diagnosi Differenziali",
                style: AppTextStyles.title3.copyWith(
                  color: AppColors.destructiveRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          ..._differentialDiagnoses.map((diagnosis) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              decoration: BoxDecoration(
                color: AppColors.destructiveRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(
                  color: AppColors.destructiveRed.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error,
                    color: AppColors.destructiveRed,
                    size: 16,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Text(
                      "${diagnosis.diagnosis} (${diagnosis.confidence})",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.destructiveRed,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildCytologyReportCard() {
    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.manage_search,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                "Riferimento Citologico",
                style: AppTextStyles.title3.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Text(_cytologyReport!, style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _buildCompatiblePatternsCard() {
    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_turned_in,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                "Pattern Compatibili",
                style: AppTextStyles.title3.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate how many columns can fit
              const minCardWidth = 200.0;
              const spacing = AppDimensions.spacingM;
              final availableWidth = constraints.maxWidth;
              final maxColumns =
                  ((availableWidth + spacing) / (minCardWidth + spacing))
                      .floor();
              final actualColumns =
                  (maxColumns < 1)
                      ? 1
                      : (maxColumns > _compatiblePatterns.length)
                      ? _compatiblePatterns.length
                      : maxColumns;

              // Calculate uniform card width

              // Group cards into rows for uniform height
              final entries = _compatiblePatterns.entries.toList();
              final rows = <List<MapEntry<String, String>>>[];

              for (int i = 0; i < entries.length; i += actualColumns) {
                final end =
                    (i + actualColumns < entries.length)
                        ? i + actualColumns
                        : entries.length;
                rows.add(entries.sublist(i, end));
              }

              return Column(
                children:
                    rows.map((rowEntries) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: rows.last == rowEntries ? 0 : spacing,
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            children:
                                rowEntries.asMap().entries.map((indexedEntry) {
                                  final index = indexedEntry.key;
                                  final entry = indexedEntry.value;

                                  return Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        right:
                                            index < rowEntries.length - 1
                                                ? spacing
                                                : 0,
                                      ),
                                      padding: const EdgeInsets.all(
                                        AppDimensions.spacingM,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundSecondary
                                            .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(
                                          AppDimensions.radiusMedium,
                                        ),
                                        border: Border.all(
                                          color: AppColors.borderGray
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _formatPatternName(entry.key),
                                            style: AppTextStyles.body.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.foregroundDark,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: AppDimensions.spacingXs,
                                          ),
                                          Text(
                                            entry.value,
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      );
                    }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerEducationCard() {
    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                "Educazione Proprietario",
                style: AppTextStyles.title3.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Text(_ownerEducation!, style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _buildRedFlagsCard() {
    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning,
                color: AppColors.destructiveRed,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                "Bandierine Rosse",
                style: AppTextStyles.title3.copyWith(
                  color: AppColors.destructiveRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          ..._redFlags.map((flag) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              decoration: BoxDecoration(
                color: AppColors.destructiveRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(
                  color: AppColors.destructiveRed.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error,
                    color: AppColors.destructiveRed,
                    size: 16,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Text(
                      flag,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.destructiveRed,
                        fontWeight: FontWeight.w500,
                      ),
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
                      "${finding.value} ${finding.unit}".trim(),
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

  Widget _buildTreatmentTab() {
    if (_isLoadingAnalysis) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Caricamento piano terapeutico...'),
          ],
        ),
      );
    }

    // Get the analysis provider to check for pending analysis
    final analysisProvider = Provider.of<AnalysisProvider>(
      context,
      listen: false,
    );
    final hasPendingAnalysis = analysisProvider.hasPendingAnalysis;

    // Show "Analisi in Corso" if there's a pending analysis
    if (hasPendingAnalysis) {
      // Start polling in the background (same as in _buildResultsTab)
      _startPolling(analysisProvider);

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.warningOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              child: const Icon(
                Icons.hourglass_empty,
                color: AppColors.warningOrange,
                size: 40,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Text("Analisi in Corso", style: AppTextStyles.title3),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              "Il piano terapeutico sarà disponibile al termine dell'analisi.",
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Diagnostic Plan
          if (_diagnosticPlan.isNotEmpty) ...[
            _buildDiagnosticPlanCard(),
            const SizedBox(height: AppDimensions.spacingL),
          ],

          // Treatment Plan
          if (_treatments.isNotEmpty) ...[
            _buildTreatmentPlanCard(),
            const SizedBox(height: AppDimensions.spacingL),
          ],

          // Follow-up Plan
          if (_followUpPeriod != null || _monitoringParameters.isNotEmpty) ...[
            _buildFollowUpCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildDiagnosticPlanCard() {
    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: AppDimensions.spacingS),
              Text("Piano Diagnostico", style: AppTextStyles.title3),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          ..._diagnosticPlan.map((plan) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plan.exam,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      AppBadge(
                        label: "Priorità: ${plan.priority}",
                        variant: _getPriorityVariant(plan.priority),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Row(
                    children: [
                      Text(
                        "Invasività: ",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        plan.invasiveness,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTreatmentPlanCard() {
    final medications = _treatments.where((t) => t.type == 'farmaco').toList();
    final supplements =
        _treatments.where((t) => t.type == 'supplemento').toList();
    final supports = _treatments.where((t) => t.type == 'supporto').toList();

    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.healing, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: AppDimensions.spacingS),
              Text("Piano Terapeutico", style: AppTextStyles.title3),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),

          // Medications
          if (medications.isNotEmpty) ...[
            Text(
              "Farmaci",
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            ...medications.map(
              (treatment) => _buildTreatmentItem(treatment, Icons.medication),
            ),
            const SizedBox(height: AppDimensions.spacingM),
          ],

          // Supplements
          if (supplements.isNotEmpty) ...[
            Text(
              "Supplementi",
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.successGreen,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            ...supplements.map(
              (treatment) => _buildTreatmentItem(treatment, Icons.add_circle),
            ),
            const SizedBox(height: AppDimensions.spacingM),
          ],

          // Support therapies
          if (supports.isNotEmpty) ...[
            Text(
              "Supporti Terapeutici",
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.warningOrange,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            ...supports.map(
              (treatment) => _buildTreatmentItem(treatment, Icons.favorite),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTreatmentItem(TreatmentItem treatment, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  treatment.name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (treatment.dosage != null ||
                    treatment.route != null ||
                    treatment.duration != null) ...[
                  const SizedBox(height: AppDimensions.spacingXs),
                  Row(
                    children: [
                      if (treatment.dosage != null) ...[
                        Text(
                          treatment.dosage!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (treatment.route != null ||
                            treatment.duration != null)
                          Text(
                            " • ",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                      if (treatment.route != null) ...[
                        Text(
                          treatment.route!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (treatment.duration != null)
                          Text(
                            " • ",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                      if (treatment.duration != null)
                        Text(
                          treatment.duration!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpCard() {
    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Text("Follow-up", style: AppTextStyles.title3),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),

          if (_followUpPeriod != null) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: AppColors.primaryBlue,
                    size: 16,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Text(
                    "Ripetere esami tra: $_followUpPeriod",
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
          ],

          if (_monitoringParameters.isNotEmpty) ...[
            Text(
              "Parametri da Monitorare",
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            ..._monitoringParameters.map((parameter) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.spacingXs),
                padding: const EdgeInsets.all(AppDimensions.spacingS),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_circle,
                      color: AppColors.mediumGray,
                      size: 14,
                    ),
                    const SizedBox(width: AppDimensions.spacingXs),
                    Text(parameter, style: AppTextStyles.bodySmall),
                  ],
                ),
              );
            }),
          ],

          if (_prognosis != null) ...[
            const SizedBox(height: AppDimensions.spacingM),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Prognosi",
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(_prognosis!, style: AppTextStyles.body),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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
}
