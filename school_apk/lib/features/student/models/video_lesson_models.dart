class VideoLesson {
  VideoLesson({
    required this.id,
    required this.title,
    this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.subject,
    required this.classInfo,
    this.academicYear,
    required this.teacher,
    this.lessonDate,
    this.durationMinutes,
    required this.formattedDuration,
    required this.status,
    this.attachments,
    this.viewsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String? description;
  final String videoUrl;
  final String? thumbnailUrl;
  final VideoLessonSubject subject;
  final VideoLessonClass classInfo;
  final VideoLessonAcademicYear? academicYear;
  final VideoLessonTeacher teacher;
  final DateTime? lessonDate;
  final int? durationMinutes;
  final String formattedDuration;
  final String status;
  final List<VideoLessonAttachment>? attachments;
  final int? viewsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory VideoLesson.fromJson(Map<String, dynamic> json) {
    return VideoLesson(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      videoUrl: json['video_url']?.toString() ?? '',
      thumbnailUrl: json['thumbnail_url']?.toString(),
      subject: VideoLessonSubject.fromJson(json['subject'] as Map<String, dynamic>),
      classInfo: VideoLessonClass.fromJson(json['class'] as Map<String, dynamic>),
      academicYear: json['academic_year'] != null
          ? VideoLessonAcademicYear.fromJson(json['academic_year'] as Map<String, dynamic>)
          : null,
      teacher: VideoLessonTeacher.fromJson(json['teacher'] as Map<String, dynamic>),
      lessonDate: json['lesson_date'] != null
          ? DateTime.parse(json['lesson_date'] as String)
          : null,
      durationMinutes: json['duration_minutes'] as int?,
      formattedDuration: json['formatted_duration']?.toString() ?? 'N/A',
      status: json['status']?.toString() ?? 'draft',
      attachments: json['attachments'] != null
          ? (json['attachments'] as List<dynamic>)
              .map((a) => VideoLessonAttachment.fromJson(a as Map<String, dynamic>))
              .toList()
          : null,
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
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'subject': subject.toJson(),
      'class': classInfo.toJson(),
      'academic_year': academicYear?.toJson(),
      'teacher': teacher.toJson(),
      'lesson_date': lessonDate?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'formatted_duration': formattedDuration,
      'status': status,
      'attachments': attachments?.map((a) => a.toJson()).toList(),
      'views_count': viewsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'published':
        return 'Published';
      case 'draft':
        return 'Draft';
      default:
        return status;
    }
  }

  bool get isYouTube => videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be');
  bool get isVimeo => videoUrl.contains('vimeo.com');
}

class VideoLessonSubject {
  VideoLessonSubject({
    required this.id,
    required this.name,
    required this.code,
  });

  final int id;
  final String name;
  final String code;

  factory VideoLessonSubject.fromJson(Map<String, dynamic> json) {
    return VideoLessonSubject(
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

class VideoLessonClass {
  VideoLessonClass({
    required this.id,
    required this.name,
    required this.code,
  });

  final int id;
  final String name;
  final String code;

  factory VideoLessonClass.fromJson(Map<String, dynamic> json) {
    return VideoLessonClass(
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

class VideoLessonAcademicYear {
  VideoLessonAcademicYear({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory VideoLessonAcademicYear.fromJson(Map<String, dynamic> json) {
    return VideoLessonAcademicYear(
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

class VideoLessonTeacher {
  VideoLessonTeacher({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory VideoLessonTeacher.fromJson(Map<String, dynamic> json) {
    return VideoLessonTeacher(
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

class VideoLessonAttachment {
  VideoLessonAttachment({
    required this.name,
    required this.url,
  });

  final String name;
  final String url;

  factory VideoLessonAttachment.fromJson(Map<String, dynamic> json) {
    return VideoLessonAttachment(
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

