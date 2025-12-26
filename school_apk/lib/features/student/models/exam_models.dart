class Exam {
  Exam({
    required this.id,
    required this.title,
    required this.code,
    this.description,
    this.pdfFileUrl,
    required this.subject,
    required this.classInfo,
    required this.academicYear,
    required this.examDate,
    required this.durationMinutes,
    required this.formattedDuration,
    required this.totalMarks,
    required this.passingMarks,
    required this.type,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    this.questions,
    this.questionsCount,
  });

  final int id;
  final String title;
  final String code;
  final String? description;
  final String? pdfFileUrl;
  final ExamSubject subject;
  final ExamClass classInfo;
  final ExamAcademicYear academicYear;
  final DateTime examDate;
  final int durationMinutes;
  final String formattedDuration;
  final double totalMarks;
  final double passingMarks;
  final String type;
  final bool isPublished;
  final List<ExamQuestion>? questions;
  final int? questionsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Exam.fromJson(Map<String, dynamic> json) {
    try {
      // Parse dates with error handling
      DateTime? parseDate(dynamic dateValue) {
        if (dateValue == null) return null;
        if (dateValue is DateTime) return dateValue;
        if (dateValue is String) {
          try {
            return DateTime.parse(dateValue);
          } catch (e) {
            return null;
          }
        }
        return null;
      }

      final examDate = parseDate(json['exam_date']);
      if (examDate == null) {
        throw Exception('Invalid exam_date: ${json['exam_date']}');
      }

      final createdAt = parseDate(json['created_at']);
      if (createdAt == null) {
        throw Exception('Invalid created_at: ${json['created_at']}');
      }

      final updatedAt = parseDate(json['updated_at']);
      if (updatedAt == null) {
        throw Exception('Invalid updated_at: ${json['updated_at']}');
      }

      // Parse subject, class, and academic_year with null checks
      if (json['subject'] == null || json['subject'] is! Map<String, dynamic>) {
        throw Exception('Missing or invalid subject in exam JSON');
      }
      if (json['class'] == null || json['class'] is! Map<String, dynamic>) {
        throw Exception('Missing or invalid class in exam JSON');
      }
      if (json['academic_year'] == null || json['academic_year'] is! Map<String, dynamic>) {
        throw Exception('Missing or invalid academic_year in exam JSON');
      }

      return Exam(
        id: json['id'] as int? ?? 0,
        title: json['title']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        description: json['description']?.toString(),
        pdfFileUrl: json['pdf_file_url']?.toString(),
        subject: ExamSubject.fromJson(json['subject'] as Map<String, dynamic>),
        classInfo: ExamClass.fromJson(json['class'] as Map<String, dynamic>),
        academicYear: ExamAcademicYear.fromJson(json['academic_year'] as Map<String, dynamic>),
        examDate: examDate,
        durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
        formattedDuration: json['formatted_duration']?.toString() ?? '',
        totalMarks: (json['total_marks'] as num?)?.toDouble() ?? 0.0,
        passingMarks: (json['passing_marks'] as num?)?.toDouble() ?? 0.0,
        type: json['type']?.toString() ?? '',
        isPublished: json['is_published'] as bool? ?? false,
        questions: json['questions'] != null && json['questions'] is List
            ? (json['questions'] as List<dynamic>)
                .whereType<Map<String, dynamic>>()
                .map((q) => ExamQuestion.fromJson(q))
                .toList()
            : null,
        questionsCount: json['questions_count'] as int?,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      throw Exception('Failed to parse Exam from JSON: $e. JSON: $json');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'code': code,
      'description': description,
      'subject': subject.toJson(),
      'class': classInfo.toJson(),
      'academic_year': academicYear.toJson(),
      'exam_date': examDate.toIso8601String(),
      'duration_minutes': durationMinutes,
      'formatted_duration': formattedDuration,
      'total_marks': totalMarks,
      'passing_marks': passingMarks,
      'type': type,
      'is_published': isPublished,
      'questions': questions?.map((q) => q.toJson()).toList(),
      'questions_count': questionsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get typeDisplay {
    switch (type.toLowerCase()) {
      case 'quiz':
        return 'Quiz';
      case 'assignment':
        return 'Assignment';
      case 'midterm':
        return 'Midterm';
      case 'final':
        return 'Final';
      case 'project':
        return 'Project';
      default:
        return type;
    }
  }

  bool get isUpcoming => examDate.isAfter(DateTime.now());
  bool get isPast => examDate.isBefore(DateTime.now());
  bool get hasQuestions => questions != null && questions!.isNotEmpty;
}

class ExamQuestion {
  ExamQuestion({
    required this.id,
    required this.questionText,
    this.questionDescription,
    required this.marks,
    required this.order,
    required this.type,
    this.correctAnswer,
    this.options,
  });

  final int id;
  final String questionText;
  final String? questionDescription;
  final double marks;
  final int order;
  final String type;
  final String? correctAnswer;
  final List<ExamQuestionOption>? options;

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    return ExamQuestion(
      id: (json['id'] as num?)?.toInt() ?? 0,
      questionText: json['question_text']?.toString() ?? '',
      questionDescription: json['question_description']?.toString(),
      marks: (json['marks'] as num?)?.toDouble() ?? 0.0,
      order: (json['order'] as num?)?.toInt() ?? 0,
      type: json['type']?.toString() ?? '',
      correctAnswer: json['correct_answer']?.toString(),
      options: json['options'] != null && json['options'] is List
          ? (json['options'] as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map((o) => ExamQuestionOption.fromJson(o))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_text': questionText,
      'question_description': questionDescription,
      'marks': marks,
      'order': order,
      'type': type,
      'correct_answer': correctAnswer,
      'options': options?.map((o) => o.toJson()).toList(),
    };
  }

  String get typeDisplay {
    switch (type.toLowerCase()) {
      case 'multiple_choice':
        return 'Multiple Choice';
      case 'true_false':
        return 'True/False';
      case 'short_answer':
        return 'Short Answer';
      default:
        return type;
    }
  }
}

class ExamQuestionOption {
  ExamQuestionOption({
    required this.id,
    required this.optionText,
    required this.isCorrect,
    required this.order,
  });

  final int id;
  final String optionText;
  final bool isCorrect;
  final int order;

  factory ExamQuestionOption.fromJson(Map<String, dynamic> json) {
    return ExamQuestionOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      optionText: json['option_text']?.toString() ?? '',
      isCorrect: json['is_correct'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'option_text': optionText,
      'is_correct': isCorrect,
      'order': order,
    };
  }
}

class ExamSubject {
  ExamSubject({
    required this.id,
    required this.name,
    required this.code,
  });

  final int id;
  final String name;
  final String code;

  factory ExamSubject.fromJson(Map<String, dynamic> json) {
    return ExamSubject(
      id: (json['id'] as num?)?.toInt() ?? 0,
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

class ExamClass {
  ExamClass({
    required this.id,
    required this.name,
    required this.code,
  });

  final int id;
  final String name;
  final String code;

  factory ExamClass.fromJson(Map<String, dynamic> json) {
    return ExamClass(
      id: (json['id'] as num?)?.toInt() ?? 0,
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

class ExamAcademicYear {
  ExamAcademicYear({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory ExamAcademicYear.fromJson(Map<String, dynamic> json) {
    return ExamAcademicYear(
      id: (json['id'] as num?)?.toInt() ?? 0,
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

