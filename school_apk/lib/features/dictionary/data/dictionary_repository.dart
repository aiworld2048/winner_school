import '../../../core/network/api_client.dart';
import '../models/dictionary_entry.dart';

class DictionaryRepository {
  DictionaryRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<DictionaryEntry>> fetchEntries({String? query}) async {
    final response = await _apiClient.get(
      'dictionary',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        'per_page': 200,
      },
    );

    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((item) => DictionaryEntry.fromJson(item as Map<String, dynamic>)).toList();
  }
}

