import 'package:flutter/material.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/core/utils/date_formatter.dart';
import 'package:ytu_assistant/features/applications/presentation/application_status_l10n.dart';
import 'package:ytu_assistant/features/jobs/data/models/applicant_model.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// Row in the applicants list.
class ApplicantTile extends StatelessWidget {
  const ApplicantTile({super.key, required this.applicant, this.onTap});

  final ApplicantModel applicant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: Text(
                  applicant.initials,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Builder(
                  builder: (BuildContext context) {
                    final L10n l10n = L10n.of(context);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          applicant.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _subtitle(l10n),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: <Widget>[
                            if (applicant.gpa != null) ...<Widget>[
                              _gpaPill(applicant.gpa!, l10n),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Text(
                                applicant.appliedAt == null
                                    ? (applicant.email ?? '')
                                    : l10n.appliedOn(
                                        DateFormatter.relativeTime(
                                            applicant.appliedAt!)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              _statusChip(context),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(L10n l10n) {
    final List<String> parts = <String>[];
    if ((applicant.department ?? '').trim().isNotEmpty) {
      parts.add(applicant.department!.trim());
    }
    if (applicant.classYear != null) {
      parts.add('${l10n.labelClassYear} ${applicant.classYear}');
    }
    if (parts.isEmpty && (applicant.email ?? '').isNotEmpty) {
      return applicant.email!;
    }
    return parts.join(' · ');
  }

  Widget _gpaPill(double gpa, L10n l10n) {
    final bool high = gpa >= 3.5;
    final String text = '${l10n.labelGpa} ${gpa.toStringAsFixed(2)}';
    if (high) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _statusChip(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final Color color = applicant.status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        applicant.status.localizedLabel(l10n),
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
