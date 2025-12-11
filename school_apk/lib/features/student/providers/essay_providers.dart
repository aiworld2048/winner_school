import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/essay_repository.dart';
import '../models/essay_models.dart';

final studentEssayRepositoryProvider = Provider<StudentEssayRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return StudentEssayRepository(api);
});

final studentEssaysProvider = FutureProvider.autoDispose<List<Essay>>((ref) async {
  final repo = ref.watch(studentEssayRepositoryProvider);
  return repo.fetchEssays();
});

final studentEssayDetailProvider = FutureProvider.autoDispose.family<Essay, int>((ref, essayId) async {
  final repo = ref.watch(studentEssayRepositoryProvider);
  return repo.fetchEssayDetail(essayId);
});

