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
      final errors = <String>[];
      
      for (final item in data) {
        try {
          if (item is Map<String, dynamic>) {
            exams.add(Exam.fromJson(item));
          } else {
            errors.add('Invalid exam item type: ${item.runtimeType}');
          }
        } catch (e) {
          // Log error but continue processing others
          errors.add('Failed to parse exam: ${e.toString()}');
          // Only throw if all items fail
          if (exams.isEmpty && errors.length == data.length) {
            throw Exception('Failed to parse any exams. Errors: ${errors.join('; ')}');
          }
        }
      }

      // If we have some exams, return them even if some failed
      if (exams.isNotEmpty) {
        return exams;
      }

      // If no exams parsed but we had data, throw error
      if (data.isNotEmpty && errors.isNotEmpty) {
        throw Exception('Failed to parse exams. Errors: ${errors.join('; ')}');
      }

      return exams;
    } catch (e) {
      // Re-throw errors with more context
      throw Exception('Failed to fetch exams: ${e.toString()}');
    }
  }

  Future<Exam> fetchExam(int examId) async {
    try {
      final response = await _apiClient.get('student/exams/$examId');
      
      // Handle different response structures
      Map<String, dynamic> data;
      if (response is Map<String, dynamic>) {
        if (response['data'] is Map<String, dynamic>) {
          data = response['data'] as Map<String, dynamic>;
        } else {
          // Direct response
          data = response;
        }
      } else {
        throw Exception('Unexpected response format: ${response.runtimeType}');
      }
      
      return Exam.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch exam: ${e.toString()}');
    }
  }
}

