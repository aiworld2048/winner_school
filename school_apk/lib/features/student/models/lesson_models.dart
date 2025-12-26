class LessonSummary {
  LessonSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectName,
    required this.className,
    required this.lessonDate,
  });

  final int id;
  final String title;
  final String? description;
  final String? subjectName;
  final String? className;
  final DateTime? lessonDate;

  factory LessonSummary.fromJson(Map<String, dynamic> json) {
    return LessonSummary(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      subjectName: json['subject']?['name'] as String? ?? json['subject_name'] as String?,
      className: json['class']?['name'] as String? ?? json['class_name'] as String?,
      lessonDate: json['lesson_date'] != null ? DateTime.tryParse(json['lesson_date'] as String) : null,
    );
  }
}

class LessonDetail extends LessonSummary {
  LessonDetail({
    required super.id,
    required super.title,
    required super.description,
    required super.subjectName,
    required super.className,
    required super.lessonDate,
    required this.content,
    required this.durationMinutes,
    this.pdfFileUrl,
  });

  final String? content;
  final int? durationMinutes;
  final String? pdfFileUrl;

  factory LessonDetail.fromJson(Map<String, dynamic> json) {
    return LessonDetail(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      subjectName: json['subject']?['name'] as String? ?? json['subject_name'] as String?,
      className: json['class']?['name'] as String? ?? json['class_name'] as String?,
      lessonDate: json['lesson_date'] != null ? DateTime.tryParse(json['lesson_date'] as String) : null,
      content: json['content'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      pdfFileUrl: json['pdf_file_url'] as String?,
    );
  }
}

