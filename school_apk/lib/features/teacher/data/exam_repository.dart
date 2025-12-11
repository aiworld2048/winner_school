import '../../../core/network/api_client.dart';
import '../../student/models/exam_models.dart';

class TeacherExamRepository {
  TeacherExamRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Exam>> fetchExams({
    int? subjectId,
    int? classId,
    String? type,
    bool? isPublished,
  }) async {
    final queryParams = <String, dynamic>{};
    if (subjectId != null) queryParams['subject_id'] = subjectId;
    if (classId != null) queryParams['class_id'] = classId;
    if (type != null) queryParams['type'] = type;
    if (isPublished != null) queryParams['is_published'] = isPublished ? 1 : 0;

    final response = await _apiClient.get('teacher/exams', queryParameters: queryParams);
    // Handle paginated response
    final data = response['data'] is List
        ? (response['data'] as List<dynamic>)
        : (response['data']?['data'] as List<dynamic>? ?? []);
    return data.map((json) => Exam.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Exam> fetchExam(int examId) async {
    final response = await _apiClient.get('teacher/exams/$examId');
    final data = response['data'] as Map<String, dynamic>;
    return Exam.fromJson(data);
  }

  Future<Exam> createExam(Map<String, dynamic> data) async {
    final response = await _apiClient.post('teacher/exams', data: data);
    final examData = response['data'] as Map<String, dynamic>;
    return Exam.fromJson(examData);
  }

  Future<Exam> updateExam(int examId, Map<String, dynamic> data) async {
    final response = await _apiClient.put('teacher/exams/$examId', data: data);
    final examData = response['data'] as Map<String, dynamic>;
    return Exam.fromJson(examData);
  }

  Future<void> deleteExam(int examId) async {
    await _apiClient.delete('teacher/exams/$examId');
  }
}

