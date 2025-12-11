import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dictionary/presentation/dictionary_screen.dart';
import '../../media/presentation/media_hub_screen.dart';
import '../../shared/widgets/app_navbar.dart';
import '../providers/teacher_providers.dart';
import 'screens/teacher_dashboard_screen.dart';
import 'screens/teacher_exams_screen.dart';
import 'screens/teacher_lessons_screen.dart';
import 'screens/teacher_profile_screen.dart';
import 'screens/teacher_students_screen.dart';
import 'widgets/teacher_lesson_form_sheet.dart';
import 'widgets/teacher_student_form_sheet.dart';

class TeacherShell extends ConsumerStatefulWidget {
  const TeacherShell({super.key});

  @override
  ConsumerState<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends ConsumerState<TeacherShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final titles = ['Dashboard', 'Lessons', 'Students', 'Profile'];
    final pages = <Widget>[
      const TeacherDashboardScreen(),
      const TeacherLessonsScreen(),
      const TeacherStudentsScreen(),
      const TeacherProfileScreen(),
    ];

    return Scaffold(
      appBar: AppNavbar(
        title: titles[_index],
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MediaHubScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Exams',
            icon: const Icon(Icons.quiz_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TeacherExamsScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Dictionary',
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DictionaryScreen()),
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: pages[_index],
      ),
      floatingActionButton: _buildFab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Lessons'),
          NavigationDestination(icon: Icon(Icons.group_outlined), label: 'Students'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        onDestinationSelected: (value) => setState(() => _index = value),
      ),
    );
  }

  Widget? _buildFab() {
    switch (_index) {
      case 1:
        return FloatingActionButton.extended(
          onPressed: _openCreateLesson,
          icon: const Icon(Icons.add),
          label: const Text('New lesson'),
        );
      case 2:
        return FloatingActionButton.extended(
          onPressed: _openCreateStudent,
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('New student'),
        );
      default:
        return null;
    }
  }

  Future<void> _openCreateLesson() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const TeacherLessonFormSheet(),
    );
    if (created == true) {
      ref.invalidate(teacherLessonsProvider);
    }
  }

  Future<void> _openCreateStudent() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const TeacherStudentFormSheet(),
    );
    if (created == true) {
      ref.invalidate(teacherStudentsProvider);
    }
  }
}

