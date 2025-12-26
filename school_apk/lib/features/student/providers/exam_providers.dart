import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/exam_repository.dart';
import '../models/exam_models.dart';

final examRepositoryProvider = Provider<ExamRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return ExamRepository(api);
});

final studentExamsProvider = FutureProvider.autoDispose.family<List<Exam>, Map<String, dynamic>>((ref, filters) async {
  try {
    final repo = ref.watch(examRepositoryProvider);
    final exams = await repo.fetchExams(
      subjectId: filters['subject_id'] as int?,
      type: filters['type'] as String?,
      academicYearId: filters['academic_year_id'] as int?,
      upcomingOnly: filters['upcoming_only'] as bool? ?? false,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException('Request timed out. Please check your connection and try again.');
      },
    );
    return exams;
  } catch (e) {
    // Re-throw with better error message
    throw Exception('Failed to load exams: ${e.toString()}');
  }
});

final studentExamProvider = FutureProvider.autoDispose.family<dynamic, int>((ref, examId) async {
  final repo = ref.watch(examRepositoryProvider);
  return repo.fetchExam(examId);
});

