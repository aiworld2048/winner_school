class Essay {
  Essay({
    required this.id,
    required this.title,
    this.description,
    this.instructions,
    required this.subject,
    required this.classInfo,
    required this.academicYear,
    required this.teacher,
    required this.dueDate,
    this.dueTime,
    required this.dueDateTime,
    this.wordCountMin,
    this.wordCountMax,
    required this.totalMarks,
    required this.status,
    required this.isOverdue,
    this.attachments,
    this.submissionsCount,
    this.viewsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String? description;
  final String? instructions;
  final EssaySubject subject;
  final EssayClass classInfo;
  final EssayAcademicYear academicYear;
  final EssayTeacher teacher;
  final DateTime dueDate;
  final String? dueTime;
  final DateTime dueDateTime;
  final int? wordCountMin;
  final int? wordCountMax;
  final double totalMarks;
  final String status;
  final bool isOverdue;
  final List<EssayAttachment>? attachments;
  final int? submissionsCount;
  final int? viewsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Essay.fromJson(Map<String, dynamic> json) {
    return Essay(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      instructions: json['instructions']?.toString(),
      subject: EssaySubject.fromJson(json['subject'] as Map<String, dynamic>),
      classInfo: EssayClass.fromJson(json['class'] as Map<String, dynamic>),
      academicYear: EssayAcademicYear.fromJson(json['academic_year'] as Map<String, dynamic>),
      teacher: EssayTeacher.fromJson(json['teacher'] as Map<String, dynamic>),
      dueDate: DateTime.parse(json['due_date'] as String),
      dueTime: json['due_time']?.toString(),
      dueDateTime: DateTime.parse(json['due_date_time'] as String),
      wordCountMin: json['word_count_min'] as int?,
      wordCountMax: json['word_count_max'] as int?,
      totalMarks: (json['total_marks'] as num).toDouble(),
      status: json['status']?.toString() ?? 'draft',
      isOverdue: json['is_overdue'] as bool? ?? false,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List<dynamic>)
              .map((a) => EssayAttachment.fromJson(a as Map<String, dynamic>))
              .toList()
          : null,
      submissionsCount: json['submissions_count'] as int?,
      viewsCount: json['views_count'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructions': instructions,
      'subject': subject.toJson(),
      'class': classInfo.toJson(),
      'academic_year': academicYear.toJson(),
      'teacher': teacher.toJson(),
      'due_date': dueDate.toIso8601String(),
      'due_time': dueTime,
      'due_date_time': dueDateTime.toIso8601String(),
      'word_count_min': wordCountMin,
      'word_count_max': wordCountMax,
      'total_marks': totalMarks,
      'status': status,
      'is_overdue': isOverdue,
      'attachments': attachments?.map((a) => a.toJson()).toList(),
      'submissions_count': submissionsCount,
      'views_count': viewsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get wordCountDisplay {
    if (wordCountMin != null && wordCountMax != null) {
      return '$wordCountMin - $wordCountMax words';
    } else if (wordCountMin != null) {
      return 'Min: $wordCountMin words';
    } else if (wordCountMax != null) {
      return 'Max: $wordCountMax words';
    }
    return 'No limit';
  }

  String get statusDisplay {
    switch (status) {
      case 'published':
        return 'Published';
      case 'draft':
        return 'Draft';
      case 'archived':
        return 'Archived';
      default:
        return status.toUpperCase();
    }
  }
}

class EssaySubject {
  EssaySubject({
    required this.id,
    required this.name,
    required this.code,
  });

  final int id;
  final String name;
  final String code;

  factory EssaySubject.fromJson(Map<String, dynamic> json) {
    return EssaySubject(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }
}

class EssayClass {
  EssayClass({
    required this.id,
    required this.name,
    required this.code,
  });

  final int id;
  final String name;
  final String code;

  factory EssayClass.fromJson(Map<String, dynamic> json) {
    return EssayClass(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }
}

class EssayAcademicYear {
  EssayAcademicYear({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory EssayAcademicYear.fromJson(Map<String, dynamic> json) {
    return EssayAcademicYear(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class EssayTeacher {
  EssayTeacher({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory EssayTeacher.fromJson(Map<String, dynamic> json) {
    return EssayTeacher(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class EssayAttachment {
  EssayAttachment({
    required this.name,
    required this.url,
  });

  final String name;
  final String url;

  factory EssayAttachment.fromJson(Map<String, dynamic> json) {
    return EssayAttachment(
      name: json['name']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
    };
  }
}

