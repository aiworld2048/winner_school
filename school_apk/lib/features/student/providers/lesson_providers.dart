import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/lesson_repository.dart';
import '../models/lesson_models.dart';

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return LessonRepository(api);
});

final lessonsProvider = FutureProvider.autoDispose<List<LessonSummary>>((ref) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.fetchLessons();
});

final lessonDetailProvider = FutureProvider.autoDispose.family<LessonDetail, int>((ref, id) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.fetchLessonDetail(id);
});

