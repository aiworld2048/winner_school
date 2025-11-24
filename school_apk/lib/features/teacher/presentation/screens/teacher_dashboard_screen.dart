import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/async_value_widget.dart';
import '../../../student/models/lesson_models.dart';
import '../../providers/teacher_providers.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(teacherDashboardProvider);
    final lessons = ref.watch(teacherLessonsProvider);
    final students = ref.watch(teacherStudentsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AsyncValueWidget(
          value: dashboard,
          builder: (data) => Row(
            children: [
              Expanded(child: _StatCard(label: 'Students', value: data.studentCount)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Lessons', value: data.lessonCount)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AsyncValueWidget(
          value: dashboard,
          builder: (data) => Row(
            children: [
              Expanded(child: _StatCard(label: 'Classes', value: data.classCount)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Subjects', value: data.subjectCount)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Recent lessons', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        AsyncValueWidget(
          value: lessons,
          builder: (items) => items.isEmpty
              ? const _PlaceholderText('No lessons created yet')
              : Column(
                  children: items.take(3).map((lesson) => _LessonTile(lesson: lesson)).toList(),
                ),
        ),
        const SizedBox(height: 24),
        Text('Recent students', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        AsyncValueWidget(
          value: students,
          builder: (items) => items.isEmpty
              ? const _PlaceholderText('No students added yet')
              : Column(
                  children: items
                      .take(4)
                      .map(
                        (student) => ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(student.name),
                          subtitle: Text(student.className ?? 'Unassigned'),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson});

  final LessonSummary lesson;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(lesson.title),
        subtitle: Text(
          [
            if (lesson.className != null) lesson.className,
            if (lesson.subjectName != null) lesson.subjectName,
          ].whereType<String>().join(' • '),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _PlaceholderText extends StatelessWidget {
  const _PlaceholderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text, style: TextStyle(color: Colors.grey.shade600)),
      ),
    );
  }
}

