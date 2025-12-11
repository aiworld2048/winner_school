import '../../../core/network/api_client.dart';
import '../models/essay_models.dart';

class StudentEssayRepository {
  StudentEssayRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Essay>> fetchEssays({int page = 1}) async {
    final response = await _apiClient.get('student/essays', queryParameters: {'page': page});
    // Handle paginated response
    final data = response['data'] is List
        ? (response['data'] as List<dynamic>)
        : (response['data']?['data'] as List<dynamic>? ?? []);
    return data.map((json) => Essay.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Essay> fetchEssayDetail(int id) async {
    final response = await _apiClient.get('student/essays/$id');
    final data = response['data'] as Map<String, dynamic>;
    return Essay.fromJson(data);
  }
}

