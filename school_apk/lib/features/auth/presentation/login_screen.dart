import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/frosted_glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../marketing/models/public_highlights.dart';
import '../../marketing/providers/public_highlights_provider.dart';
import '../providers/auth_controller.dart';
import 'register_screen.dart';
import 'widgets/auth_shell.dart';
import 'widgets/auth_promo_section.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _modalVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showLoginModal(context);
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).login(
          _phoneController.text.trim(),
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final highlights = ref.watch(publicHighlightsProvider);
    final highlightData = highlights.valueOrNull;

    return AuthShell(
      heroTitle: 'Seamless learning hub',
      heroSubtitle: 'Connect teachers, students, lessons, and wallets in one modern workspace.',
      heroHighlights: const ['Teacher workspace', 'Secure wallet', 'Student portal'],
      heroBadge: 'Winner School Platform',
      navActions: [
        AuthNavAction(
          label: 'Login',
          active: true,
          isPrimary: true,
          onTap: () => _showLoginModal(context),
        ),
        AuthNavAction(
          label: 'Register',
          onTap: authState.isLoading
              ? null
              : () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
                },
        ),
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

  Future<void> _showLoginModal(BuildContext context) async {
    if (_modalVisible) return;
    _modalVisible = true;
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Consumer(
            builder: (context, ref, _) {
              final authState = ref.watch(authControllerProvider);
              final theme = Theme.of(context);
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: _buildLoginForm(dialogContext, theme, authState, ref),
              );
            },
          ),
        );
      },
    );
    if (mounted) {
      setState(() {
        _modalVisible = false;
      });
    } else {
      _modalVisible = false;
    }
  }

  Widget _buildLoginForm(
    BuildContext dialogContext,
    ThemeData theme,
    AsyncValue authState,
    WidgetRef ref,
  ) {
    return FrostedGlassCard(
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text('Welcome back', style: theme.textTheme.headlineSmall),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to access your classes, lessons, and wallet.',
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
                autofillHints: const [AutofillHints.telephoneNumber, AutofillHints.username],
                textInputAction: TextInputAction.next,
                validator: (value) => value == null || value.isEmpty ? 'Enter your phone number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_rounded),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                    icon: Icon(_obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter your password' : null,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => ref.read(authControllerProvider.notifier).bootstrap(),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: authState.isLoading ? null : _submit,
                icon: authState.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_rounded),
                label: const Text('Sign in'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: authState.isLoading
                    ? null
                    : () {
                        Navigator.of(dialogContext).pop();
                        Navigator.of(dialogContext).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                child: const Text('Create a new student account'),
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
}

