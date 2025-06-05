class MoodEntry {
  final String uid;
  final DateTime date;
  final String mood;
  final int? stressLevel;
  final String? notes;
  final DateTime timestamp;

  MoodEntry({
    required this.uid,
    required this.date,
    required this.mood,
    this.stressLevel,
    this.notes,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'date': date.toIso8601String(),
      'mood': mood,
      'stressLevel': stressLevel,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      uid: json['uid'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: json['mood'] as String,
      stressLevel: json['stressLevel'] as int?,
      notes: json['notes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
