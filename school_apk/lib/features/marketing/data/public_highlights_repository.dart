import '../../../core/network/api_client.dart';
import '../models/public_highlights.dart';

class PublicHighlightsRepository {
  PublicHighlightsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<PublicHighlights> fetchHighlights() async {
    final response = await _apiClient.get('public/highlights');
    final payload = response['data'] as Map<String, dynamic>? ?? response as Map<String, dynamic>;
    return PublicHighlights.fromJson(payload);
  }
}

