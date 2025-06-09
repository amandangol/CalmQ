import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import '../models/achievement.dart';
import '../../web3/providers/web3_provider.dart';

class AchievementProvider extends ChangeNotifier {
  final List<Achievement> _achievements = [];
  final Map<String, int> _activityCounts = {};
  Web3Provider? _web3Provider;

  List<Achievement> get achievements => _achievements;

  AchievementProvider() {
    _initializeAchievements();
  }

  void setWeb3Provider(Web3Provider provider) {
    _web3Provider = provider;
  }

  void _initializeAchievements() {
    _achievements.addAll([
      Achievement(
        id: 'breathing_beginner',
        title: 'Breathing Beginner',
        description: 'Complete your first breathing session',
        iconPath: 'assets/icon/icon.png',
        type: AchievementType.breathing,
        requiredCount: 1,
      ),
      Achievement(
        id: 'mood_tracker',
        title: 'Mood Tracker',
        description: 'Track your mood for 7 days',
        iconPath: 'assets/images/happy.png',
        type: AchievementType.mood,
        requiredCount: 7,
      ),
      Achievement(
        id: 'journal_master',
        title: 'Journal Master',
        description: 'Write 10 journal entries',
        iconPath: 'assets/icon/icon.png',
        type: AchievementType.journal,
        requiredCount: 10,
      ),
      Achievement(
        id: 'water_champion',
        title: 'Water Champion',
        description: 'Track water intake for 14 days',
        iconPath: 'assets/icon/icon.png',
        type: AchievementType.water,
        requiredCount: 14,
      ),
      Achievement(
        id: 'focus_pro',
        title: 'Focus Pro',
        description: 'Complete 20 focus sessions',
        iconPath: 'assets/icon/icon.png',
        type: AchievementType.focus,
        requiredCount: 20,
      ),
    ]);
  }

  void incrementActivityCount(AchievementType type) {
    final typeString = type.toString().split('.').last;
    _activityCounts[typeString] = (_activityCounts[typeString] ?? 0) + 1;
    _checkAchievements();
    notifyListeners();
  }

  void _checkAchievements() {
    for (var i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      final typeString = achievement.type.toString().split('.').last;
      final currentCount = _activityCounts[typeString] ?? 0;

      if (!achievement.isUnlocked &&
          currentCount >= achievement.requiredCount) {
        _achievements[i] = achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
      }
    }
  }

