import '../../../core/network/api_client.dart';
import '../models/exam_models.dart';

class ExamRepository {
  ExamRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Exam>> fetchExams({
    int? subjectId,
    String? type,
    int? academicYearId,
    bool upcomingOnly = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (subjectId != null) queryParams['subject_id'] = subjectId;
      if (type != null) queryParams['type'] = type;
      if (academicYearId != null) queryParams['academic_year_id'] = academicYearId;
      if (upcomingOnly) queryParams['upcoming_only'] = true;

      final response = await _apiClient.get('student/exams', queryParameters: queryParams);
      
      // Handle paginated response - Laravel returns {data: [...], current_page: 1, ...}
      List<dynamic> data;
      if (response is Map<String, dynamic>) {
        if (response['data'] is List) {
          data = response['data'] as List<dynamic>;
        } else if (response['data'] is Map && response['data']?['data'] is List) {
          data = response['data']['data'] as List<dynamic>;
        } else {
          // If no data found, return empty list instead of throwing
          return [];
        }
      } else if (response is List) {
        // Direct list response
        data = response;
      } else {
        // Unexpected response format - return empty list
        return [];
      }

      if (data.isEmpty) {
        return [];
      }

      // Parse exams with error handling
      final exams = <Exam>[];
      for (final item in data) {
        try {
          if (item is Map<String, dynamic>) {
            exams.add(Exam.fromJson(item));
          }
        } catch (e) {
          // Skip invalid exam entries but continue processing others
          continue;
        }
      }

      return exams;
    } catch (e) {
      // Re-throw errors with more context
      throw Exception('Failed to fetch exams: ${e.toString()}');
    }
  }

  Future<Exam> fetchExam(int examId) async {
    final response = await _apiClient.get('student/exams/$examId');
    final data = response['data'] as Map<String, dynamic>;
    return Exam.fromJson(data);
  }
}

