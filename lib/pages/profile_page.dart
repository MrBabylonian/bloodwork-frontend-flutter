import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';
import '../components/buttons/index.dart';
import '../components/forms/text_input.dart';
import '../components/forms/app_switch.dart';
import '../components/navigation/app_header.dart';
import '../components/navigation/app_tabs.dart';
import '../components/cards/info_card.dart';
import '../components/dialogs/app_custom_dialog.dart';
import '../core/providers/auth_provider.dart';

/// Profile data model
class ProfileData {
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String phone;
  final String clinic;
  final String license;
  final String specialty;

  const ProfileData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.phone,
    required this.clinic,
    required this.license,
    required this.specialty,
  });

  ProfileData copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? username,
    String? phone,
    String? clinic,
    String? license,
    String? specialty,
  }) {
    return ProfileData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      clinic: clinic ?? this.clinic,
      license: license ?? this.license,
      specialty: specialty ?? this.specialty,
    );
  }

  // Create from user profile map
  factory ProfileData.fromUserProfile(
    Map<String, dynamic> profile, {
    required String username,
    required String email,
  }) {
    return ProfileData(
      firstName: profile['first_name'] ?? '',
      lastName: profile['last_name'] ?? '',
      email: email,
      username: username,
      phone: profile['phone'] ?? '',
      clinic: profile['clinic_name'] ?? '',
      license: profile['license_number'] ?? '',
      specialty: profile['specialty'] ?? '',
    );
  }
}

/// Notification preferences model
class NotificationPreferences {
  final bool emailAlerts;
  final bool smsAlerts;
  final bool criticalResults;
  final bool weeklyReports;

  const NotificationPreferences({
    required this.emailAlerts,
    required this.smsAlerts,
    required this.criticalResults,
    required this.weeklyReports,
  });

  NotificationPreferences copyWith({
    bool? emailAlerts,
    bool? smsAlerts,
    bool? criticalResults,
    bool? weeklyReports,
  }) {
    return NotificationPreferences(
      emailAlerts: emailAlerts ?? this.emailAlerts,
      smsAlerts: smsAlerts ?? this.smsAlerts,
      criticalResults: criticalResults ?? this.criticalResults,
      weeklyReports: weeklyReports ?? this.weeklyReports,
    );
  }
}

