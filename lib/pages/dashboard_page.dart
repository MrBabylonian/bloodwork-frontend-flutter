import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';
import '../components/buttons/index.dart';
import '../components/forms/text_input.dart';
import '../components/navigation/app_header.dart';
import '../components/dialogs/add_patient_modal.dart';
import '../core/models/patient_models.dart';
import '../core/providers/patient_provider.dart';
import '../core/services/logout_service.dart';
import '../utils/auth_utils.dart';
import '../components/cards/patient_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isAddPatientModalOpen = false;
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load patients when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPatients();
    });

    // Add scroll listener for pagination
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );
      if (patientProvider.hasMorePages && !patientProvider.isLoadingMore) {
        patientProvider.loadMorePatients();
      }
    }
  }

  void _loadPatients() {
    final patientProvider = Provider.of<PatientProvider>(
      context,
      listen: false,
    );
    patientProvider.loadPatients(reset: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
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
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.backgroundWhite,
                  Color(0xFFF8F9FA),
                  AppColors.backgroundWhite,
                ],
              ),
            ),
            child: Column(
              children: [
                // Header
                AppHeader(
                  showAuth: true,
                  onProfileTap: () => context.go('/profile'),
                  onLogoutTap: () => LogoutService.showLogoutDialog(context),
                ),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppDimensions.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page Header
                        _buildPageHeader(),

                        const SizedBox(height: AppDimensions.spacingXl),

                        // Stats Cards
                        _buildStatsCards(),

                        const SizedBox(height: AppDimensions.spacingXl),

                        // Search and Filters
                        _buildSearchAndFilters(),

                        const SizedBox(height: AppDimensions.spacingXl),

                        // Patient Grid
                        _buildPatientGrid(),

                        // Pagination loading indicator
                        _buildPaginationIndicator(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Add Patient Modal
        AddPatientModal(
          isOpen: _isAddPatientModalOpen,
          onClose: () => setState(() => _isAddPatientModalOpen = false),
          onPatientCreated: () {
            // Refresh patient list after creation
            _loadPatients();
          },
        ),
      ],
    );
  }

  Widget _buildPageHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile layout (stacked)
        if (constraints.maxWidth < 768) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard Pazienti', style: AppTextStyles.pageTitle),
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                'Gestisci i tuoi pazienti e le loro analisi del sangue',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // Stacked buttons on mobile
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      size: ButtonSize.large,
                      onPressed:
                          () => setState(() => _isAddPatientModalOpen = true),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 16),
                          SizedBox(width: AppDimensions.spacingS),
                          Text('Aggiungi Paziente'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        // Desktop layout (horizontal)
        return Row(
          children: [
            // Left side - Title and Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dashboard Pazienti', style: AppTextStyles.pageTitle),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    'Gestisci i tuoi pazienti e le loro analisi del sangue',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppDimensions.spacingL),

            // Right side - Action Buttons (horizontal layout)
            PrimaryButton(
              size: ButtonSize.medium,
              onPressed: () => setState(() => _isAddPatientModalOpen = true),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: AppDimensions.spacingS),
                  Text('Aggiungi Paziente'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsCards() {
    final patientProvider = Provider.of<PatientProvider>(context);
    final totalPatients = patientProvider.totalPatients.toString();

    return LayoutBuilder(
      builder: (context, constraints) {
        final card = _buildStatCard(
          title: 'Pazienti Totali',
          value: totalPatients,
          icon: Icons.people,
          color: AppColors.primaryBlue,
        );

        // Mobile (stacked)
        if (constraints.maxWidth < 768) {
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: card,
          );
        }

        // Larger viewports – center the single card
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: card,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      // Remove fixed width to use all available space
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.foregroundDark.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.title2.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, size: 24, color: color),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.foregroundDark.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: AppTextInput(
                controller: _searchController,
                placeholder: 'Cerca pazienti per nome, proprietario o razza...',
                onChanged: (value) {
                  setState(() => _searchQuery = value);

                  // Get provider reference before async gap
                  final patientProvider = Provider.of<PatientProvider>(
                    context,
                    listen: false,
                  );

                  // Debounce search
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_searchQuery == value) {
                      if (_searchQuery.isEmpty) {
                        // Check if widget is still mounted before updating
                        if (mounted) {
                          patientProvider.loadPatients(reset: true);
                        }
                      } else {
                        // Check if widget is still mounted before updating
                        if (mounted) {
                          patientProvider.searchPatients(
                            _searchQuery,
                            reset: true,
                          );
                        }
                      }
                    }
                  });
                },
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 12, right: 16),
                  child: Icon(
                    Icons.search,
                    color: AppColors.mediumGray,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          SecondaryButton(
            size: ButtonSize.medium,
            onPressed: () => debugPrint('Filtri tapped'),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune, size: 16),
                SizedBox(width: 8),
                Text('Filtri'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientGrid() {
    return Consumer<PatientProvider>(
      builder: (context, patientProvider, child) {
        // Handle loading state
        if (patientProvider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Caricamento pazienti...'),
              ],
            ),
          );
        }

        // Handle error state
        if (patientProvider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.errorRed,
                ),
                const SizedBox(height: 16),
                Text(
                  patientProvider.errorMessage ?? 'Errore nel caricamento',
                  style: const TextStyle(color: AppColors.errorRed),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  onPressed: () => patientProvider.refresh(),
                  child: const Text('Riprova'),
                ),
              ],
            ),
          );
        }

        // Get patients
        final patients = patientProvider.patients;

        // Handle empty state
        if (patients.isEmpty) {
          return _buildEmptyState();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Responsive grid
            int crossAxisCount = 1;
            if (constraints.maxWidth > 1400) {
              crossAxisCount = 4; // xl: 4 columns
            } else if (constraints.maxWidth > 1024) {
              crossAxisCount = 3; // lg: 3 columns
            } else if (constraints.maxWidth > 768) {
              crossAxisCount = 2; // md: 2 columns
            } else {
              crossAxisCount = 1; // sm: 1 column
            }

            // Responsive grid using ListView and Row
            return Column(
              children: [
                for (int i = 0; i < patients.length; i += crossAxisCount)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.spacingL,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (
                          int j = i;
                          j < i + crossAxisCount && j < patients.length;
                          j++
                        )
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right:
                                    j < i + crossAxisCount - 1
                                        ? AppDimensions.spacingL
                                        : 0,
                              ),
                              child: PatientCard(patient: patients[j]),
                            ),
                          ),
                        // Add empty expanded widgets if the row isn't full
                        for (
                          int k = patients.length;
                          k < i + crossAxisCount && k > i;
                          k++
                        )
                          Expanded(child: const SizedBox()),
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPaginationIndicator() {
    final patientProvider = Provider.of<PatientProvider>(context);

    if (patientProvider.isLoadingMore) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingL),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (patientProvider.hasMorePages) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingL),
        alignment: Alignment.center,
        child: SecondaryButton(
          size: ButtonSize.medium,
          onPressed: () => patientProvider.loadMorePatients(),
          child: const Text('Carica altri pazienti'),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.foregroundDark.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.search, size: 48, color: AppColors.mediumGray),
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            'Nessun paziente trovato',
            style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'Prova ad aggiustare i termini di ricerca o aggiungi un nuovo paziente.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
