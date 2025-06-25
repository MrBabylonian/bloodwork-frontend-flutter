import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/models/patient_models.dart';
import '../../core/providers/patient_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../buttons/index.dart';
import '../forms/text_input.dart';
import '../forms/app_date_picker.dart';
import 'app_custom_dialog.dart';

/// Modal for updating an existing patient
class UpdatePatientModal extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final PatientModel patient;
  final VoidCallback? onPatientUpdated;

  const UpdatePatientModal({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.patient,
    this.onPatientUpdated,
  });

  @override
  State<UpdatePatientModal> createState() => _UpdatePatientModalState();
}

class _UpdatePatientModalState extends State<UpdatePatientModal> {
  late TextEditingController _nameController;
  late TextEditingController _ownerController;
  late TextEditingController _speciesController;
  late TextEditingController _breedController;
  late TextEditingController _weightController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _sexController;

  late DateTime _selectedBirthdate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _nameController = TextEditingController(text: p.name);
    _ownerController = TextEditingController(text: p.ownerInfo.name);
    _speciesController = TextEditingController(text: p.species);
    _breedController = TextEditingController(text: p.breed);
    _weightController = TextEditingController(text: p.weight?.toString() ?? '');
    _emailController = TextEditingController(text: p.ownerInfo.email);
    _phoneController = TextEditingController(text: p.ownerInfo.phone);
    _sexController = TextEditingController(text: p.sex);
    _selectedBirthdate = p.birthdate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _sexController.dispose();
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

    setState(() => _isLoading = true);

    try {
      double? weight;
      if (_weightController.text.isNotEmpty) {
        weight = double.tryParse(_weightController.text);
      }

      final updateRequest = PatientUpdateRequest(
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        breed: _breedController.text.trim(),
        birthdate: _selectedBirthdate,
        weight: weight,
        sex: _sexController.text.trim(),
        ownerInfo: PatientOwnerInfo(
          name: _ownerController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
        ),
      );

      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );
      final success = await patientProvider.updatePatient(
        widget.patient.patientId,
        updateRequest,
      );

      if (success) {
        widget.onClose();
        widget.onPatientUpdated?.call();
      } else {
        _showErrorDialog('Failed to update patient. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('Error updating patient: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showErrorDialog(context: context, message: message);
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
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(AppDimensions.spacingL),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Aggiorna Paziente', style: AppTextStyles.title2),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 0,
                          child: const Icon(CupertinoIcons.clear_circled),
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingL),
                    AppTextInput(
                      controller: _nameController,
                      label: 'Nome Paziente',
                      placeholder: 'Buddy',
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    AppTextInput(
                      controller: _ownerController,
                      label: 'Nome Proprietario',
                      placeholder: 'Mario Rossi',
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    AppTextInput(
                      controller: _speciesController,
                      label: 'Specie',
                      placeholder: 'Cane',
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    AppTextInput(
                      controller: _breedController,
                      label: 'Razza',
                      placeholder: 'Golden Retriever',
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextInput(
                            controller: _sexController,
                            label: 'Sesso',
                            placeholder: 'Maschio',
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingM),
                        Expanded(
                          child: AppTextInput(
                            controller: _weightController,
                            label: 'Peso',
                            placeholder: '25 kg',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    AppDatePickerField(
                      label: 'Data di Nascita',
                      selectedDate: _selectedBirthdate,
                      onDateChanged:
                          (d) => setState(() => _selectedBirthdate = d),
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    AppTextInput(
                      controller: _emailController,
                      label: 'Email di Contatto',
                      placeholder: 'email@example.com',
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    AppTextInput(
                      controller: _phoneController,
                      label: 'Telefono di Contatto',
                      placeholder: '+39 123 456 7890',
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SecondaryButton(
                          onPressed: widget.onClose,
                          child: const Text('Annulla'),
                        ),
                        const SizedBox(width: AppDimensions.spacingM),
                        PrimaryButton(
                          isLoading: _isLoading,
                          onPressed: _handleSubmit,
                          child: const Text('Aggiorna'),
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
    );
  }
}
