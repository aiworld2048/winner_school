import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/content_card.dart';
import '../../../../common/widgets/error_state.dart';
import '../../../../common/widgets/filter_chips.dart';
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

    // Filter essays based on selected status
    final filteredEssays = essays.when(
      data: (essaysList) {
        if (_selectedStatus != null) {
          return essaysList.where((e) => e.status == _selectedStatus).toList();
        }
        return essaysList;
      },
      loading: () => <Essay>[],
      error: (_, __) => <Essay>[],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Essays'),
      ),
      body: Column(
        children: [
          // Filters
          FilterSection(
            child: StatusFilterChips(
              selectedStatus: _selectedStatus,
              onStatusChanged: (status) {
                setState(() => _selectedStatus = status);
              },
            ),
          ),
          // Essays List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(studentEssaysProvider);
                await ref.read(studentEssaysProvider.future);
              },
              child: essays.when(
                data: (_) {
                  if (filteredEssays.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No essays found'),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredEssays.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _EssayCard(essay: filteredEssays[index]);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) {
                  final errorMessage = ErrorState.extractErrorMessage(error);
                  return ErrorState(
                    title: 'Error loading essays',
                    message: errorMessage,
                    onRetry: () => ref.invalidate(studentEssaysProvider),
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

    return ContentCard(
      borderColor: isOverdue
          ? Colors.red.withValues(alpha: 0.3)
          : essay.status == 'published'
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.outline.withValues(alpha: 0.5),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StudentEssayDetailScreen(essayId: essay.id),
          ),
        );
      },
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
                        StatusBadge(
                          label: essay.statusDisplay,
                          color: essay.status == 'published'
                              ? AppColors.primary
                              : AppColors.muted,
                        ),
                        if (isOverdue) ...[
                          const SizedBox(width: 8),
                          const StatusBadge(
                            label: 'Overdue',
                            color: Colors.red,
                          ),
                        ],
                        if (essay.pdfFileUrl != null && essay.pdfFileUrl!.isNotEmpty) ...[
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
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              InfoRow(icon: Icons.book_outlined, text: essay.subject.name),
              const SizedBox(width: 16),
              InfoRow(icon: Icons.class_outlined, text: essay.classInfo.name),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              InfoRow(
                icon: Icons.calendar_today_outlined,
                text: 'Due: ${DateFormat('MMM d, y').format(essay.dueDate)}${essay.dueTime != null ? ' • ${essay.dueTime}' : ''}',
              ),
              const SizedBox(width: 16),
              InfoRow(
                icon: Icons.grade_outlined,
                text: '${essay.totalMarks.toStringAsFixed(0)} marks',
              ),
            ],
          ),
          if (essay.wordCountMin != null || essay.wordCountMax != null) ...[
            const SizedBox(height: 8),
            InfoRow(icon: Icons.text_fields_outlined, text: essay.wordCountDisplay),
          ],
        ],
      ),
    );
  }
}

