import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/async_value_widget.dart';
import '../../../../common/widgets/empty_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/essay_models.dart';
import '../../providers/essay_providers.dart';
import 'student_essay_detail_screen.dart';

class StudentEssaysScreen extends ConsumerStatefulWidget {
  const StudentEssaysScreen({super.key});

  @override
  ConsumerState<StudentEssaysScreen> createState() => _StudentEssaysScreenState();
}

class _StudentEssaysScreenState extends ConsumerState<StudentEssaysScreen> {
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final essays = ref.watch(studentEssaysProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Essays'),
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedStatus == null,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedStatus = null);
                        }
                      },
                    ),
                    FilterChip(
                      label: const Text('Published'),
                      selected: _selectedStatus == 'published',
                      onSelected: (selected) {
                        setState(() => _selectedStatus = selected ? 'published' : null);
                      },
                    ),
                    FilterChip(
                      label: const Text('Draft'),
                      selected: _selectedStatus == 'draft',
                      onSelected: (selected) {
                        setState(() => _selectedStatus = selected ? 'draft' : null);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Essays List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(studentEssaysProvider);
                await ref.read(studentEssaysProvider.future);
              },
              child: AsyncValueWidget(
                value: essays,
                builder: (essaysList) {
                  // Filter essays based on selected status
                  final filteredEssays = _selectedStatus != null
                      ? essaysList.where((e) => e.status == _selectedStatus).toList()
                      : essaysList;

                  if (filteredEssays.isEmpty) {
                    return const EmptyState(
                      title: 'No essays found',
                      icon: Icons.article_outlined,
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredEssays.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final essay = filteredEssays[index];
                      return _EssayCard(essay: essay);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EssayCard extends StatelessWidget {
  const _EssayCard({required this.essay});

  final Essay essay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = essay.isOverdue;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isOverdue
              ? Colors.red.withValues(alpha: 0.3)
              : essay.status == 'published'
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.outline.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StudentEssayDetailScreen(essayId: essay.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          essay.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: essay.status == 'published'
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : AppColors.outline.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                essay.statusDisplay,
                                style: TextStyle(
                                  color: essay.status == 'published'
                                      ? AppColors.primary
                                      : AppColors.muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isOverdue) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Overdue',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.book_outlined, size: 16, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Text(
                    essay.subject.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.class_outlined, size: 16, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Text(
                    essay.classInfo.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Text(
                    'Due: ${DateFormat('MMM d, y').format(essay.dueDate)}${essay.dueTime != null ? ' • ${essay.dueTime}' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.grade_outlined, size: 16, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Text(
                    '${essay.totalMarks.toStringAsFixed(0)} marks',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              if (essay.wordCountMin != null || essay.wordCountMax != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.text_fields_outlined, size: 16, color: AppColors.muted),
                    const SizedBox(width: 6),
                    Text(
                      essay.wordCountDisplay,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

