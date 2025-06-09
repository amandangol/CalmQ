import 'package:flutter/material.dart';

enum AchievementType { breathing, mood, journal, water, focus }

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final AchievementType type;
  final int requiredCount;
  final bool isUnlocked;
  final bool isClaimed;
  final DateTime? unlockedAt;
  final DateTime? claimedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.type,
    required this.requiredCount,
    this.isUnlocked = false,
    this.isClaimed = false,
    this.unlockedAt,
    this.claimedAt,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconPath,
    AchievementType? type,
    int? requiredCount,
    bool? isUnlocked,
    bool? isClaimed,
    DateTime? unlockedAt,
    DateTime? claimedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      type: type ?? this.type,
      requiredCount: requiredCount ?? this.requiredCount,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isClaimed: isClaimed ?? this.isClaimed,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }
}
