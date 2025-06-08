import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/achievement.dart';
import '../../web3/providers/web3_provider.dart';

class AchievementsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Web3Provider _web3Provider;
  List<Achievement> _achievements = [];
  bool _isLoading = false;
  bool _isDisposed = false;

  AchievementsProvider(this._web3Provider);

  List<Achievement> get allAchievements => _achievements;
  bool get isLoading => _isLoading;

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  Future<void> loadAchievements() async {
    if (_isDisposed) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('achievements').get();
      if (_isDisposed) return;

      _achievements = snapshot.docs
          .map((doc) => Achievement.fromJson(doc.data()))
          .toList();

      // Load on-chain achievement status if wallet is connected
      if (_web3Provider.isConnected) {
        await _loadOnChainAchievements();
      }
    } catch (e) {
      debugPrint('Error loading achievements: $e');
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadOnChainAchievements() async {
    try {
      // Load user's NFTs
      await _web3Provider.loadWellnessNFTs();

      // Update achievement status based on NFTs
      for (var achievement in _achievements) {
        final isEarned = _web3Provider.wellnessNFTs.contains(achievement.id);
        if (isEarned != achievement.isEarned) {
          achievement = achievement.copyWith(isEarned: isEarned);
        }
      }
    } catch (e) {
      debugPrint('Error loading on-chain achievements: $e');
    }
  }

  List<Achievement> getAchievementsByFeature(String feature) {
    return _achievements.where((a) => a.feature == feature).toList();
  }

  Future<void> checkAndAwardAchievements(String feature) async {
    if (!_web3Provider.isConnected) return;

    try {
      final featureAchievements = getAchievementsByFeature(feature);
      for (final achievement in featureAchievements) {
        if (!achievement.isEarned && achievement.checkProgress()) {
          await _awardAchievement(achievement);
        }
      }
    } catch (e) {
      debugPrint('Error checking achievements: $e');
    }
  }

  Future<void> _awardAchievement(Achievement achievement) async {
    try {
      // Award on-chain
      await _web3Provider.completeAchievement(
        achievement.id,
        achievement.description,
        achievement.feature,
        achievement.difficulty,
        achievement.imageUrl,
      );

      // Update Firestore
      await _firestore.collection('achievements').doc(achievement.id).update({
        'isEarned': true,
        'earnedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      final index = _achievements.indexWhere((a) => a.id == achievement.id);
      if (index != -1) {
        _achievements[index] = achievement.copyWith(isEarned: true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error awarding achievement: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
