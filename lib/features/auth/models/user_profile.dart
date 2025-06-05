class UserProfile {
  final String uid;
  final String name;
  final int age;
  final String? gender;
  final List<String> goals;
  final List<String> causes;
  final String? stressFrequency;
  final String? healthyEating;
  final String? meditationExperience;
  final String? sleepQuality;
  final String? happinessLevel;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.age,
    this.gender,
    this.goals = const [],
    this.causes = const [],
    this.stressFrequency,
    this.healthyEating,
    this.meditationExperience,
    this.sleepQuality,
    this.happinessLevel,
    this.createdAt,
    this.updatedAt,
  });

  // Convert UserProfile to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
      'gender': gender,
      'goals': goals,
      'causes': causes,
      'stressFrequency': stressFrequency,
      'healthyEating': healthyEating,
      'meditationExperience': meditationExperience,
      'sleepQuality': sleepQuality,
      'happinessLevel': happinessLevel,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Create UserProfile from Firestore JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'],
      goals: List<String>.from(json['goals'] ?? []),
      causes: List<String>.from(json['causes'] ?? []),
      stressFrequency: json['stressFrequency'],
      healthyEating: json['healthyEating'],
      meditationExperience: json['meditationExperience'],
      sleepQuality: json['sleepQuality'],
      happinessLevel: json['happinessLevel'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // Create a copy with updated values
  UserProfile copyWith({
    String? uid,
    String? name,
    int? age,
    String? gender,
    List<String>? goals,
    List<String>? causes,
    String? stressFrequency,
    String? healthyEating,
    String? meditationExperience,
    String? sleepQuality,
    String? happinessLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      goals: goals ?? this.goals,
      causes: causes ?? this.causes,
      stressFrequency: stressFrequency ?? this.stressFrequency,
      healthyEating: healthyEating ?? this.healthyEating,
      meditationExperience: meditationExperience ?? this.meditationExperience,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      happinessLevel: happinessLevel ?? this.happinessLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