  Future<void> claimAchievement(String achievementId) async {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1 &&
        _achievements[index].isUnlocked &&
        !_achievements[index].isClaimed) {
      try {
        // Check if wallet is connected
        if (_web3Provider == null || !_web3Provider!.isConnected) {
          throw Exception('Please connect your wallet to claim achievements');
        }

        // Mint NFT for the achievement
        await _mintAchievementNFT(_achievements[index]);

        // Update achievement status
        _achievements[index] = _achievements[index].copyWith(
          isClaimed: true,
          claimedAt: DateTime.now(),
        );
        notifyListeners();
      } catch (e) {
        debugPrint('Error claiming achievement: $e');
        rethrow;
      }
    }
  }

  Future<void> _mintAchievementNFT(Achievement achievement) async {
    if (_web3Provider == null) {
      debugPrint('Web3Provider is null');
      throw Exception('Web3Provider not initialized');
    }

    try {
      // Get the NFT contract
      final nftContract = _web3Provider!.wellnessNFTContract;
      if (nftContract == null) {
        debugPrint('NFT contract is null');
        throw Exception('NFT contract not initialized');
      }

      debugPrint('Contract address: ${nftContract.address.hex}');
      debugPrint('Achievement ID: ${achievement.id}');

      // Get the achievement ID and convert to BigInt
      final achievementId = BigInt.from(_getAchievementTokenId(achievement.id));
      debugPrint('Token ID: $achievementId');

      // Check if user already has this achievement
      final userAddress = EthereumAddress.fromHex(
        _web3Provider!.walletAddress!,
      );
      final getUserAchievements = nftContract.function('getUserAchievements');

      try {
        final result = await _web3Provider!.client.call(
          contract: nftContract,
          function: getUserAchievements,
          params: [userAddress],
        );

        final userAchievements = (result[0] as List<dynamic>).cast<BigInt>();
        debugPrint(
          'User achievements: ${userAchievements.map((a) => a.toString()).join(', ')}',
        );

        if (userAchievements.contains(achievementId)) {
          throw Exception('You have already minted this achievement');
        }
      } catch (e) {
        debugPrint('Error checking user achievements: $e');
        // Continue anyway, as this might be a view function error
      }

      // Prepare the mint function
      final mintFunction = nftContract.function('mintAchievement');

      // First, try to simulate the call
      try {
        // Check if the user has already minted this achievement
        final getUserAchievements = nftContract.function('getUserAchievements');
        final userAchievements = await _web3Provider!.client.call(
          contract: nftContract,
          function: getUserAchievements,
          params: [userAddress],
        );
        debugPrint('User achievements: ${userAchievements[0]}');

        // Convert achievement ID to uint256
        final achievementIdInt = BigInt.from(
          1,
        ); // For now, hardcode to 1 for breathing_beginner

        // Try the mint simulation
        final txData = await _web3Provider!.client.call(
          contract: nftContract,
          function: mintFunction,
          params: [achievementIdInt],
        );
        debugPrint('Simulation successful: $txData');
      } catch (e) {
        debugPrint('Simulation failed: $e');
        // Try to get more information about the revert
        try {
          // Check if the user has any achievements
          final getUserAchievements = nftContract.function(
            'getUserAchievements',
          );
          final userAchievements = await _web3Provider!.client.call(
            contract: nftContract,
            function: getUserAchievements,
            params: [userAddress],
          );
          debugPrint('User achievements: ${userAchievements[0]}');

          // Check if the achievement ID is valid
          debugPrint('Attempting to mint achievement ID: 1');
        } catch (e) {
          debugPrint('Error getting additional info: $e');
        }
        throw Exception('Transaction would fail: $e');
      }

      // Encode the function call
      final data = mintFunction.encodeCall([BigInt.from(1)]);
      debugPrint(
        'Encoded data: 0x${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}',
      );

      // Send the transaction using Web3Provider's sendTransaction method
      final txHash = await _web3Provider!.sendTransaction(
        to: nftContract.address,
        data: data,
        gasLimit: 100000,
      );

      if (txHash == null) {
        debugPrint('Transaction failed - no hash returned');
        throw Exception('Transaction failed - no hash returned');
      }

      debugPrint('Transaction hash: $txHash');

      // Wait for transaction confirmation with retries
      TransactionReceipt? receipt;
      int retries = 0;
      const maxRetries = 5;
      const retryDelay = Duration(seconds: 2);

      while (retries < maxRetries) {
        try {
          receipt = await _web3Provider!.client.getTransactionReceipt(txHash);
          if (receipt != null) {
            break;
          }
        } catch (e) {
          debugPrint('Error getting receipt: $e');
        }
        await Future.delayed(retryDelay);
        retries++;
      }

      if (receipt == null) {
        throw Exception(
          'Transaction confirmation timeout after ${maxRetries * retryDelay.inSeconds} seconds',
        );
      }

      if (receipt.status == false) {
        // Get the transaction details from the receipt
        debugPrint('Failed transaction details:');
        debugPrint('Block number: ${receipt.blockNumber}');
        debugPrint('Gas used: ${receipt.gasUsed}');
        debugPrint('Status: ${receipt.status}');

        throw Exception('Transaction failed on chain. Check logs for details.');
      }

      debugPrint('Transaction confirmed in block: ${receipt.blockNumber}');

      // Refresh NFTs after minting
      await _web3Provider!.loadWellnessNFTs();
    } catch (e, stackTrace) {
      debugPrint('Error minting NFT: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  int _getAchievementTokenId(String achievementId) {
    // Map achievement IDs to token IDs
    final tokenIdMap = {
      'breathing_beginner': 1,
      'mood_tracker': 2,
      'journal_master': 3,
      'water_champion': 4,
      'focus_pro': 5,
    };
    return tokenIdMap[achievementId] ?? 0;
  }

  int getActivityCount(AchievementType type) {
    final typeString = type.toString().split('.').last;
    return _activityCounts[typeString] ?? 0;
  }

  void resetAchievements() {
    _activityCounts.clear();
    for (var i = 0; i < _achievements.length; i++) {
      _achievements[i] = _achievements[i].copyWith(
        isUnlocked: false,
        isClaimed: false,
        unlockedAt: null,
        claimedAt: null,
      );
    }
    notifyListeners();
  }
}
