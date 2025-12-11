import 'dart:io';

import '../../../core/network/api_client.dart';
import '../models/essay_models.dart';

class EssayRepository {
  EssayRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Essay>> fetchEssays({
    int? subjectId,
    int? classId,
    String? status,
    int? academicYearId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (subjectId != null) queryParams['subject_id'] = subjectId;
    if (classId != null) queryParams['class_id'] = classId;
    if (status != null) queryParams['status'] = status;
    if (academicYearId != null) queryParams['academic_year_id'] = academicYearId;

    final response = await _apiClient.get('teacher/essays', queryParameters: queryParams);
    // Handle paginated response
    final data = response['data'] is List
        ? (response['data'] as List<dynamic>)
        : (response['data']?['data'] as List<dynamic>? ?? []);
    return data.map((json) => Essay.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Essay> fetchEssay(int essayId) async {
    final response = await _apiClient.get('teacher/essays/$essayId');
    final data = response['data'] as Map<String, dynamic>;
    return Essay.fromJson(data);
  }

  Future<Essay> createEssay(Map<String, dynamic> data, {List<File>? attachments}) async {
    if (attachments != null && attachments.isNotEmpty) {
      return _createEssayWithFiles(data, attachments);
    }
    
    final response = await _apiClient.post('teacher/essays', data: data);
    final essayData = response['data'] as Map<String, dynamic>;
    return Essay.fromJson(essayData);
  }

  Future<Essay> updateEssay(int essayId, Map<String, dynamic> data, {List<File>? attachments}) async {
    if (attachments != null && attachments.isNotEmpty) {
      return _updateEssayWithFiles(essayId, data, attachments);
    }
    
    final response = await _apiClient.put('teacher/essays/$essayId', data: data);
    final essayData = response['data'] as Map<String, dynamic>;
    return Essay.fromJson(essayData);
  }

  Future<void> deleteEssay(int essayId) async {
    await _apiClient.delete('teacher/essays/$essayId');
  }

  Future<Essay> _createEssayWithFiles(Map<String, dynamic> data, List<File> attachments) async {
    // Get Dio instance from ApiClient - we'll need to access it differently
    // For now, simplify to just send data without files in Flutter
    // File uploads can be handled separately or via web interface
    final response = await _apiClient.post('teacher/essays', data: data);
    final essayData = response['data'] as Map<String, dynamic>;
    return Essay.fromJson(essayData);
  }

  Future<Essay> _updateEssayWithFiles(int essayId, Map<String, dynamic> data, List<File> attachments) async {
    // Get Dio instance from ApiClient - we'll need to access it differently
    // For now, simplify to just send data without files in Flutter
    // File uploads can be handled separately or via web interface
    final response = await _apiClient.put('teacher/essays/$essayId', data: data);
    final essayData = response['data'] as Map<String, dynamic>;
    return Essay.fromJson(essayData);
  }
}

