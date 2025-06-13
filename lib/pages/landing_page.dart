import 'package:flutter/cupertino.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';
import '../components/layout/page_scaffold.dart';
import '../components/buttons/primary_button.dart';
import '../components/buttons/ghost_button.dart';

// Data model for features section
class FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  const FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

// Data model for stats section
class StatItem {
  final IconData icon;
  final String value;
  final String label;

  const StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  // Define our feature data - translated to Italian
  static const List<FeatureItem> features = [
    FeatureItem(
      icon: CupertinoIcons.waveform_path_ecg,
      title: "Analisi Istantanea",
      description:
          "Ottieni analisi complete del sangue in secondi con insight basati sull'intelligenza artificiale",
    ),
    FeatureItem(
      icon: CupertinoIcons.shield_fill,
      title: "Conforme HIPAA",
      description:
          "Sicurezza di livello aziendale che garantisce la protezione di tutti i dati dei pazienti",
    ),
    FeatureItem(
      icon: CupertinoIcons.bolt_fill,
      title: "Risultati in Tempo Reale",
      description:
          "Insight diagnostici immediati per accelerare le decisioni di cura dei pazienti",
    ),
  ];

  // Define our stats data - translated to Italian
  static const List<StatItem> stats = [
    StatItem(
      icon: CupertinoIcons.group,
      value: "500+",
      label: "Cliniche Veterinarie",
    ),
    StatItem(
      icon: CupertinoIcons.doc_text,
      value: "50K+",
      label: "Test Analizzati",
    ),
    StatItem(
      icon: CupertinoIcons.chart_bar,
      value: "99.2%",
      label: "Tasso di Accuratezza",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      layoutType:
          PageLayoutType.fullWidth, // Full width for landing page design
      backgroundColor: AppColors.backgroundWhite,
      padding:
          EdgeInsets.zero, // No default padding, we'll handle it per section
      navigationBar: _buildNavigationBar(context),
      body: Column(
        children: [
          // Hero Section
          _buildHeroSection(context),

          // Features Section
          _buildFeaturesSection(context),

          // Stats Section
          _buildStatsSection(context),

          // CTA Section
          _buildCTASection(context),
        ],
      ),
      footer: _buildFooter(context),
    );
  }

