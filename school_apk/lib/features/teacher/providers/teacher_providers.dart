import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../student/models/lesson_models.dart';
import '../data/teacher_repository.dart';
import '../models/teacher_models.dart';

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return TeacherRepository(api);
});

final teacherDashboardProvider = FutureProvider.autoDispose<TeacherDashboardData>((ref) async {
  final repo = ref.watch(teacherRepositoryProvider);
  return repo.fetchDashboard();
});

final teacherStudentsProvider = FutureProvider.autoDispose<List<TeacherStudent>>((ref) async {
  final repo = ref.watch(teacherRepositoryProvider);
  return repo.fetchStudents();
});

final teacherLessonsProvider = FutureProvider.autoDispose<List<LessonSummary>>((ref) async {
  final repo = ref.watch(teacherRepositoryProvider);
  return repo.fetchLessons();
});

final teacherClassesProvider = FutureProvider.autoDispose<List<TeacherClassInfo>>((ref) async {
  final repo = ref.watch(teacherRepositoryProvider);
  return repo.fetchClasses();
});

final teacherSubjectsProvider = FutureProvider.autoDispose<List<TeacherSubjectInfo>>((ref) async {
  final repo = ref.watch(teacherRepositoryProvider);
  return repo.fetchSubjects();
});

