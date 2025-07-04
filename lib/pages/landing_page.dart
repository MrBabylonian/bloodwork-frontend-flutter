import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';
import '../components/navigation/app_header.dart';
import '../components/buttons/index.dart';

// Data models for the landing page sections
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

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // Features data in Italian
  static const List<FeatureItem> features = [
    FeatureItem(
      icon: Icons.monitor_heart,
      title: "Analisi Istantanea",
      description:
          "Ottieni analisi complete del sangue in secondi con insight basati sull'intelligenza artificiale",
    ),
    FeatureItem(
      icon: Icons.shield,
      title: "Conforme HIPAA",
      description:
          "Sicurezza di livello aziendale che garantisce la protezione di tutti i dati dei pazienti",
    ),
    FeatureItem(
      icon: Icons.bolt,
      title: "Risultati in Tempo Reale",
      description:
          "Insight diagnostici immediati per accelerare le decisioni di cura dei pazienti",
    ),
  ];

  // Stats data in Italian
  static const List<StatItem> stats = [
    StatItem(icon: Icons.group, value: "500+", label: "Cliniche Veterinarie"),
    StatItem(icon: Icons.description, value: "50K+", label: "Test Analizzati"),
    StatItem(
      icon: Icons.bar_chart,
      value: "99.2%",
      label: "Tasso di Accuratezza",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: const LandingHeader(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            _buildHeroSection(context),

            // Features Section
            _buildFeaturesSection(context),

            // Stats Section
            _buildStatsSection(context),

            // CTA Section
            _buildCTASection(context),

            // Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // Hero section
  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingL,
        AppDimensions.spacingXxl + AppDimensions.spacingXl,
        AppDimensions.spacingL,
        AppDimensions.spacingXxl,
      ),
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
          Container(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              children: [
                // Main headline with gradient text
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.foregroundDark,
                      height: 1.1,
                    ),
                    children: [
                      const TextSpan(text: 'Analisi '),
                      TextSpan(
                        text: 'Rivoluzionaria ',
                        style: TextStyle(
                          foreground:
                              Paint()
                                ..shader = const LinearGradient(
                                  colors: [
                                    AppColors.primaryBlue,
                                    Color(0xFF4A90E2),
                                  ],
                                ).createShader(
                                  const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                                ),
                        ),
                      ),
                      const TextSpan(text: 'del Sangue'),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingL),

                // Subtitle
                Text(
                  'Trasforma la diagnostica veterinaria con l\'analisi del sangue basata sull\'intelligenza artificiale. '
                  'Ottieni insight istantanei e precisi per fornire la migliore cura ai tuoi pazienti.',
                  style: AppTextStyles.title3.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.spacingXl),

                // CTA buttons
                _buildResponsiveCTAButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Responsive CTA buttons for hero section
  Widget _buildResponsiveCTAButtons(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < AppDimensions.breakpointM;

        if (isSmallScreen) {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  size: ButtonSize.large,
                  width: double.infinity,
                  onPressed: () => context.go('/login'),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Inizia Analisi'),
                      SizedBox(width: AppDimensions.spacingS),
                      Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),
              SizedBox(
                width: double.infinity,
                child: OutlineButton(
                  size: ButtonSize.large,
                  width: double.infinity,
                  onPressed: () => debugPrint('Guarda Demo tapped'),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, size: 20),
                      SizedBox(width: AppDimensions.spacingS),
                      Text('Guarda Demo'),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PrimaryButton(
                    size: ButtonSize.large,
                    width: double.infinity,
                    onPressed: () => context.go('/login'),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Inizia Analisi'),
                        SizedBox(width: AppDimensions.spacingS),
                        Icon(Icons.chevron_right, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  OutlineButton(
                    size: ButtonSize.large,
                    width: double.infinity,
                    onPressed: () => debugPrint('Guarda Demo tapped'),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow, size: 20),
                        SizedBox(width: AppDimensions.spacingS),
                        Text('Guarda Demo'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  // Features section
  Widget _buildFeaturesSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingL,
        vertical: AppDimensions.spacingXxl,
      ),
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.maxContentWidth,
            ),
            child: Column(
              children: [
                // Section header
                Column(
                  children: [
                    Text(
                      'Perché Scegliere VetAnalytics?',
                      style: AppTextStyles.largeTitle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Text(
                      'Costruito per le moderne pratiche veterinarie che richiedono precisione, velocità e affidabilità',
                      style: AppTextStyles.title3.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingXxl),

                // Feature cards
                _buildFeatureCards(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Feature cards grid
  Widget _buildFeatureCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < AppDimensions.breakpointM;

        if (isSmallScreen) {
          return IntrinsicHeight(
            child: Column(
              children:
                  features
                      .map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppDimensions.spacingL,
                          ),
                          child: _buildFeatureCard(feature),
                        ),
                      )
                      .toList(),
            ),
          );
        } else {
          return Wrap(
            spacing: AppDimensions.spacingL,
            runSpacing: AppDimensions.spacingL,
            children:
                features
                    .map(
                      (feature) => SizedBox(
                        width:
                            (constraints.maxWidth -
                                2 * AppDimensions.spacingL) /
                            3,
                        height: 280, // Fixed height for equal card heights
                        child: _buildFeatureCard(feature),
                      ),
                    )
                    .toList(),
          );
        }
      },
    );
  }

  // Individual feature card
  Widget _buildFeatureCard(FeatureItem feature) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
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
          Text(
            feature.title,
            style: AppTextStyles.title3.copyWith(
              color: AppColors.foregroundDark,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingM),

          // Description
          Flexible(
            child: Text(
              feature.description,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }

  // Stats section
  Widget _buildStatsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingL,
        vertical: AppDimensions.spacingXxl,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withValues(alpha: 0.3),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.maxContentWidth,
        ),
        child: _buildStatsGrid(context),
      ),
    );
  }

  // Stats grid
  Widget _buildStatsGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < AppDimensions.breakpointM;

        if (isSmallScreen) {
          return Column(
            children:
                stats
                    .map(
                      (stat) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.spacingL,
                        ),
                        child: _buildStatItem(stat),
                      ),
                    )
                    .toList(),
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                stats
                    .map((stat) => Expanded(child: _buildStatItem(stat)))
                    .toList(),
          );
        }
      },
    );
  }

  // Individual stat item
  Widget _buildStatItem(StatItem stat) {
    return Column(
      children: [
        // Icon and value
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(stat.icon, color: AppColors.primaryBlue, size: 32),
            const SizedBox(width: AppDimensions.spacingM),
            Text(
              stat.value,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.foregroundDark,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.spacingM),

        // Label
        Text(
          stat.label,
          style: AppTextStyles.title3.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // CTA section
  Widget _buildCTASection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingL,
        vertical: AppDimensions.spacingXxl,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 768),
          padding: const EdgeInsets.all(AppDimensions.spacingXxl),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryBlue, Color(0xFF4A90E2)],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          ),
          child: Column(
            children: [
              // Title
              Text(
                'Pronto a Trasformare la Tua Pratica?',
                style: AppTextStyles.largeTitle.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Description
              Text(
                'Unisciti a centinaia di professionisti veterinari che si fidano di VetAnalytics '
                'per analisi del sangue accurate e veloci.',
                style: AppTextStyles.title3.copyWith(
                  color: AppColors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.normal,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // CTA button
              SecondaryButton(
                size: ButtonSize.large,
                onPressed: () => context.go('/login'),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Inizia Oggi'),
                    SizedBox(width: AppDimensions.spacingS),
                    Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Footer
  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingL,
        vertical: AppDimensions.spacingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withValues(alpha: 0.2),
        border: const Border(top: BorderSide(color: AppColors.borderGray)),
      ),
      child: Column(
        children: [
          // Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBlue, Color(0xFF4A90E2)],
                  ),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'V',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
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
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
