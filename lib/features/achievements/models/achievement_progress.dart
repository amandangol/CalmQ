class AchievementProgress {
  final int current;
  final int total;

  const AchievementProgress({required this.current, required this.total});

  bool get isComplete => current >= total;

  Map<String, dynamic> toJson() => {'current': current, 'total': total};

  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    return AchievementProgress(
      current: json['current'] as int,
      total: json['total'] as int,
    );
  }
}
