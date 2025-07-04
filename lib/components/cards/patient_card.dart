import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/models/patient_models.dart';
import '../../core/providers/tests_count_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/date_utils.dart';

/// Reusable card widget that displays a patient's key information.
class PatientCard extends StatelessWidget {
  final PatientModel patient;
  final VoidCallback? onTap;

  const PatientCard({super.key, required this.patient, this.onTap});

  @override
  Widget build(BuildContext context) {
    final testsProvider = context.watch<TestsCountProvider>();
    final testsCount = testsProvider.getCount(patient.id);

    // Trigger lazy load if needed.
    if (testsCount == null) {
      // Schedule after build to avoid setState during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TestsCountProvider>().loadCount(patient.id);
      });
    }

    return GestureDetector(
      onTap: onTap ?? () => context.go('/patient/${patient.id}'),
      child: IntrinsicHeight(
        child: Container(
          constraints: const BoxConstraints(minHeight: 240),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderGray.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.foregroundDark.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Proprietario: ${patient.ownerInfo.name}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Patient Details
              Expanded(
                child: Column(
                  children: [
                    _buildDetailRow(context, 'Specie:', patient.species),
                    const SizedBox(height: 6),
                    _buildDetailRow(context, 'Razza:', patient.breed),
                    const SizedBox(height: 6),
                    _buildDetailRow(context, 'Età:', patient.age.toString()),
                    const SizedBox(height: 6),
                    _buildDetailRow(
                      context,
                      'Data di nascita:',
                      formatShortDate(context, patient.birthdate),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Last Visit / Updated date
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formatShortDate(context, patient.updatedAt),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Tests Count
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.borderGray, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Test eseguiti:',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      testsCount?.toString() ?? '-',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------- Helper methods -----------------

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
