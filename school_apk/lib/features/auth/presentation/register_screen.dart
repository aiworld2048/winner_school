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
  final _referralController = TextEditingController(text: 'winnerschool');
  bool _obscurePassword = true;
  bool _modalVisible = false;
  int? _selectedClassId;
  int? _selectedSubjectId;
  int? _selectedAcademicYearId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = ref.read(publicHighlightsProvider).valueOrNull;
      _showRegisterModal(context, data);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext dialogContext) async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      await ref.read(authControllerProvider.notifier).register(
            _nameController.text.trim(),
            _phoneController.text.trim(),
            _passwordController.text,
            classId: _selectedClassId,
            subjectId: _selectedSubjectId,
            academicYearId: _selectedAcademicYearId,
            referralCode: _referralController.text.trim(),
          );
      
      // Only close dialog on success - AuthGate will automatically navigate to StudentShell
      if (mounted && dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }
    } catch (e) {
      // Error is already handled by the auth controller state
      // Dialog stays open to show error message
    }
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
        AuthNavAction(
          label: 'Register',
          active: true,
          isPrimary: true,
          onTap: () => _showRegisterModal(context, highlightData),
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

  Future<void> _showRegisterModal(BuildContext context, PublicHighlights? highlightData) async {
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
              final snapshot = ref.watch(publicHighlightsProvider);
              final data = highlightData ?? snapshot.valueOrNull;
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: _buildRegisterForm(dialogContext, theme, authState, ref, data),
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

  Widget _buildRegisterForm(
    BuildContext dialogContext,
    ThemeData theme,
    AsyncValue authState,
    WidgetRef ref,
    PublicHighlights? highlights,
  ) {
    final classes = highlights?.classes ?? [];
    final subjects = highlights?.courses ?? [];
    final academicYears = highlights?.academicYears ?? [];

    return FrostedGlassCard(
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text('Student registration', style: theme.textTheme.headlineSmall),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _referralController,
                decoration: const InputDecoration(
                  labelText: 'Referral code',
                  prefixIcon: Icon(Icons.card_membership_rounded),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedClassId,
                items: classes
                    .map(
                      (clazz) => DropdownMenuItem(
                        value: clazz.id,
                        child: Text(
                          [
                            if (clazz.name.isNotEmpty) clazz.name,
                            if (clazz.gradeLevel != null) 'Grade ${clazz.gradeLevel}',
                            if (clazz.section != null) 'Section ${clazz.section}',
                          ].whereType<String>().join(' • '),
                        ),
                      ),
                    )
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Select class',
                  prefixIcon: Icon(Icons.class_outlined),
                  helperText: classes.isEmpty ? 'Classes will be assigned by your teacher later.' : null,
                ),
                validator: (value) =>
                    classes.isEmpty ? null : (value == null ? 'Please choose a class' : null),
                onChanged: classes.isEmpty ? null : (value) => setState(() => _selectedClassId = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedSubjectId,
                items: subjects
                    .map(
                      (subject) => DropdownMenuItem(
                        value: subject.id,
                        child: Text(subject.title),
                      ),
                    )
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Preferred subject',
                  prefixIcon: Icon(Icons.menu_book_outlined),
                  helperText: subjects.isEmpty ? 'Subjects will be assigned later.' : null,
                ),
                validator: (value) =>
                    subjects.isEmpty ? null : (value == null ? 'Please choose a subject' : null),
                onChanged: subjects.isEmpty ? null : (value) => setState(() => _selectedSubjectId = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedAcademicYearId,
                items: academicYears
                    .map(
                      (year) => DropdownMenuItem(
                        value: year.id,
                        child: Text(year.name),
                      ),
                    )
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Academic year',
                  prefixIcon: Icon(Icons.calendar_month),
                  helperText: academicYears.isEmpty ? 'Academic years unavailable.' : null,
                ),
                validator: (value) =>
                    academicYears.isEmpty ? null : (value == null ? 'Select academic year' : null),
                onChanged:
                    academicYears.isEmpty ? null : (value) => setState(() => _selectedAcademicYearId = value),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: authState.isLoading ? null : () => _submit(dialogContext),
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
                          color: AppColors.danger.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
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

