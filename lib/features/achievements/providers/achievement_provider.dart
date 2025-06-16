import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore for Timestamp
import 'package:firebase_auth/firebase_auth.dart';
import '../models/achievement.dart';
import '../services/nft_service.dart';
import '../data/achievement_data.dart';
import '../../web3/providers/web3_provider.dart';
import '../../breathing/providers/breathing_provider.dart';

class AchievementProvider extends ChangeNotifier {
  final List<Achievement> _achievements = [];
  Web3Provider? _web3Provider;
  NFTService? _nftService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  AchievementProvider({Web3Provider? web3Provider})
    : _web3Provider = web3Provider,
      _nftService = web3Provider != null ? NFTService(web3Provider) : null {
    _initializeAchievements();
  }

  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  void setWeb3Provider(Web3Provider web3Provider) {
    _web3Provider = web3Provider;
    _nftService = NFTService(web3Provider);
    _initializeAchievements();
  }

  Future<void> _initializeAchievements() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Initialize with default achievements
      _achievements.clear();
      _achievements.addAll(List.from(allAchievements));
      print('Initialized ${_achievements.length} achievements');

      // Load user progress and sync with Firestore and blockchain concurrently
      await Future.wait([
        _loadUserProgress(),
        _syncWithFirestore(),
        if (_web3Provider != null && _web3Provider!.isConnected)
          _syncWithBlockchain(),
      ]);

