import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/async_value_widget.dart';
import '../../../../common/widgets/empty_state.dart';
import '../../providers/lesson_providers.dart';
import 'student_lesson_detail_screen.dart';

class StudentLessonsScreen extends ConsumerWidget {
  const StudentLessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = ref.watch(lessonsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(lessonsProvider.future),
      child: AsyncValueWidget(
        value: lessons,
        builder: (data) {
          if (data.isEmpty) {
            return const EmptyState(
              title: 'No lessons yet',
              message: 'Your teacher has not assigned lessons. Check back soon.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final lesson = data[index];
              final subtitle = [
                if (lesson.subjectName != null) lesson.subjectName,
                if (lesson.className != null) lesson.className,
              ].whereType<String>().join(' • ');
              final date = lesson.lessonDate != null
                  ? DateFormat('MMM d, y').format(lesson.lessonDate!)
                  : null;

              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(lesson.title, style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (lesson.description != null && lesson.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            lesson.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (subtitle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                        ),
                      if (date != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('Lesson date: $date',
                              style: Theme.of(context).textTheme.bodySmall),
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StudentLessonDetailScreen(lessonId: lesson.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

