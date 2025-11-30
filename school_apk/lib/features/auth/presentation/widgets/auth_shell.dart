import 'package:flutter/material.dart';

import '../../../../common/widgets/frosted_glass_card.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_spacing.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    this.form,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.heroHighlights,
    this.heroBadge,
    this.heroIcon = Icons.school_rounded,
    this.navActions = const [],
    this.promoSection,
  });

  final Widget? form;
  final String heroTitle;
  final String heroSubtitle;
  final List<String> heroHighlights;
  final String? heroBadge;
  final IconData heroIcon;
  final List<AuthNavAction> navActions;
  final Widget? promoSection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.hero),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final hasForm = form != null;

              if (isWide) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: AppSpacing.screenPadding,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _HeroPanel(this, navActions: navActions),
                                if (promoSection != null) ...[
                                  const SizedBox(height: 32),
                                  promoSection!,
                                ],
                              ],
                            ),
                          ),
                          if (hasForm) ...[
                            const SizedBox(width: 32),
                            Expanded(
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 460),
                                    child: form!,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: AppSpacing.screenPadding.copyWith(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeroPanel(this, compact: true, navActions: navActions),
                    if (promoSection != null) ...[
                      const SizedBox(height: 24),
                      promoSection!,
                    ],
                    if (hasForm) ...[
                      const SizedBox(height: 28),
                      form!,
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel(this.config, {this.compact = false, this.navActions = const []});

  final AuthShell config;
  final bool compact;
  final List<AuthNavAction> navActions;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final badge = config.heroBadge;

    return Padding(
      padding: EdgeInsets.only(right: compact ? 0 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (navActions.isNotEmpty) ...[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: navActions
                  .map(
                    (action) => _NavButton(
                      label: action.label,
                      onTap: action.onTap,
                      active: action.active,
                      isPrimary: action.isPrimary,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(config.heroIcon, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    badge,
                    style: textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            config.heroTitle,
            style: (compact ? textTheme.headlineLarge : textTheme.displaySmall)
                ?.copyWith(color: Colors.white, height: 1.1),
          ),
          const SizedBox(height: 16),
          Text(
            config.heroSubtitle,
            style: textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: config.heroHighlights
                .map(
                  (text) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Text(
                      text,
                      style: textTheme.labelLarge?.copyWith(color: Colors.white),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 32),
          FrostedGlassCard(
            borderRadius: 28,
            padding: const EdgeInsets.all(20),
            backgroundColor: Colors.white.withOpacity(0.12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '3,200+ students',
                        style: textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'already learning inside Winner School',
                        style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.onTap,
    required this.active,
    required this.isPrimary,
  });

  final String label;
  final VoidCallback? onTap;
  final bool active;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color baseColor = isPrimary ? Colors.white : Colors.white.withOpacity(0.18);
    final Color textColor = active ? AppGradients.hero.colors.first : Colors.white;

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        backgroundColor: onTap == null
            ? Colors.white.withOpacity(0.08)
            : (active ? Colors.white : baseColor),
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: onTap == null ? Colors.white70 : textColor,
        ),
      ),
    );
  }
}

class AuthNavAction {
  const AuthNavAction({
    required this.label,
    this.onTap,
    this.active = false,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool active;
  final bool isPrimary;
}

