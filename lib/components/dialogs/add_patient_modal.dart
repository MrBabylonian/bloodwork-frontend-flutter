import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../dialogs/app_generic_dialog.dart';
import '../forms/app_form.dart';
import '../forms/app_label.dart';
import '../buttons/primary_button.dart';
import '../buttons/outline_button.dart';

/// Data model for patient form
class PatientFormData {
  final String name;
  final String owner;
  final String species;
  final String breed;
  final String age;
  final String weight;
  final String contactEmail;
  final String contactPhone;

  const PatientFormData({
    required this.name,
    required this.owner,
    required this.species,
    required this.breed,
    required this.age,
    required this.weight,
    required this.contactEmail,
    required this.contactPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'owner': owner,
      'species': species,
      'breed': breed,
      'age': age,
      'weight': weight,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
    };
  }
}

/// A modal dialog for adding new patient information
///
/// This modal provides a comprehensive form for entering patient details
/// including personal information, physical characteristics, and contact details.
class AddPatientModal extends StatefulWidget {
  /// Whether the modal is currently visible
  final bool isOpen;

  /// Callback when the modal should be closed
  final ValueChanged<bool> onOpenChanged;

  /// Callback when a new patient is submitted
  final ValueChanged<PatientFormData>? onPatientAdded;

  const AddPatientModal({
    super.key,
    required this.isOpen,
    required this.onOpenChanged,
    this.onPatientAdded,
  });

  @override
  State<AddPatientModal> createState() => _AddPatientModalState();
}

class _AddPatientModalState extends State<AddPatientModal> {
  late AppFormController _formController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _formController = AppFormController();
    _setupForm();
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  void _setupForm() {
    // Register form fields with validators
    _formController.registerField<String>(
      'name',
      validator: AppFormValidators.required('Patient name is required'),
    );
    _formController.registerField<String>(
      'owner',
      validator: AppFormValidators.required('Owner name is required'),
    );
    _formController.registerField<String>(
      'species',
      validator: AppFormValidators.required('Species is required'),
    );
    _formController.registerField<String>('breed');
    _formController.registerField<String>('age');
    _formController.registerField<String>('weight');
    _formController.registerField<String>(
      'contactEmail',
      validator: AppFormValidators.combine([
        AppFormValidators.required('Email is required'),
        AppFormValidators.email(),
      ]),
    );
    _formController.registerField<String>('contactPhone');
  }

  void _onSubmit() async {
    if (_isSubmitting) return;

    if (!_formController.validateAll()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final data = _formController.getData();
      final patientData = PatientFormData(
        name: data['name'] ?? '',
        owner: data['owner'] ?? '',
        species: data['species'] ?? '',
        breed: data['breed'] ?? '',
        age: data['age'] ?? '',
        weight: data['weight'] ?? '',
        contactEmail: data['contactEmail'] ?? '',
        contactPhone: data['contactPhone'] ?? '',
      );

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      widget.onPatientAdded?.call(patientData);
      _formController.reset();
      widget.onOpenChanged(false);
    } catch (e) {
      // Handle error - in a real app you'd show a toast or snackbar
      debugPrint('Error adding patient: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _onCancel() {
    _formController.reset();
    widget.onOpenChanged(false);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) {
      return const SizedBox.shrink();
    }

    return AppGenericDialog(
      title: Row(
        children: [
          Icon(CupertinoIcons.add, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: AppDimensions.spacingXs),
          Text('Add New Patient', style: AppTextStyles.title3),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: AppForm(
          controller: _formController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient and Owner Info
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      name: 'name',
                      label: 'Patient Name',
                      placeholder: 'Buddy',
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Expanded(
                    child: _buildFormField(
                      name: 'owner',
                      label: 'Owner Name',
                      placeholder: 'John Smith',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Species and Breed
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      name: 'species',
                      label: 'Species',
                      placeholder: 'Dog',
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Expanded(
                    child: _buildFormField(
                      name: 'breed',
                      label: 'Breed',
                      placeholder: 'Golden Retriever',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Age and Weight
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      name: 'age',
                      label: 'Age',
                      placeholder: '5 years',
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Expanded(
                    child: _buildFormField(
                      name: 'weight',
                      label: 'Weight',
                      placeholder: '25 kg',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Contact Information
              _buildFormField(
                name: 'contactEmail',
                label: 'Contact Email',
                placeholder: 'owner@email.com',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: AppDimensions.spacingM),

              _buildFormField(
                name: 'contactPhone',
                label: 'Contact Phone',
                placeholder: '+1 (555) 123-4567',
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlineButton(
          onPressed: _isSubmitting ? null : _onCancel,
          child: const Text('Cancel'),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        PrimaryButton(
          onPressed: _isSubmitting ? null : _onSubmit,
          isLoading: _isSubmitting,
          child: const Text('Add Patient'),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String name,
    required String label,
    required String placeholder,
    TextInputType? keyboardType,
  }) {
    return AppFormField<String>(
      name: name,
      builder: (context, value, error, onChanged) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppLabel(
              text: label,
              required:
                  name == 'name' ||
                  name == 'owner' ||
                  name == 'species' ||
                  name == 'contactEmail',
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            CupertinoTextField(
              controller: TextEditingController(text: value ?? ''),
              placeholder: placeholder,
              onChanged: onChanged,
              keyboardType: keyboardType,
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border:
                    error != null
                        ? Border.all(color: AppColors.primaryBlue, width: 1)
                        : null,
              ),
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              style: AppTextStyles.body,
            ),
            if (error != null) ...[
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                error,
                style: AppTextStyles.footnote.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Helper function to show the AddPatientModal
Future<PatientFormData?> showAddPatientModal({
  required BuildContext context,
  ValueChanged<PatientFormData>? onPatientAdded,
}) {
  return showCupertinoDialog<PatientFormData>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          bool isOpen = true;

          return AddPatientModal(
            isOpen: isOpen,
            onOpenChanged: (open) {
              if (!open) {
                setState(() => isOpen = false);
                Navigator.of(context).pop();
              }
            },
            onPatientAdded: (data) {
              onPatientAdded?.call(data);
              Navigator.of(context).pop(data);
            },
          );
        },
      );
    },
  );
}