      _isInitialized = true;
      print('Final achievement count: ${_achievements.length}');
    } catch (e) {
      print('Error initializing achievements: $e');
      _error = 'Failed to load achievements';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _syncWithFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('achievements')
          .get();

      final firestoreAchievements = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'progress': {
            'current': data['progress']?['current'] ?? 0,
            'total': data['progress']?['total'] ?? 1,
          },
          'isEarned': data['isEarned'] ?? false,
          'isClaimed': data['isClaimed'] ?? false,
        };
      }).toList();

      print('Firestore achievements: ${firestoreAchievements.length}');

      // Update achievements with Firestore data
      for (var i = 0; i < _achievements.length; i++) {
        final achievement = _achievements[i];
        final firestoreAchievement = firestoreAchievements.firstWhere(
          (fa) => fa['id'] == achievement.id,
          orElse: () => {
            'id': achievement.id,
            'progress': {'current': 0, 'total': achievement.requiredCount},
            'isEarned': false,
            'isClaimed': false,
          },
        );

        _achievements[i] = achievement.copyWith(
          progress: firestoreAchievement['progress'] as Map<String, dynamic>,
          isEarned: firestoreAchievement['isEarned'] as bool,
          isClaimed: firestoreAchievement['isClaimed'] as bool,
        );
      }
    } catch (e) {
      print('Error syncing with Firestore: $e');
      // Don't set error state for Firestore sync failures
      // Just continue with local achievements
    }
  }

  Future<void> _syncWithBlockchain() async {
    if (_web3Provider == null || !_web3Provider!.isConnected) return;

    try {
      final blockchainAchievements = await _nftService!.getUserAchievements();
      print('Blockchain achievements: ${blockchainAchievements.length}');

      // Update claimed status for achievements that exist on blockchain
      for (var i = 0; i < _achievements.length; i++) {
        final achievement = _achievements[i];
        final numericId = NFTService.achievementIdMap[achievement.id];

        if (numericId != null) {
          final isClaimed = blockchainAchievements.contains(
            BigInt.from(numericId),
          );
          if (isClaimed && !achievement.isClaimed) {
            _achievements[i] = achievement.copyWith(isClaimed: true);
          }
        }
      }
    } catch (e) {
      print('Error syncing with blockchain: $e');
      // Don't set error state for blockchain sync failures
      // Just continue with local achievements
    }
  }

  Future<void> _loadUserProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userProgress = prefs.getString('user_achievements');

      if (userProgress != null) {
        final List<dynamic> progressData = json.decode(userProgress);
        print(
          'Loaded ${progressData.length} achievements from SharedPreferences',
        );

        for (var i = 0; i < _achievements.length; i++) {
          final achievement = _achievements[i];
          final progress = progressData.firstWhere(
            (p) => p['id'] == achievement.id,
            orElse: () => {
              'id': achievement.id,
              'progress': {'current': 0, 'total': achievement.requiredCount},
              'isEarned': false,
            },
          );

          _achievements[i] = achievement.copyWith(
            progress: progress['progress'] as Map<String, dynamic>,
            isEarned: progress['isEarned'] as bool,
          );
        }
      }
    } catch (e) {
      print('Error loading user progress: $e');
      // Don't set error state for local storage failures
      // Just continue with default achievements
    }
  }

  Future<void> claimAchievement(String achievementId) async {
    try {
      if (_web3Provider == null || !_web3Provider!.isConnected) {
        throw Exception('Wallet not connected');
      }

      final achievement = _achievements.firstWhere(
        (a) => a.id == achievementId,
        orElse: () => throw Exception('Achievement not found'),
      );

      if (!achievement.isEarned) {
        throw Exception('Achievement not earned yet');
      }

      if (achievement.isClaimed) {
        throw Exception('Achievement already claimed');
      }

      // Mint NFT badge
      final txHash = await _nftService!.mintBadge(achievementId);
      if (txHash == null) {
        throw Exception('Failed to mint NFT: Transaction failed');
      }

      // Update achievement status
      final index = _achievements.indexWhere((a) => a.id == achievementId);
      if (index != -1) {
        _achievements[index] = achievement.copyWith(
          isClaimed: true,
          txHash: txHash,
        );
      }

      // Save to Firestore
      await _saveToFirestore(achievementId, txHash);

      notifyListeners();
    } catch (e) {
      print('Error claiming achievement: $e');
      rethrow;
    }
  }

  Future<void> _saveToFirestore(String achievementId, String txHash) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final achievement = _achievements.firstWhere(
        (a) => a.id == achievementId,
      );
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('achievements')
          .doc(achievementId)
          .set({
            'progress': achievement.progress,
            'isEarned': achievement.isEarned,
            'isClaimed': true,
            'txHash': txHash,
            'claimedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error saving to Firestore: $e');
      // Don't throw error, just log it
    }
  }

  Future<void> refreshAchievements() async {
    await _initializeAchievements();
  }

  void updateAchievementProgress(String achievementId, int progress) {
    try {
      final index = _achievements.indexWhere((a) => a.id == achievementId);
      if (index == -1) return;

      final achievement = _achievements[index];
      final currentProgress = achievement.progress['current'] as int;
      final totalProgress = achievement.progress['total'] as int;
      final newProgress = currentProgress + progress;

      _achievements[index] = achievement.copyWith(
        progress: {'current': newProgress, 'total': totalProgress},
        isEarned: newProgress >= totalProgress,
      );

      _saveProgress();
      notifyListeners();
    } catch (e) {
      print('Error updating achievement progress: $e');
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressData = _achievements
          .map(
            (a) => {'id': a.id, 'progress': a.progress, 'isEarned': a.isEarned},
          )
          .toList();

      await prefs.setString('user_achievements', json.encode(progressData));
    } catch (e) {
      print('Error saving progress: $e');
    }
  }

  // Track breathing achievements
  void trackBreathingAchievements(BreathingProvider breathingProvider) {
    debugPrint('AchievementProvider: Tracking breathing achievements...');
    // First Breath Achievement
    if (breathingProvider.completedCycles > 0) {
      updateAchievementProgress('first_breathe', 1);
    }

    // Consistent Breather Achievement
    if (breathingProvider.totalSessions >= 5) {
      updateAchievementProgress('breathing_streak_3', 1);
    }

    // Breathing Master Achievement
    if (breathingProvider.totalBreathingTime >= 3600) {
      // 1 hour total
      updateAchievementProgress('breathing_master', 1);
    }
  }

  Achievement? getAchievementById(String id) {
    try {
      return _achievements.firstWhere((achievement) => achievement.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Achievement> getAchievementsByCategory(String category) {
    if (category == 'All') return _achievements;
    return _achievements.where((a) => a.category == category).toList();
  }

  List<Achievement> getEarnedAchievements() {
    return _achievements.where((a) => a.isEarned).toList();
  }

  List<Achievement> getClaimedAchievements() {
    return _achievements.where((a) => a.isClaimed).toList();
  }

  void clearData() {
    _achievements.clear();
    _isLoading = false;
    _error = null;
    _isInitialized = false;
    notifyListeners();
  }

  // Update breathing achievements
  void updateBreathingAchievements(BreathingProvider breathingProvider) {
    // First Breath Achievement
    if (breathingProvider.completedCycles > 0) {
      updateAchievementProgress('first_breathe', 1);
    }

    // Consistent Breather Achievement
    if (breathingProvider.totalSessions >= 5) {
      updateAchievementProgress('breathing_streak_3', 1);
    }
  }
}
