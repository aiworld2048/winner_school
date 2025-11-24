import '../../../core/network/api_client.dart';
import '../../student/models/lesson_models.dart';
import '../models/teacher_models.dart';

class TeacherRepository {
  TeacherRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<TeacherDashboardData> fetchDashboard() async {
    final response = await _apiClient.get('teacher/dashboard');
    final data = response['data'] as Map<String, dynamic>? ?? response as Map<String, dynamic>;
    return TeacherDashboardData.fromJson(data);
  }

  Future<List<TeacherStudent>> fetchStudents() async {
    final response = await _apiClient.get('teacher/students');
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((item) => TeacherStudent.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> createStudent({
    required String name,
    required String phone,
    required String password,
    required int classId,
  }) async {
    await _apiClient.post('teacher/students', data: {
      'name': name,
      'phone': phone,
      'password': password,
      'password_confirmation': password,
      'class_id': classId,
    });
  }

  Future<List<LessonSummary>> fetchLessons() async {
    final response = await _apiClient.get('teacher/lessons');
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((item) => LessonSummary.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> createLesson({
    required String title,
    required String description,
    required String content,
    required int classId,
    required int subjectId,
    required DateTime lessonDate,
    required int durationMinutes,
  }) async {
    await _apiClient.post('teacher/lessons', data: {
      'title': title,
      'description': description,
      'content': content,
      'class_id': classId,
      'subject_id': subjectId,
      'lesson_date': lessonDate.toIso8601String(),
      'duration_minutes': durationMinutes,
    });
  }

  Future<List<TeacherClassInfo>> fetchClasses() async {
    final response = await _apiClient.get('teacher/classes');
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((e) => TeacherClassInfo.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TeacherSubjectInfo>> fetchSubjects() async {
    final response = await _apiClient.get('teacher/subjects');
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((e) => TeacherSubjectInfo.fromJson(e as Map<String, dynamic>)).toList();
  }
}

