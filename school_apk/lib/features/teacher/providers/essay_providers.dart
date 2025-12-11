import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/essay_repository.dart';
import '../models/essay_models.dart';

final essayRepositoryProvider = Provider<EssayRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return EssayRepository(api);
});

final teacherEssaysProvider = FutureProvider.autoDispose.family<List<Essay>, Map<String, dynamic>>((ref, filters) async {
  final repo = ref.watch(essayRepositoryProvider);
  final essays = await repo.fetchEssays(
    subjectId: filters['subject_id'] as int?,
    classId: filters['class_id'] as int?,
    status: filters['status'] as String?,
    academicYearId: filters['academic_year_id'] as int?,
  );
  return essays;
});

final teacherEssayProvider = FutureProvider.autoDispose.family<Essay, int>((ref, essayId) async {
  final repo = ref.watch(essayRepositoryProvider);
  return repo.fetchEssay(essayId);
});

