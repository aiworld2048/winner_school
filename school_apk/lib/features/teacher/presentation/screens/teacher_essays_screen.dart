import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/async_value_widget.dart';
import '../../../../common/widgets/empty_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/essay_models.dart';
import '../../providers/essay_providers.dart';
import 'teacher_essay_detail_screen.dart';
import '../widgets/teacher_essay_form_sheet.dart';

class TeacherEssaysScreen extends ConsumerStatefulWidget {
  const TeacherEssaysScreen({super.key});

  @override
  ConsumerState<TeacherEssaysScreen> createState() => _TeacherEssaysScreenState();
}

class _TeacherEssaysScreenState extends ConsumerState<TeacherEssaysScreen> {
  String? _selectedStatus;
  int? _selectedSubjectId;
  int? _selectedClassId;

  @override
  Widget build(BuildContext context) {
    final filters = {
      'status': _selectedStatus,
      'subject_id': _selectedSubjectId,
      'class_id': _selectedClassId,
    };
    final essays = ref.watch(teacherEssaysProvider(filters));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Essays'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const TeacherEssayFormSheet(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All')),
                          DropdownMenuItem(value: 'published', child: Text('Published')),
                          DropdownMenuItem(value: 'draft', child: Text('Draft')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedStatus = value);
                        },
                      ),
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
                ref.invalidate(teacherEssaysProvider(filters));
                await ref.read(teacherEssaysProvider(filters).future);
              },
              child: AsyncValueWidget(
                value: essays,
                builder: (essaysList) {
                  if (essaysList.isEmpty) {
                    return const EmptyState(
                      title: 'No essays found',
                      icon: Icons.article_outlined,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: essaysList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final essay = essaysList[index];
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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: essay.status == 'published'
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.outline.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TeacherEssayDetailScreen(essayId: essay.id),
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
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                essay.statusDisplay,
                                style: const TextStyle(fontSize: 11),
                              ),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            if (essay.isOverdue) ...[
                              const SizedBox(width: 8),
                              Chip(
                                label: const Text(
                                  'Overdue',
                                  style: TextStyle(fontSize: 11, color: Colors.red),
                                ),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
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
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.class_outlined, size: 16, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Text(
                    essay.classInfo.name,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMM d, y').format(essay.dueDate) +
                        (essay.dueTime != null ? ' • ${essay.dueTime}' : ''),
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.grade_outlined, size: 16, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Text(
                    '${essay.totalMarks.toStringAsFixed(0)} marks',
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                  if (essay.viewsCount != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.visibility_outlined, size: 16, color: AppColors.muted),
                    const SizedBox(width: 6),
                    Text(
                      '${essay.viewsCount} views',
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

