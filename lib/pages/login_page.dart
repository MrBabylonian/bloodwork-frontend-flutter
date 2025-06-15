import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';
import '../components/buttons/index.dart';
import '../components/forms/text_input.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;

      // Email validation
      if (_emailController.text.isEmpty) {
        _emailError = 'Email è richiesta';
      } else if (!_emailController.text.contains('@')) {
        _emailError = 'Inserisci un email valida';
      }

      // Password validation
      if (_passwordController.text.isEmpty) {
        _passwordError = 'Password è richiesta';
      } else if (_passwordController.text.length < 6) {
        _passwordError = 'Password deve essere almeno 6 caratteri';
      }

      // Confirm password validation (only for registration)
      if (!_isLogin) {
        if (_confirmPasswordController.text.isEmpty) {
          _confirmPasswordError = 'Conferma password è richiesta';
        } else if (_passwordController.text !=
            _confirmPasswordController.text) {
          _confirmPasswordError = 'Le password non corrispondono';
        }
      }
    });
  }

  void _handleSubmit() {
    _validateForm();

    if (_emailError == null &&
        _passwordError == null &&
        (_isLogin || _confirmPasswordError == null)) {
      // Simulate authentication
      debugPrint(_isLogin ? 'Bentornato!' : 'Account creato con successo!');

      // Navigate to dashboard (we'll implement this route next)
      if (mounted) {
        context.go('/dashboard');
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _confirmPasswordController.clear();
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
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

                            const SizedBox(height: AppDimensions.spacingL),

                            // Submit Button
                            PrimaryButton(
                              size: ButtonSize.large,
                              onPressed: _handleSubmit,
                              child: Text(_isLogin ? 'Accedi' : 'Crea Account'),
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
        // Email Field
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

        // Confirm Password Field (only for registration)
        if (!_isLogin) ...[
          const SizedBox(height: AppDimensions.spacingM),
          AppTextInput(
            controller: _confirmPasswordController,
            label: 'Conferma Password',
            placeholder: 'Conferma la tua password',
            obscureText: true,
            textInputAction: TextInputAction.done,
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
