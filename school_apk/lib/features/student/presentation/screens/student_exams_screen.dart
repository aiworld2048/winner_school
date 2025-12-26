import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/content_card.dart';
import '../../../../common/widgets/filter_chips.dart';
import '../../../../common/widgets/refreshable_list.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/exam_models.dart';
import '../../providers/exam_providers.dart';
import 'student_exam_detail_screen.dart';

class StudentExamsScreen extends ConsumerStatefulWidget {
  const StudentExamsScreen({super.key});

  @override
  ConsumerState<StudentExamsScreen> createState() => _StudentExamsScreenState();
}

class _StudentExamsScreenState extends ConsumerState<StudentExamsScreen> {
  String? _selectedType;
  bool _upcomingOnly = false;

  @override
  Widget build(BuildContext context) {
    final filters = {
      'type': _selectedType,
      'upcoming_only': _upcomingOnly,
    };
    final exams = ref.watch(studentExamsProvider(filters));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams'),
      ),
      body: Column(
        children: [
          // Filters
          FilterSection(
            child: Column(
              children: [
                Row(
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
                    FilterChip(
                      label: const Text('Upcoming Only'),
                      selected: _upcomingOnly,
                      onSelected: (selected) {
                        setState(() => _upcomingOnly = selected);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Exams List
          Expanded(
            child: RefreshableList<Exam>(
              asyncValue: exams,
              onRefresh: () async {
                ref.invalidate(studentExamsProvider(filters));
                await ref.read(studentExamsProvider(filters).future);
              },
              itemBuilder: (context, exam, index) => _ExamCard(exam: exam),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              emptyTitle: 'No exams found',
              emptyIcon: Icons.quiz_outlined,
              errorTitle: 'Error loading exams',
              onRetry: () => ref.invalidate(studentExamsProvider(filters)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam});

  final Exam exam;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUpcoming = exam.isUpcoming;
    final isPast = exam.isPast;

    return ContentCard(
      borderColor: isUpcoming
          ? AppColors.primary.withValues(alpha: 0.3)
          : AppColors.outline.withValues(alpha: 0.5),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StudentExamDetailScreen(examId: exam.id),
          ),
        );
      },
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
                        if (exam.pdfFileUrl != null && exam.pdfFileUrl!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.picture_as_pdf,
                                  size: 14,
                                  color: Colors.red[800],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'PDF',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (isUpcoming)
                const StatusBadge(
                  label: 'Upcoming',
                  color: AppColors.primary,
                )
              else if (isPast)
                const StatusBadge(
                  label: 'Past',
                  color: AppColors.muted,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              InfoRow(icon: Icons.book_outlined, text: exam.subject.name),
              const SizedBox(width: 16),
              InfoRow(icon: Icons.class_outlined, text: exam.classInfo.name),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              InfoRow(
                icon: Icons.calendar_today_outlined,
                text: DateFormat('MMM d, y • h:mm a').format(exam.examDate),
              ),
              const SizedBox(width: 16),
              InfoRow(icon: Icons.timer_outlined, text: exam.formattedDuration),
            ],
          ),
          const SizedBox(height: 8),
          InfoRow(
            icon: Icons.grade_outlined,
            text: '${exam.totalMarks.toStringAsFixed(0)} marks (Pass: ${exam.passingMarks.toStringAsFixed(0)})',
          ),
        ],
      ),
    );
  }
}

