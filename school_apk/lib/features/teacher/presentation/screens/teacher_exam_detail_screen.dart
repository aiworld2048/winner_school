import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/async_value_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../student/models/exam_models.dart';
import '../../providers/teacher_providers.dart';

class TeacherExamDetailScreen extends ConsumerWidget {
  const TeacherExamDetailScreen({required this.examId, super.key});

  final int examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examAsync = ref.watch(teacherExamProvider(examId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Details'),
      ),
      body: AsyncValueWidget(
        value: examAsync,
        builder: (exam) {
          final examData = exam as Exam;
          final questions = examData.questions ?? [];
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: examData.isPublished
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : AppColors.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
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
                                    examData.title,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    examData.code,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.muted,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: examData.isPublished
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : AppColors.outline.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                examData.isPublished ? 'Published' : 'Draft',
                                style: TextStyle(
                                  color: examData.isPublished
                                      ? AppColors.primary
                                      : AppColors.muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.book_outlined, size: 16, color: AppColors.muted),
                            const SizedBox(width: 6),
                            Text(
                              examData.subject.name,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.muted,
                                  ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.class_outlined, size: 16, color: AppColors.muted),
                            const SizedBox(width: 6),
                            Text(
                              examData.classInfo.name,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                              DateFormat('MMM d, y • h:mm a').format(examData.examDate),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.muted,
                                  ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.timer_outlined, size: 16, color: AppColors.muted),
                            const SizedBox(width: 6),
                            Text(
                              examData.formattedDuration,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.muted,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.grade_outlined, size: 16, color: AppColors.muted),
                            const SizedBox(width: 6),
                            Text(
                              '${examData.totalMarks.toStringAsFixed(0)} marks (Pass: ${examData.passingMarks.toStringAsFixed(0)})',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.muted,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (examData.description != null && examData.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: AppColors.outline.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            examData.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Questions Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Questions (${questions.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (questions.isEmpty)
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Navigate to add question screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Add questions feature coming soon'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Questions'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (questions.isEmpty)
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: AppColors.outline.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.quiz_outlined,
                            size: 64,
                            color: AppColors.muted.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No questions yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.muted,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add questions to this exam',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.muted,
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppColors.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        question.questionText,
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      if (question.questionDescription != null &&
                                          question.questionDescription!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          question.questionDescription!,
                                          style: Theme.of(context).textTheme.bodySmall,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${question.marks.toStringAsFixed(0)} marks',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.outline.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    question.typeDisplay,
                                    style: TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                if (question.options != null && question.options!.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '${question.options!.length} options',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.muted,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                            if (question.options != null && question.options!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ...question.options!.map((option) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: option.isCorrect
                                                ? Colors.green
                                                : AppColors.outline,
                                            width: 2,
                                          ),
                                          color: option.isCorrect
                                              ? Colors.green.withValues(alpha: 0.1)
                                              : Colors.transparent,
                                        ),
                                        child: option.isCorrect
                                            ? const Icon(
                                                Icons.check,
                                                size: 12,
                                                color: Colors.green,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          option.optionText,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: option.isCorrect
                                                    ? Colors.green
                                                    : null,
                                                fontWeight: option.isCorrect
                                                    ? FontWeight.w600
                                                    : null,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

