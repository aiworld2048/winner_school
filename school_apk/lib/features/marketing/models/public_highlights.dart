class PublicHighlights {
  const PublicHighlights({
    required this.stats,
    required this.courses,
    required this.lessons,
    required this.classes,
    required this.academicYears,
  });

  final PublicStats stats;
  final List<PublicCourse> courses;
  final List<PublicLesson> lessons;
  final List<PublicClass> classes;
  final List<PublicAcademicYear> academicYears;

  factory PublicHighlights.fromJson(Map<String, dynamic> json) {
    return PublicHighlights(
      stats: PublicStats.fromJson(json['stats'] as Map<String, dynamic>? ?? const {}),
      courses: (json['courses'] as List<dynamic>? ?? [])
          .map((item) => PublicCourse.fromJson(item as Map<String, dynamic>))
          .toList(),
      lessons: (json['lessons'] as List<dynamic>? ?? [])
          .map((item) => PublicLesson.fromJson(item as Map<String, dynamic>))
          .toList(),
      classes: (json['classes'] as List<dynamic>? ?? [])
          .map((item) => PublicClass.fromJson(item as Map<String, dynamic>))
          .toList(),
      academicYears: (json['academic_years'] as List<dynamic>? ?? [])
          .map((item) => PublicAcademicYear.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PublicStats {
  const PublicStats({
    required this.students,
    required this.teachers,
    required this.lessons,
    required this.classes,
  });

  final int students;
  final int teachers;
  final int lessons;
  final int classes;

  factory PublicStats.fromJson(Map<String, dynamic> json) {
    return PublicStats(
      students: _readInt(json['students']),
      teachers: _readInt(json['teachers']),
      lessons: _readInt(json['lessons']),
      classes: _readInt(json['classes']),
    );
  }
}

class PublicCourse {
  const PublicCourse({required this.id, required this.title, this.description});

  final int id;
  final String title;
  final String? description;

  factory PublicCourse.fromJson(Map<String, dynamic> json) {
    return PublicCourse(
      id: _readInt(json['id']),
      title: json['title']?.toString() ?? 'Course',
      description: json['description']?.toString(),
    );
  }
}

class PublicLesson {
  const PublicLesson({
    required this.id,
    required this.title,
    this.subjectName,
    this.className,
    this.lessonDate,
  });

  final int id;
  final String title;
  final String? subjectName;
  final String? className;
  final String? lessonDate;

  factory PublicLesson.fromJson(Map<String, dynamic> json) {
    return PublicLesson(
      id: _readInt(json['id']),
      title: json['title']?.toString() ?? '',
      subjectName: json['subject_name']?.toString(),
      className: json['class_name']?.toString(),
      lessonDate: json['lesson_date']?.toString(),
    );
  }
}

class PublicClass {
  const PublicClass({
    required this.id,
    required this.name,
    this.gradeLevel,
    this.section,
  });

  final int id;
  final String name;
  final int? gradeLevel;
  final String? section;

  factory PublicClass.fromJson(Map<String, dynamic> json) {
    return PublicClass(
      id: _readInt(json['id']),
      name: json['name']?.toString() ?? '',
      gradeLevel: json['grade_level'] is int ? json['grade_level'] as int : int.tryParse('${json['grade_level']}'),
      section: json['section']?.toString(),
    );
  }
}

class PublicAcademicYear {
  const PublicAcademicYear({
    required this.id,
    required this.name,
    this.code,
    this.startDate,
    this.endDate,
  });

  final int id;
  final String name;
  final String? code;
  final String? startDate;
  final String? endDate;

  factory PublicAcademicYear.fromJson(Map<String, dynamic> json) {
    return PublicAcademicYear(
      id: _readInt(json['id']),
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
    );
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

