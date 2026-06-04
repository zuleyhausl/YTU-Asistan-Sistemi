import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ytu_assistant/core/network/localized_error.dart';
import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ytu_assistant/features/jobs/presentation/widgets/empty_state.dart';
import 'package:ytu_assistant/features/profile/data/models/education_model.dart';
import 'package:ytu_assistant/features/profile/data/models/experience_model.dart';
import 'package:ytu_assistant/features/profile/data/models/profile_model.dart';
import 'package:ytu_assistant/features/profile/data/models/user_language_model.dart';
import 'package:ytu_assistant/features/profile/data/models/user_skill_model.dart';
import 'package:ytu_assistant/features/profile/presentation/controllers/educations_controller.dart';
import 'package:ytu_assistant/features/profile/presentation/controllers/experiences_controller.dart';
import 'package:ytu_assistant/features/profile/presentation/controllers/profile_controller.dart';
import 'package:ytu_assistant/features/profile/presentation/widgets/education_tile.dart';
import 'package:ytu_assistant/features/profile/presentation/widgets/experience_tile.dart';
import 'package:ytu_assistant/features/profile/presentation/widgets/language_chip.dart';
import 'package:ytu_assistant/features/profile/presentation/widgets/profile_header.dart';
import 'package:ytu_assistant/features/profile/presentation/widgets/section_card.dart';
import 'package:ytu_assistant/features/profile/presentation/widgets/skill_chip.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_snack_bar.dart';

/// The real profile screen (replaces the placeholder). Shows the user header
/// and, for students, the CV sections (skills, languages, experience, education).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<bool> _confirmDelete(
    BuildContext context,
    L10n l10n,
    String title,
  ) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(title),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _deleteExperience(
    BuildContext context,
    WidgetRef ref,
    L10n l10n,
    ExperienceModel exp,
  ) async {
    if (!await _confirmDelete(context, l10n, l10n.deleteExperienceConfirm)) {
      return;
    }
    try {
      await ref.read(experiencesControllerProvider.notifier).remove(exp.id);
    } catch (error) {
      if (context.mounted) {
        AppSnackBar.error(context, localizedApiError(l10n, error));
      }
    }
  }

  Future<void> _deleteEducation(
    BuildContext context,
    WidgetRef ref,
    L10n l10n,
    EducationModel edu,
  ) async {
    if (!await _confirmDelete(context, l10n, l10n.deleteEducationConfirm)) {
      return;
    }
    try {
      await ref.read(educationsControllerProvider.notifier).remove(edu.id);
    } catch (error) {
      if (context.mounted) {
        AppSnackBar.error(context, localizedApiError(l10n, error));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final L10n l10n = L10n.of(context);
    final AsyncValue<ProfileModel> async = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, _) => EmptyState(
          icon: Icons.cloud_off_outlined,
          title: l10n.profileErrorTitle,
          subtitle: localizedApiError(l10n, error),
          actionLabel: l10n.actionRetry,
          onAction: () => ref.read(profileControllerProvider.notifier).refresh(),
        ),
        data: (ProfileModel profile) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(profileControllerProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: <Widget>[
              ProfileHeader(
                user: profile.user,
                academicTitle: profile.professor?.academicTitle,
                onEdit: () => context.push('/profile/edit'),
              ),
              const SizedBox(height: 24),
              if (profile.isStudent) ...<Widget>[
                _skillsSection(context, l10n, profile.skills),
                const SizedBox(height: 16),
                _languagesSection(context, l10n, profile.languages),
                const SizedBox(height: 16),
                _experienceSection(context, ref, l10n, profile.experiences),
                const SizedBox(height: 16),
                _educationSection(context, ref, l10n, profile.educations),
                const SizedBox(height: 24),
              ],
              _accountCard(context, ref, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyHint(L10n l10n) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(l10n.emptySectionGeneric, style: AppTextStyles.bodyMedium),
      );

  Widget _skillsSection(
    BuildContext context,
    L10n l10n,
    List<UserSkillModel> skills,
  ) {
    return SectionCard(
      icon: Icons.bolt_outlined,
      title: l10n.sectionSkills,
      actionLabel: l10n.actionAdd,
      onAction: () => context.push('/profile/skills'),
      child: skills.isEmpty
          ? _emptyHint(l10n)
          : Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills
                    .map((UserSkillModel s) => SkillChip(label: s.skillName))
                    .toList(),
              ),
            ),
    );
  }

  Widget _languagesSection(
    BuildContext context,
    L10n l10n,
    List<UserLanguageModel> languages,
  ) {
    return SectionCard(
      icon: Icons.translate_outlined,
      title: l10n.sectionLanguages,
      actionLabel: l10n.actionAdd,
      onAction: () => context.push('/profile/languages'),
      child: languages.isEmpty
          ? _emptyHint(l10n)
          : Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: languages
                    .map((UserLanguageModel lng) =>
                        LanguageChip(language: lng))
                    .toList(),
              ),
            ),
    );
  }

  Widget _experienceSection(
    BuildContext context,
    WidgetRef ref,
    L10n l10n,
    List<ExperienceModel> experiences,
  ) {
    return SectionCard(
      icon: Icons.work_outline,
      title: l10n.sectionExperience,
      actionLabel: l10n.actionAdd,
      onAction: () => context.push('/profile/experience'),
      child: experiences.isEmpty
          ? _emptyHint(l10n)
          : Column(
              children: experiences
                  .map((ExperienceModel e) => ExperienceTile(
                        experience: e,
                        onEdit: () =>
                            context.push('/profile/experience', extra: e),
                        onDelete: () =>
                            _deleteExperience(context, ref, l10n, e),
                      ))
                  .toList(),
            ),
    );
  }

  Widget _educationSection(
    BuildContext context,
    WidgetRef ref,
    L10n l10n,
    List<EducationModel> educations,
  ) {
    return SectionCard(
      icon: Icons.school_outlined,
      title: l10n.sectionEducation,
      actionLabel: l10n.actionAdd,
      onAction: () => context.push('/profile/education'),
      child: educations.isEmpty
          ? _emptyHint(l10n)
          : Column(
              children: educations
                  .map((EducationModel e) => EducationTile(
                        education: e,
                        onEdit: () =>
                            context.push('/profile/education', extra: e),
                        onDelete: () => _deleteEducation(context, ref, l10n, e),
                      ))
                  .toList(),
            ),
    );
  }

  Widget _accountCard(BuildContext context, WidgetRef ref, L10n l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l10n.changePasswordAction),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/change-password'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text(
              l10n.logoutAction,
              style: const TextStyle(color: AppColors.error),
            ),
            onTap: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}
