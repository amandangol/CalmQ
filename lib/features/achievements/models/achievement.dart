import 'package:cloud_firestore/cloud_firestore.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final int requiredCount;
  final Map<String, dynamic> progress;
  final bool isEarned;
  final bool isClaimed;
  final Timestamp? claimedAt;
  final String? txHash;
  final String? ipfsMetadataUri;
  final String category;
  final String imageUrl;
  final int difficulty;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredCount,
    required this.progress,
    required this.isEarned,
    required this.isClaimed,
    this.claimedAt,
    this.txHash,
    this.ipfsMetadataUri,
    required this.category,
    required this.imageUrl,
    required this.difficulty,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      requiredCount: json['requiredCount'] as int,
      progress: json['progress'] as Map<String, dynamic>,
      isEarned: json['isEarned'] as bool,
      isClaimed: json['isClaimed'] as bool,
      claimedAt: json['claimedAt'] as Timestamp?,
      txHash: json['txHash'] as String?,
      ipfsMetadataUri: json['ipfsMetadataUri'] as String?,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      difficulty: json['difficulty'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'requiredCount': requiredCount,
      'progress': progress,
      'isEarned': isEarned,
      'isClaimed': isClaimed,
      'claimedAt': claimedAt,
      'txHash': txHash,
      'ipfsMetadataUri': ipfsMetadataUri,
      'category': category,
      'imageUrl': imageUrl,
      'difficulty': difficulty,
    };
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    int? requiredCount,
    Map<String, dynamic>? progress,
    bool? isEarned,
    bool? isClaimed,
    Timestamp? claimedAt,
    String? txHash,
    String? ipfsMetadataUri,
    String? category,
    String? imageUrl,
    int? difficulty,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      requiredCount: requiredCount ?? this.requiredCount,
      progress: progress ?? this.progress,
      isEarned: isEarned ?? this.isEarned,
      isClaimed: isClaimed ?? this.isClaimed,
      claimedAt: claimedAt ?? this.claimedAt,
      txHash: txHash ?? this.txHash,
      ipfsMetadataUri: ipfsMetadataUri ?? this.ipfsMetadataUri,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