  // Navigation Bar using CupertinoNavigationBar
  CupertinoNavigationBar _buildNavigationBar(BuildContext context) {
    return CupertinoNavigationBar(
      backgroundColor: AppColors.backgroundWhite.withValues(alpha: 0.95),
      border: const Border(
        bottom: BorderSide(color: AppColors.borderGray, width: 0.5),
      ),
      middle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue,
                  AppColors.primaryBlue.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: const Center(
              child: Text(
                'V',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingXs),
          Text(
            'VetAnalytics',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GhostButton(
            onPressed: () {
              debugPrint('Navigate to login');
            },
            child: const Text('Accedi'),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          PrimaryButton(
            onPressed: () {
              debugPrint('Navigate to get started');
            },
            child: const Text('Inizia'),
          ),
        ],
      ),
    );
  }

  // Hero Section - Main banner with call to action
  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundWhite,
            AppColors.lightGray,
            AppColors.backgroundWhite,
          ],
        ),
      ),
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      child: Column(
        children: [
          const SizedBox(height: AppDimensions.spacingXxl),

          // Main headline
          Text(
            'Analisi Professionale del Sangue\nper l\'Eccellenza Veterinaria',
            style: AppTextStyles.largeTitle.copyWith(fontSize: 48, height: 1.1),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.spacingL),

          // Subtitle
          Text(
            'Trasforma la tua pratica veterinaria con l\'analisi del sangue basata sull\'IA.\nOttieni risultati istantanei e accurati che ti aiutano a fornire la migliore cura per i tuoi pazienti.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.mediumGray,
              fontSize: 18,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.spacingXxl),

          // CTA Buttons
          Wrap(
            spacing: AppDimensions.spacingM,
            runSpacing: AppDimensions.spacingM,
            alignment: WrapAlignment.center,
            children: [
              PrimaryButton(
                onPressed: () {
                  debugPrint('Start analyzing');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.play_fill, size: 16),
                    const SizedBox(width: AppDimensions.spacingXs),
                    const Text('Inizia ad Analizzare'),
                  ],
                ),
              ),

              GhostButton(
                onPressed: () {
                  debugPrint('Watch demo');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.play_circle, size: 16),
                    const SizedBox(width: AppDimensions.spacingXs),
                    const Text('Guarda Demo'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingXxl),
        ],
      ),
    );
  }

  // Features Section - Showcasing key benefits
  Widget _buildFeaturesSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      child: Column(
        children: [
          // Section title
          Text(
            'Perché Scegliere VetAnalytics?',
            style: AppTextStyles.title1.copyWith(fontSize: 32),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.spacingM),

          // Section subtitle
          Text(
            'Costruito per pratiche veterinarie moderne che richiedono precisione, velocità e affidabilità',
            style: AppTextStyles.body.copyWith(
              color: AppColors.mediumGray,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.spacingXxl),

          // Features grid - Using Wrap for better responsive behavior
          Wrap(
            spacing: AppDimensions.spacingL,
            runSpacing: AppDimensions.spacingL,
            children:
                features
                    .map(
                      (feature) => ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 280,
                          maxWidth: 350,
                        ),
                        child: _buildFeatureCard(feature),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  // Individual feature card
  Widget _buildFeatureCard(FeatureItem feature) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Icon(feature.icon, color: AppColors.primaryBlue, size: 24),
          ),

          const SizedBox(height: AppDimensions.spacingL),

          // Title
          Text(feature.title, style: AppTextStyles.title3),

          const SizedBox(height: AppDimensions.spacingS),

          // Description
          Text(
            feature.description,
            style: AppTextStyles.body.copyWith(
              color: AppColors.mediumGray,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // Stats Section - Social proof with numbers
  Widget _buildStatsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      decoration: const BoxDecoration(color: AppColors.lightGray),
      child: Wrap(
        spacing: AppDimensions.spacingXl,
        runSpacing: AppDimensions.spacingL,
        alignment: WrapAlignment.spaceEvenly,
        children: stats.map((stat) => _buildStatItem(stat)).toList(),
      ),
    );
  }

  // Individual stat item
  Widget _buildStatItem(StatItem stat) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(stat.icon, color: AppColors.primaryBlue, size: 32),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              stat.value,
              style: AppTextStyles.largeTitle.copyWith(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.spacingS),

        Text(
          stat.label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.mediumGray,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  // Call to Action Section
  Widget _buildCTASection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingXxl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryBlue,
              AppColors.primaryBlue.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Pronto a Trasformare la Tua Pratica?',
              style: AppTextStyles.title1.copyWith(
                color: CupertinoColors.white,
                fontSize: 32,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.spacingM),

            Text(
              'Unisciti a centinaia di professionisti veterinari che si fidano di VetAnalytics\nper analisi del sangue accurate e veloci.',
              style: AppTextStyles.body.copyWith(
                color: CupertinoColors.white.withValues(alpha: 0.9),
                fontSize: 18,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.spacingXl),

            // Custom CTA Button
            GestureDetector(
              onTap: () {
                debugPrint('Get started today');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingXl,
                  vertical: AppDimensions.spacingM,
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Inizia Oggi',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingXs),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 16,
                      color: AppColors.primaryBlue,
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

  // Footer Section
  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: const BoxDecoration(
        color: AppColors.lightGray,
        border: Border(top: BorderSide(color: AppColors.borderGray)),
      ),
      child: Column(
        children: [
          // Logo and title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.primaryBlue.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'V',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingXs),
              Text(
                'VetAnalytics',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingM),

          // Copyright
          Text(
            '© 2024 VetAnalytics. Tutti i diritti riservati.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }
}
