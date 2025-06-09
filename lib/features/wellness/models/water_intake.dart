class WaterIntake {
  final String id;
  final double amount; // in ml
  final DateTime timestamp;
  final String? note;

  WaterIntake({
    required this.id,
    required this.amount,
    required this.timestamp,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  factory WaterIntake.fromJson(Map<String, dynamic> json) {
    return WaterIntake(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
    );
  }
}
