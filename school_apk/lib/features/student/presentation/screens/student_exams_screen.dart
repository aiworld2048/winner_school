import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/empty_state.dart';
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
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
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
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(studentExamsProvider(filters));
                await ref.read(studentExamsProvider(filters).future);
              },
              child: exams.when(
                data: (examsList) {
                  if (examsList.isEmpty) {
                    return const EmptyState(
                      title: 'No exams found',
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) {
                  // Extract a user-friendly error message
                  String errorMessage = 'Unable to load exams.';
                  if (error.toString().contains('TimeoutException') || 
                      error.toString().contains('timed out')) {
                    errorMessage = 'Request timed out. Please check your internet connection.';
                  } else if (error.toString().contains('Failed to fetch')) {
                    errorMessage = 'Network error. Please check your connection.';
                  } else if (error.toString().contains('403') || 
                             error.toString().contains('Forbidden')) {
                    errorMessage = 'You do not have permission to view exams.';
                  } else if (error.toString().contains('401') || 
                             error.toString().contains('Unauthorized')) {
                    errorMessage = 'Please log in again.';
                  }

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading exams',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              ref.invalidate(studentExamsProvider(filters));
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
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

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam});

  final Exam exam;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUpcoming = exam.isUpcoming;
    final isPast = exam.isPast;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isUpcoming
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.outline.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StudentExamDetailScreen(examId: exam.id),
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
                  if (isUpcoming)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Upcoming',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else if (isPast)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.muted.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Past',
                        style: TextStyle(
                          color: AppColors.muted,
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

