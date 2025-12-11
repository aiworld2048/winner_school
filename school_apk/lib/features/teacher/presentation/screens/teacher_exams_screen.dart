import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/async_value_widget.dart';
import '../../../../common/widgets/empty_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../student/models/exam_models.dart';
import '../../providers/teacher_providers.dart';
import '../widgets/teacher_exam_form_sheet.dart';
import 'teacher_exam_detail_screen.dart';

class TeacherExamsScreen extends ConsumerStatefulWidget {
  const TeacherExamsScreen({super.key});

  @override
  ConsumerState<TeacherExamsScreen> createState() => _TeacherExamsScreenState();
}

class _TeacherExamsScreenState extends ConsumerState<TeacherExamsScreen> {
  String? _selectedType;
  bool? _isPublished;

  @override
  Widget build(BuildContext context) {
    final filters = {
      'type': _selectedType,
      'is_published': _isPublished,
    };
    final exams = ref.watch(teacherExamsProvider(filters));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams'),
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Type',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Types')),
                      DropdownMenuItem(value: 'quiz', child: Text('Quiz')),
                      DropdownMenuItem(value: 'assignment', child: Text('Assignment')),
                      DropdownMenuItem(value: 'midterm', child: Text('Midterm')),
                      DropdownMenuItem(value: 'final', child: Text('Final')),
                      DropdownMenuItem(value: 'project', child: Text('Project')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedType = value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<bool?>(
                    value: _isPublished,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: true, child: Text('Published')),
                      DropdownMenuItem(value: false, child: Text('Draft')),
                    ],
                    onChanged: (value) {
                      setState(() => _isPublished = value);
                    },
                  ),
                ),
              ],
            ),
          ),
          // Exams List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(teacherExamsProvider(filters));
                await ref.read(teacherExamsProvider(filters).future);
              },
              child: AsyncValueWidget(
                value: exams,
                builder: (examsList) {
                  if (examsList.isEmpty) {
                    return const EmptyState(
                      title: 'No exams yet',
                      message: 'Tap "New Exam" to create your first exam.',
                      icon: Icons.quiz_outlined,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: examsList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final exam = examsList[index] as Exam;
                      return _ExamCard(exam: exam);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateExam,
        icon: const Icon(Icons.add),
        label: const Text('New Exam'),
      ),
    );
  }

  Future<void> _openCreateExam() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const TeacherExamFormSheet(),
    );
    if (created == true) {
      final filters = {
        'type': _selectedType,
        'is_published': _isPublished,
      };
      ref.invalidate(teacherExamsProvider(filters));
    }
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam});

  final Exam exam;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: exam.isPublished
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.outline.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TeacherExamDetailScreen(examId: exam.id),
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
                        exam.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              exam.typeDisplay,
                              style: const TextStyle(fontSize: 11),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            exam.code,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: exam.isPublished
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.muted.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    exam.isPublished ? 'Published' : 'Draft',
                    style: TextStyle(
                      color: exam.isPublished ? AppColors.success : AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
                  exam.subject.name,
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(width: 16),
                Icon(Icons.class_outlined, size: 16, color: AppColors.muted),
                const SizedBox(width: 6),
                Text(
                  exam.classInfo.name,
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
                  DateFormat('MMM d, y • h:mm a').format(exam.examDate),
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(width: 16),
                Icon(Icons.timer_outlined, size: 16, color: AppColors.muted),
                const SizedBox(width: 6),
                Text(
                  exam.formattedDuration,
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.grade_outlined, size: 16, color: AppColors.muted),
                const SizedBox(width: 6),
                Text(
                  '${exam.totalMarks.toStringAsFixed(0)} marks (Pass: ${exam.passingMarks.toStringAsFixed(0)})',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

