import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/exam_repository.dart';

final examRepositoryProvider = Provider<ExamRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return ExamRepository(api);
});

final studentExamsProvider = FutureProvider.autoDispose.family<List<dynamic>, Map<String, dynamic>>((ref, filters) async {
  final repo = ref.watch(examRepositoryProvider);
  final exams = await repo.fetchExams(
    subjectId: filters['subject_id'] as int?,
    type: filters['type'] as String?,
    academicYearId: filters['academic_year_id'] as int?,
    upcomingOnly: filters['upcoming_only'] as bool? ?? false,
  );
  return exams;
});

final studentExamProvider = FutureProvider.autoDispose.family<dynamic, int>((ref, examId) async {
  final repo = ref.watch(examRepositoryProvider);
  return repo.fetchExam(examId);
});

