class JournalEntry {
  final String uid;
  final DateTime date;
  final String entry;
  final String? prompt;
  final DateTime timestamp;

  JournalEntry({
    required this.uid,
    required this.date,
    required this.entry,
    this.prompt,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'date': date.toIso8601String(),
      'entry': entry,
      'prompt': prompt,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      uid: json['uid'] as String,
      date: DateTime.parse(json['date'] as String),
      entry: json['entry'] as String,
      prompt: json['prompt'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
