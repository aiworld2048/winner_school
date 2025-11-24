import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/async_value_widget.dart';
import '../../../../common/widgets/empty_state.dart';
import '../../providers/teacher_providers.dart';

class TeacherStudentsScreen extends ConsumerWidget {
  const TeacherStudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(teacherStudentsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(teacherStudentsProvider.future),
      child: AsyncValueWidget(
        value: students,
        builder: (data) {
          if (data.isEmpty) {
            return const EmptyState(
              title: 'No students yet',
              message: 'Use the "+" button to add your students.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (_, index) {
              final student = data[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                    ),
                  ),
                  title: Text(student.name),
                  subtitle: Text(
                    [
                      student.className ?? 'Unassigned',
                      student.userName,
                    ].whereType<String>().join(' • '),
                  ),
                  trailing: Text(student.phone),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: data.length,
          );
        },
      ),
    );
  }
}

