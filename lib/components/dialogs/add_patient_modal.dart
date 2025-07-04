import 'package:flutter/material.dart' hide IconButton, showDatePicker;
import 'package:flutter/material.dart'
    as material
    show IconButton, CircularProgressIndicator, showDatePicker;
import 'package:flutter/material.dart' as material_icons;
import 'package:provider/provider.dart';
import '../../core/models/patient_models.dart';
import '../../core/providers/patient_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../buttons/index.dart';
import '../forms/text_input.dart';
import 'app_custom_dialog.dart';

/// Modal for adding a new patient
class AddPatientModal extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final VoidCallback? onPatientCreated; // Callback for when patient is created

  const AddPatientModal({
    super.key,
    required this.isOpen,
    required this.onClose,
    this.onPatientCreated,
  });

  @override
  State<AddPatientModal> createState() => _AddPatientModalState();
}

class _AddPatientModalState extends State<AddPatientModal> {
  final _nameController = TextEditingController();
  final _ownerController = TextEditingController();
  final _speciesController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _sexController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Birthdate instead of age
  DateTime _selectedBirthdate = DateTime.now().subtract(
    const Duration(days: 365),
  ); // Default to 1 year old

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _sexController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Basic validation
    if (_nameController.text.trim().isEmpty ||
        _ownerController.text.trim().isEmpty ||
        _speciesController.text.trim().isEmpty ||
        _sexController.text.trim().isEmpty) {
      _showErrorDialog('Please fill in all required fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      double? weight;
      if (_weightController.text.isNotEmpty) {
        weight = double.tryParse(_weightController.text);
      }

      // Create patient request
      final request = PatientCreateRequest(
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        breed: _breedController.text.trim(),
        birthdate: _selectedBirthdate,
        sex: _sexController.text.trim(),
        weight: weight,
        ownerInfo: PatientOwnerInfo(
          name: _ownerController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
        ),
        medicalHistory: const {}, // Empty medical history
      );

      // Create patient through provider
      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );
      final success = await patientProvider.createPatient(request);

      if (success) {
        _clearForm();
        widget.onClose();
        widget.onPatientCreated?.call(); // Notify parent
      } else {
        _showErrorDialog('Failed to create patient. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('Error creating patient: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showErrorDialog(context: context, message: message);
  }

  void _clearForm() {
    _nameController.clear();
    _ownerController.clear();
    _speciesController.clear();
    _breedController.clear();
    _weightController.clear();
    _sexController.clear();
    _emailController.clear();
    _phoneController.clear();
    setState(() {
      _selectedBirthdate = DateTime.now().subtract(const Duration(days: 365));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox.shrink();

    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: AppColors.foregroundDark.withValues(alpha: 0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping on modal content
            child: Material(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              elevation: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 500),
                margin: const EdgeInsets.all(AppDimensions.spacingL),
                padding: const EdgeInsets.all(AppDimensions.spacingXl),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          const Icon(
                            material_icons.Icons.add,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: AppDimensions.spacingS),
                          Text(
                            'Aggiungi Nuovo Paziente',
                            style: AppTextStyles.title3.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          material.IconButton(
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              material_icons.Icons.close,
                              color: AppColors.mediumGray,
                              size: 20,
                            ),
                            onPressed: widget.onClose,
                          ),
                        ],
                      ),

                      const SizedBox(height: AppDimensions.spacingXl),

                      // Form
                      _buildForm(),

                      const SizedBox(height: AppDimensions.spacingXl),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: GhostButton(
                              size: ButtonSize.large,
                              onPressed: widget.onClose,
                              child: const Text('Annulla'),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingM),
                          Expanded(
                            child: PrimaryButton(
                              size: ButtonSize.large,
                              onPressed: _isLoading ? null : _handleSubmit,
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child:
                                            material.CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                      )
                                      : const Text('Aggiungi Paziente'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        // Name and Owner
        Row(
          children: [
            Expanded(
              child: AppTextInput(
                controller: _nameController,
                label: 'Nome Paziente',
                placeholder: 'Buddy',
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: AppTextInput(
                controller: _ownerController,
                label: 'Nome Proprietario',
                placeholder: 'Mario Rossi',
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.spacingL),

        // Species and Breed
        Row(
          children: [
            Expanded(
              child: AppTextInput(
                controller: _speciesController,
                label: 'Specie',
                placeholder: 'Cane',
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: AppTextInput(
                controller: _breedController,
                label: 'Razza',
                placeholder: 'Golden Retriever',
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.spacingL),

        // Sex and Weight Row
        Row(
          children: [
            Expanded(
              child: AppTextInput(
                controller: _sexController,
                label: 'Sesso',
                placeholder: 'Maschio',
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: AppTextInput(
                controller: _weightController,
                label: 'Peso',
                placeholder: '25 kg',
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.spacingL),

        // Date of Birth row (full width)
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  material_icons.Icons.calendar_today,
                  size: 16,
                  color: AppColors.mediumGray,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Data di Nascita',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(_selectedBirthdate),
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.spacingL),

        // Contact Email
        AppTextInput(
          controller: _emailController,
          label: 'Email di Contatto',
          placeholder: 'proprietario@email.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),

        const SizedBox(height: AppDimensions.spacingL),

        // Contact Phone
        AppTextInput(
          controller: _phoneController,
          label: 'Telefono di Contatto',
          placeholder: '+39 123 456 7890',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await material.showDatePicker(
      context: context,
      initialDate: _selectedBirthdate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedBirthdate = picked);
    }
  }
}
