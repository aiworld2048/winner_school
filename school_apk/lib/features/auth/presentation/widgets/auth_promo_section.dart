import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../marketing/models/public_highlights.dart';

class AuthPromoSection extends StatelessWidget {
  const AuthPromoSection({
    super.key,
    required this.data,
    this.onViewCourses,
  });

  final PublicHighlights data;
  final VoidCallback? onViewCourses;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final headerColor = Colors.white;
    final subheaderColor = Colors.white.withOpacity(0.75);
    final actionColor = Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview the academy',
                    style: textTheme.titleLarge?.copyWith(color: headerColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Browse featured courses, lessons, and classes before signing in.',
                    style: textTheme.bodyMedium?.copyWith(color: subheaderColor),
                  ),
                ],
              ),
            ),
            if (onViewCourses != null)
              TextButton.icon(
                onPressed: onViewCourses,
                style: TextButton.styleFrom(foregroundColor: actionColor),
                icon: const Icon(Icons.explore_outlined),
                label: const Text('View courses'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatCard(
              label: 'Students',
              value: data.stats.students,
              icon: Icons.groups_rounded,
            ),
            _StatCard(
              label: 'Teachers',
              value: data.stats.teachers,
              icon: Icons.school_rounded,
            ),
            _StatCard(
              label: 'Lessons',
              value: data.stats.lessons,
              icon: Icons.menu_book_rounded,
            ),
            _StatCard(
              label: 'Classes',
              value: data.stats.classes,
              icon: Icons.class_rounded,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _HorizontalScroller(
          title: 'Courses',
          emptyLabel: 'Courses coming soon',
          items: data.courses.map((course) => _ScrollerItem(title: course.title, subtitle: course.description)).toList(),
        ),
        const SizedBox(height: 12),
        _HorizontalScroller(
          title: 'Recent lessons',
          emptyLabel: 'Lessons will appear here',
          items: data.lessons
              .map(
                (lesson) => _ScrollerItem(
                  title: lesson.title,
                  subtitle: [
                    if (lesson.subjectName != null) lesson.subjectName,
                    if (lesson.className != null) lesson.className,
                  ].whereType<String>().join(' • '),
                  badge: lesson.lessonDate,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        _HorizontalScroller(
          title: 'Classes',
          emptyLabel: 'Classes pending',
          items: data.classes
              .map(
                (clazz) => _ScrollerItem(
                  title: clazz.name,
                  subtitle: clazz.section != null ? 'Section ${clazz.section}' : null,
                  badge: clazz.gradeLevel != null ? 'Grade ${clazz.gradeLevel}' : null,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _HorizontalScroller extends StatelessWidget {
  const _HorizontalScroller({
    required this.title,
    required this.emptyLabel,
    required this.items,
  });

  final String title;
  final String emptyLabel;
  final List<_ScrollerItem> items;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.titleMedium),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text(emptyLabel, style: textTheme.bodySmall?.copyWith(color: AppColors.muted))
        else
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _PromoPill(item: items[index]),
            ),
          ),
      ],
    );
  }
}

class _ScrollerItem {
  _ScrollerItem({required this.title, this.subtitle, this.badge});

  final String title;
  final String? subtitle;
  final String? badge;
}

class _PromoPill extends StatelessWidget {
  const _PromoPill({required this.item});

  final _ScrollerItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              item.subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (item.badge != null) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                item.badge!,
                style: theme.textTheme.labelSmall?.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AuthHighlightsSheet extends StatelessWidget {
  const AuthHighlightsSheet({super.key, required this.data});

  final PublicHighlights data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Academy overview', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Browse top courses, lessons, and classes curated for you.',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 24),
            _buildListSection(
              context,
              title: 'Courses',
              icon: Icons.menu_book_outlined,
              items: data.courses.map((course) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(course.title),
                    subtitle: course.description != null ? Text(course.description!) : null,
                  )),
            ),
            _buildListSection(
              context,
              title: 'Recent lessons',
              icon: Icons.play_lesson_outlined,
              items: data.lessons.map((lesson) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(lesson.title),
                    subtitle: Text(
                      [
                        if (lesson.subjectName != null) lesson.subjectName,
                        if (lesson.className != null) lesson.className,
                      ].whereType<String>().join(' • '),
                    ),
                    trailing: lesson.lessonDate != null ? Text(lesson.lessonDate!) : null,
                  )),
            ),
            _buildListSection(
              context,
              title: 'Featured classes',
              icon: Icons.class_outlined,
              items: data.classes.map((clazz) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(clazz.name),
                    subtitle: Text(
                      [
                        if (clazz.gradeLevel != null) 'Grade ${clazz.gradeLevel}',
                        if (clazz.section != null) 'Section ${clazz.section}',
                      ].whereType<String>().join(' • '),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Iterable<Widget> items,
  }) {
    final children = items.toList();
    if (children.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.muted),
            const SizedBox(width: 8),
            Text('$title coming soon', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

