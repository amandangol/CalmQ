// models/journal_entry.dart
class JournalEntry {
  final String id;
  final String title;
  final String content;
  final String mood;
  final List<String> gratitudeItems;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> tags;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.gratitudeItems,
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
  });

  JournalEntry copyWith({
    String? id,
    String? title,
    String? content,
    String? mood,
    List<String>? gratitudeItems,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      gratitudeItems: gratitudeItems ?? this.gratitudeItems,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'mood': mood,
      'gratitudeItems': gratitudeItems,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'tags': tags,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      mood: json['mood'] ?? 'Neutral',
      gratitudeItems: List<String>.from(json['gratitudeItems'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
