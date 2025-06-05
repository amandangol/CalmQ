class JournalEntry {
  final String id;
  final String title;
  final String content;
  final String mood;
  final String emoji;
  final DateTime date;
  final List<String> tags;
  final int gratitudeScore;
  final int stressLevel;
  final int energyLevel;
  final List<String> emotions;
  final String? photoPath;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.emoji,
    required this.date,
    this.tags = const [],
    this.gratitudeScore = 5,
    this.stressLevel = 5,
    this.energyLevel = 5,
    this.emotions = const [],
    this.photoPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'mood': mood,
      'emoji': emoji,
      'date': date.toIso8601String(),
      'tags': tags,
      'gratitudeScore': gratitudeScore,
      'stressLevel': stressLevel,
      'energyLevel': energyLevel,
      'emotions': emotions,
      'photoPath': photoPath,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      mood: json['mood'] as String,
      emoji: json['emoji'] as String,
      date: DateTime.parse(json['date'] as String),
      tags: List<String>.from(json['tags'] ?? []),
      gratitudeScore: json['gratitudeScore'] ?? 5,
      stressLevel: json['stressLevel'] ?? 5,
      energyLevel: json['energyLevel'] ?? 5,
      emotions: List<String>.from(json['emotions'] ?? []),
      photoPath: json['photoPath'] as String?,
    );
  }
}
