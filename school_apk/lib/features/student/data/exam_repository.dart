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
    final queryParams = <String, dynamic>{};
    if (subjectId != null) queryParams['subject_id'] = subjectId;
    if (type != null) queryParams['type'] = type;
    if (academicYearId != null) queryParams['academic_year_id'] = academicYearId;
    if (upcomingOnly) queryParams['upcoming_only'] = true;

    final response = await _apiClient.get('student/exams', queryParameters: queryParams);
    // Handle paginated response
    final data = response['data'] is List
        ? (response['data'] as List<dynamic>)
        : (response['data']?['data'] as List<dynamic>? ?? []);
    return data.map((json) => Exam.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Exam> fetchExam(int examId) async {
    final response = await _apiClient.get('student/exams/$examId');
    final data = response['data'] as Map<String, dynamic>;
    return Exam.fromJson(data);
  }
}

