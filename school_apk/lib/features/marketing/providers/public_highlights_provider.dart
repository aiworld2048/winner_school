import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/public_highlights_repository.dart';
import '../models/public_highlights.dart';

final publicHighlightsRepositoryProvider = Provider<PublicHighlightsRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return PublicHighlightsRepository(api);
});

final publicHighlightsProvider = FutureProvider.autoDispose<PublicHighlights>((ref) async {
  final repo = ref.watch(publicHighlightsRepositoryProvider);
  return repo.fetchHighlights();
});

