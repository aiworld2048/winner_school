class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.balance,
  });

  final int id;
  final String name;
  final String phone;
  final UserRole role;
  final double balance;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name'] as String
          : (json['user_name'] as String? ?? ''),
      phone: json['phone']?.toString() ?? '',
      role: parseUserRole(json['type']),
      balance: _parseBalance(json['balance']),
    );
  }
}

enum UserRole { headTeacher, teacher, student, wallet, unknown }

UserRole parseUserRole(dynamic value) {
  switch (value) {
    case 10:
      return UserRole.headTeacher;
    case 15:
      return UserRole.teacher;
    case 20:
      return UserRole.student;
    case 30:
      return UserRole.wallet;
    default:
      return UserRole.unknown;
  }
}

double _parseBalance(dynamic raw) {
  if (raw is num) return raw.toDouble();
  if (raw is String) return double.tryParse(raw) ?? 0;
  return 0;
}

