import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/frosted_glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../marketing/models/public_highlights.dart';
import '../../marketing/providers/public_highlights_provider.dart';
import '../providers/auth_controller.dart';
import 'widgets/auth_shell.dart';
import 'widgets/auth_promo_section.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).register(
          _nameController.text.trim(),
          _phoneController.text.trim(),
          _passwordController.text,
        );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final highlights = ref.watch(publicHighlightsProvider);
    final highlightData = highlights.valueOrNull;

    return AuthShell(
      heroTitle: 'Join Winner School',
      heroSubtitle: 'Create your student account to receive lessons, wallet updates, and media alerts.',
      heroHighlights: const ['Student-focused UI', 'Lesson reminders', 'Wallet insights'],
      heroBadge: 'New to the platform?',
      navActions: [
        AuthNavAction(
          label: 'Login',
          onTap: authState.isLoading
              ? null
              : () {
                  Navigator.of(context).maybePop();
                },
        ),
        const AuthNavAction(label: 'Register', active: true, isPrimary: true),
        AuthNavAction(
          label: 'Courses',
          onTap: highlightData == null ? null : () => _showHighlightsSheet(context, highlightData),
        ),
      ],
      promoSection: highlights.when(
        data: (data) => AuthPromoSection(
          data: data,
          onViewCourses: () => _showHighlightsSheet(context, data),
        ),
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Unable to load academy preview • ${error.toString()}',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ),
      ),
      form: FrostedGlassCard(
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Text('Student registration', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'We will verify your phone number with your assigned teacher.',
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.badge_rounded),
                ),
                autofillHints: const [AutofillHints.name],
                textInputAction: TextInputAction.next,
                validator: (value) => value == null || value.isEmpty ? 'Enter your full name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
                autofillHints: const [AutofillHints.telephoneNumber, AutofillHints.username],
                textInputAction: TextInputAction.next,
                validator: (value) => value == null || value.isEmpty ? 'Enter a phone number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  labelText: 'Create password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                    icon: Icon(_obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) =>
                    value != null && value.length >= 6 ? null : 'Use at least 6 characters',
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: authState.isLoading ? null : _submit,
                icon: authState.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_rounded),
                label: const Text('Create account'),
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: authState.hasError
                    ? Container(
                        key: ValueKey(authState.error),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.danger.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.danger),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                authState.error.toString(),
                                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.danger),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHighlightsSheet(BuildContext context, PublicHighlights data) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => AuthHighlightsSheet(data: data),
    );
  }
}