/// Profile page for user account management
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Profile data from user
  ProfileData? _profile;
  bool _isLoadingProfile = true;
  bool _isAdmin = false; // Track if user is admin

  // Notification preferences
  NotificationPreferences _notifications = const NotificationPreferences(
    emailAlerts: true,
    smsAlerts: false,
    criticalResults: true,
    weeklyReports: true,
  );

  // Text controllers for profile form
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _clinicController;
  late TextEditingController _licenseController;
  late TextEditingController _specialtyController;

  // Text controllers for security form
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      // Check if user is admin
      _isAdmin = authProvider.isAdmin;

      setState(() {
        _profile = ProfileData.fromUserProfile(
          user.profile,
          username: user.username,
          email: user.email,
        );
        _usernameController.text = _profile!.username;
        _emailController.text = _profile!.email;
        _firstNameController.text = _profile!.firstName;
        _lastNameController.text = _profile!.lastName;
        _phoneController.text = _profile!.phone;
        _clinicController.text = _profile!.clinic;
        _licenseController.text = _profile!.license;
        _specialtyController.text = _profile!.specialty;
        _isLoadingProfile = false;
      });
    } else {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _phoneController = TextEditingController();
    _clinicController = TextEditingController();
    _licenseController = TextEditingController();
    _specialtyController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _clinicController.dispose();
    _licenseController.dispose();
    _specialtyController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    try {
      print('🔑 PROFILE PAGE: Starting logout process');
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      // Navigation will be handled automatically by the router
      print(
        '🔑 PROFILE PAGE: Logout completed, router should handle navigation',
      );
    } catch (e) {
      print('🔑 PROFILE PAGE: Logout error: $e');
      // Even if logout fails, try to navigate to login
      if (mounted) {
        context.go('/login');
      }
    }
  }

  Future<void> _handleProfileSave() async {
    if (_profile == null) return;

    setState(() {
      _profile = ProfileData(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        username: _usernameController.text,
        phone: _phoneController.text,
        clinic: _clinicController.text,
        license: _licenseController.text,
        specialty: _specialtyController.text,
      );
    });

    // Save to backend - only send fields appropriate for the user type
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final profileMap = {
      'first_name': _profile!.firstName,
      'last_name': _profile!.lastName,
      'email': _profile!.email,
      'phone': _profile!.phone,
    };

    // Add fields specific to veterinarians/technicians
    if (!_isAdmin) {
      profileMap['license_number'] = _profile!.license;
      profileMap['clinic_name'] = _profile!.clinic;
      profileMap['specialty'] = _profile!.specialty;
    }

    final success = await authProvider.updateProfile(profileMap);

    if (success) {
      _showSuccessDialog("Profilo aggiornato con successo!");
    } else {
      _showErrorDialog("Errore durante l'aggiornamento del profilo. Riprova.");
    }
  }

  void _handleNotificationSave() {
    // Show success message
    _showSuccessDialog("Preferenze notifiche aggiornate!");
  }

  Future<void> _handlePasswordUpdate() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorDialog("Le password non corrispondono!");
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showErrorDialog("La password deve essere di almeno 6 caratteri!");
      return;
    }

    // Update password in backend
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updatePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (success) {
      // Clear password fields
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      _showSuccessDialog("Password aggiornata con successo!");
    } else {
      _showErrorDialog(
        "Errore durante l'aggiornamento della password. Verifica la password attuale e riprova.",
      );
    }
  }

  void _showSuccessDialog(String message) {
    showSuccessDialog(context: context, message: message);
  }

  void _showErrorDialog(String message) {
    showErrorDialog(context: context, message: message);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundWhite,
      child: Column(
        children: [
          // Header
          AppHeader(
            title: const Text("Profilo", style: AppTextStyles.title2),
            showAuth: true,
            onProfileTap: () => context.go('/profile'),
            onLogoutTap: _handleLogout,
          ),

          // Content
          Expanded(
            child:
                _isLoadingProfile
                    ? const Center(child: CupertinoActivityIndicator())
                    : _profile == null
                    ? const Center(child: Text("Nessun profilo disponibile"))
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppDimensions.spacingL),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1024),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Back button
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

                            // Profile Header Card
                            _buildProfileHeader(),

                            const SizedBox(height: AppDimensions.spacingL),

                            // Tabs
                            SizedBox(
                              height: 600, // Fixed height for tabs content
                              child: AppTabs(
                                tabAlignment:
                                    Alignment.center, // Center the tabs
                                tabs: const [
                                  AppTab(
                                    id: 'profile',
                                    label: 'Profilo',
                                    icon: CupertinoIcons.person,
                                  ),
                                  AppTab(
                                    id: 'notifications',
                                    label: 'Notifiche',
                                    icon: CupertinoIcons.bell,
                                  ),
                                  AppTab(
                                    id: 'security',
                                    label: 'Sicurezza',
                                    icon: CupertinoIcons.shield,
                                  ),
                                ],
                                children: [
                                  _buildProfileTab(),
                                  _buildNotificationsTab(),
                                  _buildSecurityTab(),
                                ],
                              ),
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

  Widget _buildProfileHeader() {
    if (_profile == null) {
      return const SizedBox.shrink();
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final roleDisplay =
        _isAdmin
            ? 'Amministratore'
            : (authProvider.isVeterinarian
                ? 'Veterinario'
                : 'Tecnico Veterinario');

    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Center(
                  child: Text(
                    "${_profile!.firstName.isNotEmpty ? _profile!.firstName[0] : ''}${_profile!.lastName.isNotEmpty ? _profile!.lastName[0] : ''}",
                    style: AppTextStyles.title2.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusFull,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.foregroundDark.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.camera,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: AppDimensions.spacingL),

          // Profile info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_profile!.firstName} ${_profile!.lastName}",
                  style: AppTextStyles.title2,
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  roleDisplay,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.mediumGray,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXxs),
                if (!_isAdmin && _profile!.specialty.isNotEmpty)
                  Text(
                    _profile!.specialty,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mediumGray,
                    ),
                  ),
                if (!_isAdmin && _profile!.clinic.isNotEmpty)
                  Text(
                    _profile!.clinic,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mediumGray,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: InfoCard(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with save button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Informazioni Personali", style: AppTextStyles.title3),
                PrimaryButton(
                  onPressed: _handleProfileSave,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.checkmark, size: 16),
                      SizedBox(width: AppDimensions.spacingXs),
                      Text("Salva Modifiche"),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // Form fields
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;

                if (isWide) {
                  // Two-column layout for wider screens
                  return Column(
                    children: [
                      // Username field (non-editable)
                      Row(
                        children: [
                          Expanded(
                            child: AppTextInput(
                              controller: _usernameController,
                              label: "Username",
                              placeholder: "Username",
                              enabled: false, // Username is not editable
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingM),
                          Expanded(
                            child: AppTextInput(
                              controller: _emailController,
                              label: "Email",
                              placeholder: "Email",
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextInput(
                              controller: _firstNameController,
                              label: "Nome",
                              placeholder: "Inserisci il nome",
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingM),
                          Expanded(
                            child: AppTextInput(
                              controller: _lastNameController,
                              label: "Cognome",
                              placeholder: "Inserisci il cognome",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextInput(
                              controller: _phoneController,
                              label: "Telefono",
                              placeholder: "Inserisci il telefono",
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingM),
                          // Empty space for alignment when not showing clinic fields
                          if (!_isAdmin)
                            Expanded(
                              child: AppTextInput(
                                controller: _clinicController,
                                label: "Nome Clinica",
                                placeholder: "Inserisci il nome della clinica",
                              ),
                            )
                          else
                            const Expanded(child: SizedBox()),
                        ],
                      ),

                      // Only show these fields for veterinarians/technicians
                      if (!_isAdmin) ...[
                        const SizedBox(height: AppDimensions.spacingM),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextInput(
                                controller: _licenseController,
                                label: "Numero Licenza",
                                placeholder: "Inserisci il numero di licenza",
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacingM),
                            Expanded(
                              child: AppTextInput(
                                controller: _specialtyController,
                                label: "Specialità",
                                placeholder: "Inserisci la specialità",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  );
                } else {
                  // Single-column layout for narrower screens
                  return Column(
                    children: [
                      // Username field (non-editable)
                      AppTextInput(
                        controller: _usernameController,
                        label: "Username",
                        placeholder: "Username",
                        enabled: false, // Username is not editable
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      AppTextInput(
                        controller: _emailController,
                        label: "Email",
                        placeholder: "Email",
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      AppTextInput(
                        controller: _firstNameController,
                        label: "Nome",
                        placeholder: "Inserisci il nome",
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      AppTextInput(
                        controller: _lastNameController,
                        label: "Cognome",
                        placeholder: "Inserisci il cognome",
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      AppTextInput(
                        controller: _phoneController,
                        label: "Telefono",
                        placeholder: "Inserisci il telefono",
                        keyboardType: TextInputType.phone,
                      ),

                      // Only show these fields for veterinarians/technicians
                      if (!_isAdmin) ...[
                        const SizedBox(height: AppDimensions.spacingM),
                        AppTextInput(
                          controller: _clinicController,
                          label: "Nome Clinica",
                          placeholder: "Inserisci il nome della clinica",
                        ),
                        const SizedBox(height: AppDimensions.spacingM),
                        AppTextInput(
                          controller: _licenseController,
                          label: "Numero Licenza",
                          placeholder: "Inserisci il numero di licenza",
                        ),
                        const SizedBox(height: AppDimensions.spacingM),
                        AppTextInput(
                          controller: _specialtyController,
                          label: "Specialità",
                          placeholder: "Inserisci la specialità",
                        ),
                      ],
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: InfoCard(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with save button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Preferenze Notifiche", style: AppTextStyles.title3),
                PrimaryButton(
                  onPressed: _handleNotificationSave,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.checkmark, size: 16),
                      SizedBox(width: AppDimensions.spacingXs),
                      Text("Salva Preferenze"),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // Notification options
            _buildNotificationOption(
              title: "Avvisi Email",
              description: "Ricevi notifiche via email",
              value: _notifications.emailAlerts,
              onChanged:
                  (value) => setState(() {
                    _notifications = _notifications.copyWith(
                      emailAlerts: value,
                    );
                  }),
            ),

            const SizedBox(height: AppDimensions.spacingM),

            _buildNotificationOption(
              title: "Avvisi SMS",
              description: "Ricevi notifiche urgenti via SMS",
              value: _notifications.smsAlerts,
              onChanged:
                  (value) => setState(() {
                    _notifications = _notifications.copyWith(smsAlerts: value);
                  }),
            ),

            const SizedBox(height: AppDimensions.spacingM),

            _buildNotificationOption(
              title: "Risultati Critici",
              description: "Notifiche immediate per risultati critici",
              value: _notifications.criticalResults,
              onChanged:
                  (value) => setState(() {
                    _notifications = _notifications.copyWith(
                      criticalResults: value,
                    );
                  }),
            ),

            const SizedBox(height: AppDimensions.spacingM),

            _buildNotificationOption(
              title: "Report Settimanali",
              description: "Riepilogo dell'attività settimanale",
              value: _notifications.weeklyReports,
              onChanged:
                  (value) => setState(() {
                    _notifications = _notifications.copyWith(
                      weeklyReports: value,
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXxs),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
          AppSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;

              if (isWide) {
                // Side by side layout for desktop
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Change Password Card
                    Expanded(child: _buildPasswordCard()),
                    const SizedBox(width: AppDimensions.spacingL),
                    // Two-Factor Authentication Card
                    Expanded(child: _build2FACard()),
                  ],
                );
              } else {
                // Stacked layout for mobile
                return Column(
                  children: [
                    _buildPasswordCard(),
                    const SizedBox(height: AppDimensions.spacingL),
                    _build2FACard(),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordCard() {
    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Cambia Password", style: AppTextStyles.title3),
          const SizedBox(height: AppDimensions.spacingL),
          AppTextInput(
            controller: _currentPasswordController,
            label: "Password Attuale",
            placeholder: "Inserisci la password attuale",
            obscureText: true,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          AppTextInput(
            controller: _newPasswordController,
            label: "Nuova Password",
            placeholder: "Inserisci la nuova password",
            obscureText: true,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          AppTextInput(
            controller: _confirmPasswordController,
            label: "Conferma Nuova Password",
            placeholder: "Conferma la nuova password",
            obscureText: true,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              onPressed: _handlePasswordUpdate,
              child: const Text("Aggiorna Password"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build2FACard() {
    return InfoCard(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Autenticazione a Due Fattori", style: AppTextStyles.title3),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            "Aggiungi un livello extra di sicurezza al tuo account",
            style: AppTextStyles.body.copyWith(color: AppColors.mediumGray),
          ),
          const SizedBox(height: AppDimensions.spacingL),

          // 2FA Status indicator
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.shield,
                  color: AppColors.mediumGray,
                  size: AppDimensions.iconSizeMedium,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Stato 2FA",
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Non configurato",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingS,
                    vertical: AppDimensions.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusFull,
                    ),
                  ),
                  child: Text(
                    "Inattivo",
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.warningOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingL),

          SizedBox(
            width: double.infinity,
            child: SecondaryButton(
              onPressed: () {
                // TODO: Implement 2FA configuration
                _showSuccessDialog("Configurazione 2FA in arrivo!");
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.settings, size: 16),
                  SizedBox(width: AppDimensions.spacingXs),
                  Text("Configura 2FA"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
