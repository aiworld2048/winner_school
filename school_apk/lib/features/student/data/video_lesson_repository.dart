import '../../../core/network/api_client.dart';
import '../models/video_lesson_models.dart';

class VideoLessonRepository {
  VideoLessonRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<VideoLesson>> fetchVideoLessons({
    int? subjectId,
    int? classId,
    int? academicYearId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (subjectId != null) queryParams['subject_id'] = subjectId;
      if (classId != null) queryParams['class_id'] = classId;
      if (academicYearId != null) queryParams['academic_year_id'] = academicYearId;

      final response = await _apiClient.get('student/video-lessons', queryParameters: queryParams);
      
      // Handle paginated response
      List<dynamic> data;
      if (response is Map<String, dynamic>) {
        if (response['data'] is List) {
          data = response['data'] as List<dynamic>;
        } else if (response['data'] is Map && response['data']?['data'] is List) {
          data = response['data']['data'] as List<dynamic>;
        } else {
          return [];
        }
      } else if (response is List) {
        data = response;
      } else {
        return [];
      }

      if (data.isEmpty) {
        return [];
      }

      final videoLessons = <VideoLesson>[];
      for (final item in data) {
        try {
          if (item is Map<String, dynamic>) {
            videoLessons.add(VideoLesson.fromJson(item));
          }
        } catch (e) {
          continue;
        }
      }

      return videoLessons;
    } catch (e) {
      // Re-throw with more context - ApiException will have the proper message
      rethrow;
    }
  }

  Future<VideoLesson> fetchVideoLessonDetail(int videoLessonId) async {
    try {
      final response = await _apiClient.get('student/video-lessons/$videoLessonId');
      final data = response['data'] as Map<String, dynamic>;
      return VideoLesson.fromJson(data);
    } catch (e) {
      // Re-throw to preserve ApiException with proper message
      rethrow;
    }
  }
}

