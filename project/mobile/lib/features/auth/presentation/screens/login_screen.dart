import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/features/auth/presentation/controllers/login_controller.dart';
import 'package:ytu_assistant/features/auth/presentation/screens/_auth_error.dart';
import 'package:ytu_assistant/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:ytu_assistant/features/auth/presentation/widgets/email_field.dart';
import 'package:ytu_assistant/features/auth/presentation/widgets/password_field.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_snack_bar.dart';
import 'package:ytu_assistant/shared/widgets/primary_button.dart';
import 'package:ytu_assistant/shared/widgets/secondary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final L10n l10n = L10n.of(context);
    try {
      await ref.read(loginControllerProvider.notifier).submit(
            email: _email.text,
            password: _password.text,
          );
      // Successful login: the router redirect (watching authController) moves
      // us to /home automatically.
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppSnackBar.error(
        context,
        authErrorMessage(error, l10n: l10n, on401: l10n.snackInvalidCredentials),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final bool isLoading = ref.watch(loginControllerProvider).isLoading;

    return AuthScaffold(
      title: l10n.loginTitle,
      subtitle: l10n.loginSubtitle,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              EmailField(controller: _email, label: l10n.fieldEmail),
              const SizedBox(height: 16),
              PasswordField(
                controller: _password,
                label: l10n.fieldPassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed:
                      isLoading ? null : () => context.push('/forgot-password'),
                  child: Text(l10n.forgotPassword),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: l10n.actionSignIn,
                isLoading: isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 20),
              _OrDivider(label: l10n.dividerOr),
              const SizedBox(height: 20),
              SecondaryButton(
                label: l10n.actionCreateAccount,
                onPressed: isLoading ? null : () => context.push('/register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "─── veya ───" divider.
class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}
