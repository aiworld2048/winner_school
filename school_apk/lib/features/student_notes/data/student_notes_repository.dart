import '../../../core/network/api_client.dart';
import '../models/student_note.dart';

class StudentNotesRepository {
  StudentNotesRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<StudentNote>> fetchNotes() async {
    final response = await _apiClient.get('student/notes');
    final data = _parseDataList(response);
    return data.map(StudentNote.fromJson).toList();
  }

  Future<StudentNote> create({
    required String title,
    String? content,
    String? colorHex,
    bool isPinned = false,
    List<String>? tags,
  }) async {
    final payload = {
      'title': title,
      if (content != null) 'content': content,
      if (colorHex != null && colorHex.isNotEmpty) 'color_hex': colorHex,
      'is_pinned': isPinned,
      if (tags != null && tags.isNotEmpty) 'tags': tags,
    };

    final response = await _apiClient.post('student/notes', data: payload);
    return StudentNote.fromJson(_parseDataObject(response));
  }

  Future<StudentNote> update(
    int id, {
    String? title,
    String? content,
    String? colorHex,
    bool? isPinned,
    List<String>? tags,
  }) async {
    final payload = <String, dynamic>{};
    if (title != null) payload['title'] = title;
    if (content != null) payload['content'] = content;
    if (colorHex != null) payload['color_hex'] = colorHex;
    if (isPinned != null) payload['is_pinned'] = isPinned;
    if (tags != null) payload['tags'] = tags;

    final response = await _apiClient.patch('student/notes/$id', data: payload);
    return StudentNote.fromJson(_parseDataObject(response));
  }

  Future<void> delete(int id) async {
    await _apiClient.delete('student/notes/$id');
  }

  List<Map<String, dynamic>> _parseDataList(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }

  Map<String, dynamic> _parseDataObject(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
    }
    throw const FormatException('Unexpected note response.');
  }
}


