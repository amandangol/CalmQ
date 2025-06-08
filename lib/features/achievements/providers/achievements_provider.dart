import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/achievement.dart';
import '../../web3/providers/web3_provider.dart';

class AchievementsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Web3Provider _web3Provider;
  List<Achievement> _achievements = [];
  bool _isLoading = false;
  bool _isDisposed = false;
  bool _isInitialized = false;

  AchievementsProvider(this._web3Provider);

  List<Achievement> get allAchievements => _achievements;
  bool get isLoading => _isLoading;

  void updateWeb3Provider(Web3Provider web3Provider) {
    _web3Provider = web3Provider;
    if (_web3Provider.isConnected) {
      Future.microtask(() => _loadOnChainAchievements());
    }
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  Future<void> loadAchievements() async {
    if (_isDisposed) return;

    // If we already have achievements and are initialized, don't reload
    if (_isInitialized && _achievements.isNotEmpty) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Loading achievements from Firestore...');
      final snapshot = await _firestore.collection('achievements').get();

      if (_isDisposed) return;

      final loadedAchievements = snapshot.docs
          .map((doc) => Achievement.fromJson(doc.data()))
          .toList();

      debugPrint(
        'Loaded ${loadedAchievements.length} achievements from Firestore',
      );

      _achievements = loadedAchievements;
      _isInitialized = true;
      notifyListeners();

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
    if (_isDisposed) return;

    try {
      await _web3Provider.loadWellnessNFTs();

      final updatedAchievements = _achievements.map((achievement) {
        final isEarned = _web3Provider.wellnessNFTs.contains(achievement.id);
        return achievement.copyWith(isEarned: isEarned);
      }).toList();

      if (!_isDisposed) {
        _achievements = updatedAchievements;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading on-chain achievements: $e');
    }
  }

  List<Achievement> getAchievementsByFeature(String feature) {
    return _achievements.where((a) => a.feature == feature).toList();
  }

  List<Achievement> getCompletedAchievements() {
    return _achievements.where((a) => a.isEarned).toList();
  }

  List<String> getUniqueFeatures() {
    return _achievements.map((a) => a.feature).toSet().toList();
  }

  Future<void> checkAndAwardAchievements(String feature) async {
    if (!_web3Provider.isConnected) return;

    try {
      final featureAchievements = getAchievementsByFeature(feature);
      for (final achievement in featureAchievements) {
        if (!achievement.isEarned &&
            (achievement.progress == null || achievement.checkProgress())) {
          await _awardAchievement(achievement);
        }
      }
    } catch (e) {
      debugPrint('Error checking achievements: $e');
    }
  }

  Future<void> _awardAchievement(Achievement achievement) async {
    try {
      final tokenReward = achievement.difficulty * 10;

      await _web3Provider.awardTokens(tokenReward);
      await _web3Provider.mintAchievementNFT(
        achievement.id,
        achievement.title,
        achievement.description,
        achievement.feature,
        achievement.difficulty,
        achievement.imageUrl,
      );

      await _firestore.collection('achievements').doc(achievement.id).update({
        'isEarned': true,
        'earnedAt': FieldValue.serverTimestamp(),
        'tokenReward': tokenReward,
      });

      if (!_isDisposed) {
        final index = _achievements.indexWhere((a) => a.id == achievement.id);
        if (index != -1) {
          _achievements[index] = achievement.copyWith(isEarned: true);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error awarding achievement: $e');
      rethrow;
    }
  }

  void clearData() {
    _achievements = [];
    _isInitialized = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    clearData();
    super.dispose();
  }
}
