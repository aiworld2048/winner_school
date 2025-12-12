import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/video_lesson_repository.dart';
import '../models/video_lesson_models.dart';

final videoLessonRepositoryProvider = Provider<VideoLessonRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return VideoLessonRepository(api);
});

final studentVideoLessonsProvider = FutureProvider.autoDispose.family<List<VideoLesson>, Map<String, dynamic>>((ref, filters) async {
  try {
    final repo = ref.watch(videoLessonRepositoryProvider);
    final videoLessons = await repo.fetchVideoLessons(
      subjectId: filters['subject_id'] as int?,
      classId: filters['class_id'] as int?,
      academicYearId: filters['academic_year_id'] as int?,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException('Request timed out. Please check your connection and try again.');
      },
    );
    return videoLessons;
  } catch (e) {
    throw Exception('Failed to load video lessons: ${e.toString()}');
  }
});

final studentVideoLessonDetailProvider = FutureProvider.autoDispose.family<VideoLesson, int>((ref, videoLessonId) async {
  try {
    final repo = ref.watch(videoLessonRepositoryProvider);
    return await repo.fetchVideoLessonDetail(videoLessonId).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException('Request timed out. Please check your connection and try again.');
      },
    );
  } catch (e) {
    throw Exception('Failed to load video lesson: ${e.toString()}');
  }
});

