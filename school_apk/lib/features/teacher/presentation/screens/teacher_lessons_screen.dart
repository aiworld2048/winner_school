import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/async_value_widget.dart';
import '../../../../common/widgets/empty_state.dart';
import '../../../student/models/lesson_models.dart';
import '../../providers/teacher_providers.dart';

class TeacherLessonsScreen extends ConsumerWidget {
  const TeacherLessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = ref.watch(teacherLessonsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(teacherLessonsProvider.future),
      child: AsyncValueWidget(
        value: lessons,
        builder: (data) {
          if (data.isEmpty) {
            return const EmptyState(
              title: 'No lessons yet',
              message: 'Tap "New lesson" to create your first lesson.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16, top: 16),
            itemBuilder: (_, index) => _LessonCard(lesson: data[index]),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: data.length,
          );
        },
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson});

  final LessonSummary lesson;

  @override
  Widget build(BuildContext context) {
    final date = lesson.lessonDate != null
        ? DateFormat('MMM d, y').format(lesson.lessonDate!)
        : 'Date TBD';

    return Card(
      child: ListTile(
        title: Text(lesson.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lesson.description != null && lesson.description!.isNotEmpty)
              Text(
                lesson.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Text(
              [
                if (lesson.className != null) lesson.className,
                if (lesson.subjectName != null) lesson.subjectName,
              ].whereType<String>().join(' • '),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 2),
            Text('Lesson date: $date', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

