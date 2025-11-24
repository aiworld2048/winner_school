import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../common/widgets/async_value_widget.dart';
import '../../providers/lesson_providers.dart';

class StudentLessonDetailScreen extends ConsumerWidget {
  const StudentLessonDetailScreen({super.key, required this.lessonId});

  final int lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = ref.watch(lessonDetailProvider(lessonId));

    return Scaffold(
      appBar: AppBar(title: const Text('Lesson detail')),
      body: AsyncValueWidget(
        value: lesson,
        builder: (data) {
          final date = data.lessonDate != null
              ? DateFormat('MMM d, y').format(data.lessonDate!)
              : null;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                data.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                [
                  if (data.subjectName != null) data.subjectName,
                  if (data.className != null) data.className,
                ].whereType<String>().join(' • '),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              if (date != null) ...[
                const SizedBox(height: 4),
                Text('Lesson date: $date', style: Theme.of(context).textTheme.bodySmall),
              ],
              if (data.durationMinutes != null) ...[
                const SizedBox(height: 4),
                Text('Duration: ${data.durationMinutes} m',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
              const SizedBox(height: 16),
              if (data.description != null && data.description!.isNotEmpty) ...[
                Text(
                  data.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
              ],
              if (data.content != null && data.content!.isNotEmpty)
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Html(data: data.content),
                  ),
                )
              else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No detailed content provided.'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

