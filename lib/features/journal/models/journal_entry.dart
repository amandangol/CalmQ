// models/journal_entry.dart
class JournalEntry {
  final String id;
  final String title;
  final String content;
  final String mood;
  final int gratitudeLevel;
  final int stressLevel;
  final List<String> tags;
  final bool isPrivate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.gratitudeLevel,
    required this.stressLevel,
    required this.tags,
    required this.isPrivate,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'mood': mood,
      'gratitudeLevel': gratitudeLevel,
      'stressLevel': stressLevel,
      'tags': tags,
      'isPrivate': isPrivate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      mood: json['mood'],
      gratitudeLevel: json['gratitudeLevel'],
      stressLevel: json['stressLevel'],
      tags: List<String>.from(json['tags']),
      isPrivate: json['isPrivate'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  JournalEntry copyWith({
    String? id,
    String? title,
    String? content,
    String? mood,
    int? gratitudeLevel,
    int? stressLevel,
    List<String>? tags,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      gratitudeLevel: gratitudeLevel ?? this.gratitudeLevel,
      stressLevel: stressLevel ?? this.stressLevel,
      tags: tags ?? this.tags,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
