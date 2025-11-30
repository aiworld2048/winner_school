import '../../../core/network/api_client.dart';
import '../../../core/services/session_manager.dart';
import '../models/auth_user.dart';

class AuthRepository {
  AuthRepository(this._apiClient, this._session);

  final ApiClient _apiClient;
  final SessionManager _session;

  Future<AuthUser> login({
    required String phone,
    required String password,
  }) async {
    final response = await _apiClient.post('login', data: {
      'phone': phone,
      'password': password,
    });

    final data = response['data'] as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;
    final user = AuthUser.fromJson(userJson);
    final token = data['token'] as String;

    await _session.saveSession(token: token, profile: userJson);
    return user;
  }

  Future<AuthUser> register({
    required String name,
    required String phone,
    required String password,
    int? classId,
    int? subjectId,
    int? academicYearId,
  }) async {
    final Map<String, dynamic> payload = {
      'name': name,
      'phone': phone,
      'password': password,
      'password_confirmation': password,
    };

    if (classId != null) payload['class_id'] = classId;
    if (subjectId != null) payload['subject_id'] = subjectId;
    if (academicYearId != null) payload['academic_year_id'] = academicYearId;

    final response = await _apiClient.post('register', data: payload);

    final data = response['data'] as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;
    final user = AuthUser.fromJson(userJson);
    final token = data['token'] as String;
    await _session.saveSession(token: token, profile: userJson);
    return user;
  }

  Future<AuthUser?> currentUser() async {
    final token = _session.token;
    if (token == null) return null;

    try {
      final response = await _apiClient.get('user');
      final data = response['data'] as Map<String, dynamic>;
      await _session.updateProfile(data);
      return AuthUser.fromJson(data);
    } catch (_) {
      await _session.clear();
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('logout');
    } catch (_) {
      // ignore
    }
    await _session.clear();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _apiClient.post('update-password', data: {
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': confirmPassword,
    });
  }
}

