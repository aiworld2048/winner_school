import '../../../core/network/api_client.dart';
import '../models/lesson_models.dart';

class LessonRepository {
  LessonRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<LessonSummary>> fetchLessons({int page = 1}) async {
    final response = await _apiClient.get('student/lessons', queryParameters: {'page': page});
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((json) => LessonSummary.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<LessonDetail> fetchLessonDetail(int id) async {
    final response = await _apiClient.get('student/lessons/$id');
    final data = response['data'] as Map<String, dynamic>;
    return LessonDetail.fromJson(data);
  }
}

