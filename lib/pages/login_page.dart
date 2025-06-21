import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../components/buttons/index.dart';
import '../components/forms/text_input.dart';
import '../components/dialogs/app_custom_dialog.dart';
import '../core/models/auth_models.dart';
import '../core/providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLogin = true;

  // Login form controllers
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Registration form controllers
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Form state
  UserRole _selectedRole = UserRole.veterinarian;

  // Form errors
  String? _usernameError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _emailError;
  String? _firstNameError;
  String? _lastNameError;
  String? _licenseNumberError;
  String? _clinicNameError;
  String? _phoneError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _licenseNumberController.dispose();
    _clinicNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      // Clear all errors
      _usernameError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _emailError = null;
      _firstNameError = null;
      _lastNameError = null;
      _licenseNumberError = null;
      _clinicNameError = null;
      _phoneError = null;

      // Username validation
      if (_usernameController.text.isEmpty) {
        _usernameError = 'Username è richiesto';
      } else if (_usernameController.text.length < 3) {
        _usernameError = 'Username deve essere almeno 3 caratteri';
      } else if (_usernameController.text.contains(' ')) {
        _usernameError = 'Username non può contenere spazi';
      }

      // Password validation
      if (_passwordController.text.isEmpty) {
        _passwordError = 'Password è richiesta';
      } else if (_passwordController.text.length < 6) {
        _passwordError = 'Password deve essere almeno 6 caratteri';
      }

      // Confirm password validation (for both login and registration)
      if (!_isLogin || _confirmPasswordController.text.isNotEmpty) {
        if (_confirmPasswordController.text.isEmpty) {
          _confirmPasswordError = 'Conferma password è richiesta';
        } else if (_passwordController.text !=
            _confirmPasswordController.text) {
          _confirmPasswordError = 'Le password non corrispondono';
        }
      }

      // Registration-specific validation
      if (!_isLogin) {
        // Email validation
        if (_emailController.text.isEmpty) {
          _emailError = 'Email è richiesta';
        } else if (!_emailController.text.contains('@')) {
          _emailError = 'Inserisci un email valida';
        }

        // First name validation
        if (_firstNameController.text.isEmpty) {
          _firstNameError = 'Nome è richiesto';
        }

        // Last name validation
        if (_lastNameController.text.isEmpty) {
          _lastNameError = 'Cognome è richiesto';
        }

        // License number validation
        if (_licenseNumberController.text.isEmpty) {
          _licenseNumberError = 'Numero di licenza è richiesto';
        }

        // Clinic name validation
        if (_clinicNameController.text.isEmpty) {
          _clinicNameError = 'Nome clinica è richiesto';
        }

        // Phone validation
        if (_phoneController.text.isEmpty) {
          _phoneError = 'Numero di telefono è richiesto';
        }
      }
    });
  }

  void _handleSubmit() async {
    _validateForm();

    if (_isLogin) {
      // Login validation
      if (_usernameError == null && _passwordError == null) {
        await _handleLogin();
      }
    } else {
      // Registration validation
      if (_usernameError == null &&
          _passwordError == null &&
          _confirmPasswordError == null &&
          _emailError == null &&
          _firstNameError == null &&
          _lastNameError == null &&
          _licenseNumberError == null &&
          _clinicNameError == null &&
          _phoneError == null) {
        await _handleRegistration();
      }
    }
  }

  Future<void> _handleLogin() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      print('🔑 LOGIN PAGE: Starting login process');
      final success = await authProvider.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (success) {
        // Navigation will be handled automatically by the router
        // due to the authentication state change - no need for dialog
        print(
          '🔑 LOGIN PAGE: Login successful, router should handle navigation',
        );
      } else {
        // Show error from auth provider
        final errorMessage =
            authProvider.errorMessage ??
            'Login fallito. Controlla le tue credenziali.';
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      _showErrorDialog('Si è verificato un errore imprevisto. Riprova.');
      debugPrint('Login error: $e');
    }
  }

  Future<void> _handleRegistration() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final profile = UserProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        licenseNumber: _licenseNumberController.text.trim(),
        clinicName: _clinicNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      print('🔑 REGISTRATION PAGE: Starting registration process');
      final response = await authProvider.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        profile: profile,
      );
      if (response != null) {
        // Show success message
        _showSuccessDialog(
          'Registrazione completata con successo!\n\n'
          'Il tuo account è in attesa di approvazione da parte dell\'amministratore. '
          'Riceverai una notifica una volta che il tuo account sarà approvato.',
        );

        // Clear form and switch to login mode
        _clearForm();
        setState(() {
          _isLogin = true;
        });
      } else {
        // Show error from auth provider
        final errorMessage =
            authProvider.errorMessage ??
            'Registrazione fallita. Controlla tutti i campi e riprova.';
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      _showErrorDialog(
        'Si è verificato un errore imprevisto durante la registrazione. Riprova.',
      );
      debugPrint('Registration error: $e');
    }
  }

  void _clearForm() {
    _usernameController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _emailController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _licenseNumberController.clear();
    _clinicNameController.clear();
    _phoneController.clear();

    setState(() {
      _usernameError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _emailError = null;
      _firstNameError = null;
      _lastNameError = null;
      _licenseNumberError = null;
      _clinicNameError = null;
      _phoneError = null;
    });
  }

  void _showSuccessDialog(String message) {
    showSuccessDialog(context: context, message: message);
  }

  void _showErrorDialog(String message) {
    showErrorDialog(context: context, message: message);
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _confirmPasswordController.clear();

      // Clear all errors
      _usernameError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _emailError = null;
      _firstNameError = null;
      _lastNameError = null;
      _licenseNumberError = null;
      _clinicNameError = null;
      _phoneError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundWhite,
      child: SafeArea(
        child: Container(
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
              // Back Button - Fixed at top
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingM),
                child: Row(
                  children: [
                    GhostButton(
                      size: ButtonSize.small,
                      onPressed: () => context.go('/'),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.chevron_left, size: 16),
                          SizedBox(width: AppDimensions.spacingXs),
                          Text('Torna alla Home'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content - Centered
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.spacingL),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.spacingXl),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundWhite.withValues(
                            alpha: 0.9,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLarge,
                          ),
                          border: Border.all(
                            color: AppColors.borderGray.withValues(alpha: 0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.foregroundDark.withValues(
                                alpha: 0.1,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            _buildHeader(),

                            const SizedBox(height: AppDimensions.spacingXl),

                            // Form
                            _buildForm(),

                            // Show auth error if any
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                if (authProvider.errorMessage != null) {
                                  return Column(
                                    children: [
                                      const SizedBox(
                                        height: AppDimensions.spacingM,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(
                                          AppDimensions.spacingM,
                                        ),
                                        decoration: BoxDecoration(
                                          color: CupertinoColors.systemRed
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            AppDimensions.radiusSmall,
                                          ),
                                          border: Border.all(
                                            color: CupertinoColors.systemRed
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              CupertinoIcons
                                                  .exclamationmark_triangle_fill,
                                              color: CupertinoColors.systemRed,
                                              size: 16,
                                            ),
                                            const SizedBox(
                                              width: AppDimensions.spacingS,
                                            ),
                                            Expanded(
                                              child: Text(
                                                authProvider.errorMessage!,
                                                style: AppTextStyles.body
                                                    .copyWith(
                                                      color:
                                                          CupertinoColors
                                                              .systemRed,
                                                      fontSize: 14,
                                                    ),
                                              ),
                                            ),
                                            CupertinoButton(
                                              padding: EdgeInsets.zero,
                                              onPressed:
                                                  () =>
                                                      authProvider.clearError(),
                                              child: const Icon(
                                                CupertinoIcons.xmark,
                                                color:
                                                    CupertinoColors.systemRed,
                                                size: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),

                            const SizedBox(height: AppDimensions.spacingL),

                            // Submit Button
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                final isLoading = authProvider.isLoading;
                                return PrimaryButton(
                                  size: ButtonSize.large,
                                  onPressed: isLoading ? null : _handleSubmit,
                                  child:
                                      isLoading
                                          ? const CupertinoActivityIndicator(
                                            color: AppColors.white,
                                          )
                                          : Text(
                                            _isLogin
                                                ? 'Accedi'
                                                : 'Crea Account',
                                          ),
                                );
                              },
                            ),

                            const SizedBox(height: AppDimensions.spacingL),

                            // Toggle
                            _buildToggle(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryBlue, Color(0xFF4A90E2)],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: const Center(
            child: Text(
              'V',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.spacingM),

        // Title
        Text(
          _isLogin ? 'Bentornato' : 'Crea Account',
          style: AppTextStyles.largeTitle.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppDimensions.spacingS),

        // Subtitle
        Text(
          _isLogin
              ? 'Accedi al tuo account VetAnalytics'
              : 'Inizia con VetAnalytics oggi',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        // Username Field
        AppTextInput(
          controller: _usernameController,
          label: 'Username',
          placeholder: 'Inserisci il tuo username',
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          errorText: _usernameError,
          prefix: const Padding(
            padding: EdgeInsets.only(
              left: AppDimensions.spacingS,
              right: AppDimensions.spacingM,
            ),
            child: Icon(
              CupertinoIcons.person,
              color: AppColors.mediumGray,
              size: 18,
            ),
          ),
        ),

        // Email Field (only for registration)
        if (!_isLogin) ...[
          const SizedBox(height: AppDimensions.spacingM),
          AppTextInput(
            controller: _emailController,
            label: 'Email',
            placeholder: 'Inserisci la tua email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            errorText: _emailError,
            prefix: const Padding(
              padding: EdgeInsets.only(
                left: AppDimensions.spacingS,
                right: AppDimensions.spacingM,
              ),
              child: Icon(
                CupertinoIcons.mail,
                color: AppColors.mediumGray,
                size: 18,
              ),
            ),
          ),
        ],

        const SizedBox(height: AppDimensions.spacingM),

        // Password Field
        AppTextInput(
          controller: _passwordController,
          label: 'Password',
          placeholder: 'Inserisci la tua password',
          obscureText: true,
          textInputAction:
              _isLogin ? TextInputAction.done : TextInputAction.next,
          errorText: _passwordError,
          prefix: const Padding(
            padding: EdgeInsets.only(
              left: AppDimensions.spacingS,
              right: AppDimensions.spacingM,
            ),
            child: Icon(
              CupertinoIcons.lock,
              color: AppColors.mediumGray,
              size: 18,
            ),
          ),
        ),

        // Registration-specific fields
        if (!_isLogin) ...[
          const SizedBox(height: AppDimensions.spacingM),

          // Confirm Password Field
          AppTextInput(
            controller: _confirmPasswordController,
            label: 'Conferma Password',
            placeholder: 'Conferma la tua password',
            obscureText: true,
            textInputAction: TextInputAction.next,
            errorText: _confirmPasswordError,
            prefix: const Padding(
              padding: EdgeInsets.only(
                left: AppDimensions.spacingS,
                right: AppDimensions.spacingM,
              ),
              child: Icon(
                CupertinoIcons.lock,
                color: AppColors.mediumGray,
                size: 18,
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingL),

          // Role Selection
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ruolo Professionale',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.foregroundDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                CupertinoSlidingSegmentedControl<UserRole>(
                  children: const {
                    UserRole.veterinarian: Padding(
                      padding: EdgeInsets.all(AppDimensions.spacingS),
                      child: Text('Veterinario'),
                    ),
                    UserRole.veterinaryTechnician: Padding(
                      padding: EdgeInsets.all(AppDimensions.spacingS),
                      child: Text('Tecnico'),
                    ),
                  },
                  onValueChanged: (UserRole? value) {
                    if (value != null) {
                      setState(() {
                        _selectedRole = value;
                      });
                    }
                  },
                  groupValue: _selectedRole,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingM),

          // First Name Field
          AppTextInput(
            controller: _firstNameController,
            label: 'Nome',
            placeholder: 'Inserisci il tuo nome',
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            errorText: _firstNameError,
            prefix: const Padding(
              padding: EdgeInsets.only(
                left: AppDimensions.spacingS,
                right: AppDimensions.spacingM,
              ),
              child: Icon(
                CupertinoIcons.person_fill,
                color: AppColors.mediumGray,
                size: 18,
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingM),

          // Last Name Field
          AppTextInput(
            controller: _lastNameController,
            label: 'Cognome',
            placeholder: 'Inserisci il tuo cognome',
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            errorText: _lastNameError,
            prefix: const Padding(
              padding: EdgeInsets.only(
                left: AppDimensions.spacingS,
                right: AppDimensions.spacingM,
              ),
              child: Icon(
                CupertinoIcons.person_fill,
                color: AppColors.mediumGray,
                size: 18,
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingM),

          // License Number Field
          AppTextInput(
            controller: _licenseNumberController,
            label: 'Numero di Licenza',
            placeholder: 'Inserisci il numero di licenza',
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            errorText: _licenseNumberError,
            prefix: const Padding(
              padding: EdgeInsets.only(
                left: AppDimensions.spacingS,
                right: AppDimensions.spacingM,
              ),
              child: Icon(
                CupertinoIcons.doc_text,
                color: AppColors.mediumGray,
                size: 18,
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingM),

          // Clinic Name Field
          AppTextInput(
            controller: _clinicNameController,
            label: 'Nome Clinica',
            placeholder: 'Inserisci il nome della clinica',
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            errorText: _clinicNameError,
            prefix: const Padding(
              padding: EdgeInsets.only(
                left: AppDimensions.spacingS,
                right: AppDimensions.spacingM,
              ),
              child: Icon(
                CupertinoIcons.building_2_fill,
                color: AppColors.mediumGray,
                size: 18,
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingM),

          // Phone Field
          AppTextInput(
            controller: _phoneController,
            label: 'Telefono',
            placeholder: 'Inserisci il numero di telefono',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            errorText: _phoneError,
            prefix: const Padding(
              padding: EdgeInsets.only(
                left: AppDimensions.spacingS,
                right: AppDimensions.spacingM,
              ),
              child: Icon(
                CupertinoIcons.phone,
                color: AppColors.mediumGray,
                size: 18,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildToggle() {
    return Center(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _toggleMode,
        child: Text(
          _isLogin
              ? 'Non hai un account? Registrati'
              : 'Hai già un account? Accedi',
          style: AppTextStyles.body.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
