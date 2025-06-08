import 'package:cloud_firestore/cloud_firestore.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String feature;
  final String imageUrl;
  final bool isEarned;
  final DateTime? earnedAt;
  final int difficulty;
  final Progress? progress;
  final bool isNetworkImage;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.feature,
    required this.imageUrl,
    this.isEarned = false,
    this.earnedAt,
    this.difficulty = 1,
    this.progress,
    this.isNetworkImage = false,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      feature: json['feature'] as String,
      imageUrl: json['imageUrl'] as String,
      isEarned: json['isEarned'] as bool? ?? false,
      earnedAt: json['earnedAt'] != null
          ? (json['earnedAt'] as Timestamp).toDate()
          : null,
      difficulty: json['difficulty'] as int? ?? 1,
      progress: json['progress'] != null
          ? Progress.fromJson(json['progress'] as Map<String, dynamic>)
          : null,
      isNetworkImage: json['isNetworkImage'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'feature': feature,
      'imageUrl': imageUrl,
      'isEarned': isEarned,
      'earnedAt': earnedAt,
      'difficulty': difficulty,
      'progress': progress?.toJson(),
      'isNetworkImage': isNetworkImage,
    };
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? feature,
    String? imageUrl,
    bool? isEarned,
    DateTime? earnedAt,
    int? difficulty,
    Progress? progress,
    bool? isNetworkImage,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      feature: feature ?? this.feature,
      imageUrl: imageUrl ?? this.imageUrl,
      isEarned: isEarned ?? this.isEarned,
      earnedAt: earnedAt ?? this.earnedAt,
      difficulty: difficulty ?? this.difficulty,
      progress: progress ?? this.progress,
      isNetworkImage: isNetworkImage ?? this.isNetworkImage,
    );
  }

  bool checkProgress() {
    if (progress == null) return false;
    return progress!.current >= progress!.total;
  }
}

class Progress {
  final int current;
  final int total;

  Progress({required this.current, required this.total});

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      current: json['current'] as int,
      total: json['total'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'current': current, 'total': total};
  }
}
