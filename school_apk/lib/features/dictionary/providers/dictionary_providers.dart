import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/dictionary_repository.dart';
import '../models/dictionary_entry.dart';

final dictionaryRepositoryProvider = Provider<DictionaryRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return DictionaryRepository(api);
});

final dictionarySearchQueryProvider = StateProvider<String>((ref) => '');

final dictionaryEntriesProvider =
    FutureProvider.autoDispose<List<DictionaryEntry>>((ref) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  final query = ref.watch(dictionarySearchQueryProvider);
  return repo.fetchEntries(query: query);
});

