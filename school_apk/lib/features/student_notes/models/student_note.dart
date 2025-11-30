import 'package:intl/intl.dart';

class StudentNote {
  StudentNote({
    required this.id,
    required this.title,
    required this.content,
    required this.colorHex,
    required this.isPinned,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String? content;
  final String? colorHex;
  final bool isPinned;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory StudentNote.fromJson(Map<String, dynamic> json) {
    return StudentNote(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      content: json['content'] as String?,
      colorHex: json['color_hex'] as String?,
      isPinned: json['is_pinned'] == true,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((tag) => tag.toString())
              .toList() ??
          const [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  StudentNote copyWith({
    int? id,
    String? title,
    String? content,
    String? colorHex,
    bool? isPinned,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentNote(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      colorHex: colorHex ?? this.colorHex,
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get friendlyUpdatedAt {
    if (updatedAt == null) return '';
    final formatter = DateFormat('MMM d • hh:mm a');
    return formatter.format(updatedAt!);
  }
}


