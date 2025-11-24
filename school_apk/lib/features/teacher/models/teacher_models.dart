class TeacherDashboardData {
  TeacherDashboardData({
    required this.studentCount,
    required this.lessonCount,
    required this.classCount,
    required this.subjectCount,
  });

  final int studentCount;
  final int lessonCount;
  final int classCount;
  final int subjectCount;

  factory TeacherDashboardData.fromJson(Map<String, dynamic> json) {
    return TeacherDashboardData(
      studentCount: json['students'] as int? ?? 0,
      lessonCount: json['lessons'] as int? ?? 0,
      classCount: json['classes'] as int? ?? 0,
      subjectCount: json['subjects'] as int? ?? 0,
    );
  }
}

class TeacherStudent {
  TeacherStudent({
    required this.id,
    required this.name,
    required this.userName,
    required this.phone,
    required this.className,
  });

  final int id;
  final String name;
  final String? userName;
  final String phone;
  final String? className;

  factory TeacherStudent.fromJson(Map<String, dynamic> json) {
    return TeacherStudent(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      userName: json['user_name']?.toString(),
      phone: json['phone']?.toString() ?? '',
      className: json['class']?['name']?.toString() ?? json['class_name']?.toString(),
    );
  }
}

class TeacherClassInfo {
  TeacherClassInfo({required this.id, required this.name});

  final int id;
  final String name;

  factory TeacherClassInfo.fromJson(Map<String, dynamic> json) {
    return TeacherClassInfo(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
    );
  }
}

class TeacherSubjectInfo {
  TeacherSubjectInfo({required this.id, required this.name});

  final int id;
  final String name;

  factory TeacherSubjectInfo.fromJson(Map<String, dynamic> json) {
    return TeacherSubjectInfo(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
    );
  }
}

