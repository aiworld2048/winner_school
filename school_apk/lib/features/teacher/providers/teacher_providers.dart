import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../student/models/lesson_models.dart';
import '../data/exam_repository.dart';
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

// Teacher Exam Providers
final teacherExamRepositoryProvider = Provider<TeacherExamRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return TeacherExamRepository(api);
});

final teacherExamsProvider = FutureProvider.autoDispose.family<List<dynamic>, Map<String, dynamic>>((ref, filters) async {
  final repo = ref.watch(teacherExamRepositoryProvider);
  final exams = await repo.fetchExams(
    subjectId: filters['subject_id'] as int?,
    classId: filters['class_id'] as int?,
    type: filters['type'] as String?,
    isPublished: filters['is_published'] as bool?,
  );
  return exams;
});

final teacherExamProvider = FutureProvider.autoDispose.family<dynamic, int>((ref, examId) async {
  final repo = ref.watch(teacherExamRepositoryProvider);
  return repo.fetchExam(examId);
});

