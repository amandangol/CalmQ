import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class Web3Provider with ChangeNotifier {
  ReownAppKitModal? _appKitModal;
  String? _walletAddress;
  bool _isConnecting = false;
  bool _isConnected = false;
  String? _error;
  List<String> _wellnessNFTs = [];
  int _wellnessTokens = 0;
  bool _isLoadingNFTs = false;
  bool _isLoadingTokens = false;
  BigInt _ethBalance = BigInt.zero;
  bool _isLoadingBalance = false;
  int _tokenBalance = 0;

  // Contract addresses
  static const String wellnessTokenAddress =
      '0xb734524de04Ec6b93D30e7132f4034e4F8Ea16cF';
  static const String wellnessNFTAddress =
      '0x90D85445d55CA4F35B592355D90ecff6AC1F9740';
  static const String wellnessSystemAddress =
      '0xFf5bD3Aa319Aa8b02Cf95BED94A3F85983Ab79cb';

  // Contract ABIs
  static const String wellnessTokenABI = '''[
    {"inputs":[],"stateMutability":"nonpayable","type":"constructor"},
    {"anonymous":false,"inputs":[{"indexed":true,"name":"minter","type":"address"},{"indexed":false,"name":"status","type":"bool"}],"name":"MinterStatusChanged","type":"event"},
    {"inputs":[{"name":"to","type":"address"},{"name":"amount","type":"uint256"}],"name":"mint","outputs":[],"stateMutability":"nonpayable","type":"function"},
    {"inputs":[{"name":"minter","type":"address"},{"name":"status","type":"bool"}],"name":"setMinter","outputs":[],"stateMutability":"nonpayable","type":"function"},
    {"inputs":[{"name":"","type":"address"}],"name":"minters","outputs":[{"name":"","type":"bool"}],"stateMutability":"view","type":"function"}
  ]''';

  static const String wellnessNFTABI = '''[
    {"inputs":[],"stateMutability":"nonpayable","type":"constructor"},
    {"anonymous":false,"inputs":[{"indexed":true,"name":"user","type":"address"},{"indexed":false,"name":"tokenId","type":"uint256"},{"indexed":false,"name":"achievementName","type":"string"}],"name":"AchievementMinted","type":"event"},
    {"inputs":[{"name":"to","type":"address"},{"name":"name","type":"string"},{"name":"description","type":"string"},{"name":"category","type":"string"},{"name":"difficulty","type":"uint256"},{"name":"imageUri","type":"string"}],"name":"mintAchievement","outputs":[{"name":"","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},
    {"inputs":[{"name":"user","type":"address"}],"name":"getUserAchievements","outputs":[{"name":"","type":"uint256[]"}],"stateMutability":"view","type":"function"}
  ]''';

  static const String wellnessSystemABI = '''[
    {"inputs":[{"name":"_wellnessToken","type":"address"},{"name":"_achievementNFT","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},
    {"anonymous":false,"inputs":[{"indexed":true,"name":"user","type":"address"},{"indexed":false,"name":"achievementName","type":"string"},{"indexed":false,"name":"tokenReward","type":"uint256"}],"name":"AchievementCompleted","type":"event"},
    {"inputs":[{"name":"user","type":"address"},{"name":"achievementName","type":"string"},{"name":"description","type":"string"},{"name":"category","type":"string"},{"name":"difficulty","type":"uint256"},{"name":"imageUri","type":"string"}],"name":"completeAchievement","outputs":[],"stateMutability":"nonpayable","type":"function"},
    {"inputs":[{"name":"user","type":"address"},{"name":"achievementName","type":"string"}],"name":"getUserProgress","outputs":[{"name":"","type":"uint256"}],"stateMutability":"view","type":"function"}
  ]''';

  // Web3 client and contracts
  late Web3Client _client;
  late DeployedContract _wellnessTokenContract;
  late DeployedContract _wellnessNFTContract;
  late DeployedContract _wellnessSystemContract;

  // Getters
  bool get isConnected => _isConnected;
  String? get walletAddress => _walletAddress;
  bool get isLoadingBalance => _isLoadingBalance;
  bool get isConnecting => _isConnecting;
  int get wellnessTokens => _wellnessTokens;
  String get ethBalance => _formatEthBalance(_ethBalance);
  int get tokenBalance => _tokenBalance;
  int get nftCount => _wellnessNFTs.length;
  List<dynamic> get wellnessNFTs => _wellnessNFTs;
  String? get error => _error;

  String _formatEthBalance(BigInt balance) {
    final ethValue = balance / BigInt.from(10).pow(18);
    final remainder = balance % BigInt.from(10).pow(18);
    final remainderStr = remainder.toString().padLeft(18, '0');

    // Handle very small values
    if (ethValue == BigInt.zero) {
      final decimalPart = remainderStr.substring(0, 6);
      final nonZeroIndex = decimalPart.indexOf(RegExp(r'[1-9]'));
      if (nonZeroIndex == -1) return '0 ETH';

      // Show up to 4 significant digits after the first non-zero digit
      final significantDigits = decimalPart.substring(nonZeroIndex);
      final displayDigits = significantDigits.length > 4
          ? significantDigits.substring(0, 4)
          : significantDigits;
      return '0.${displayDigits} ETH';
    }

    // For values >= 1 ETH, show up to 2 decimal places
    final decimalPart = remainderStr.substring(0, 2);
    return '${ethValue.toString()}.${decimalPart} ETH';
  }

  Future<void> initialize(BuildContext context) async {
    try {
      // Initialize Web3 client
      _client = Web3Client(
        'https://ethereum-sepolia-rpc.publicnode.com',
        http.Client(),
      );

      // Initialize contracts
      _wellnessTokenContract = DeployedContract(
        ContractAbi.fromJson(wellnessTokenABI, 'WellnessToken'),
        EthereumAddress.fromHex(wellnessTokenAddress),
      );

      _wellnessNFTContract = DeployedContract(
        ContractAbi.fromJson(wellnessNFTABI, 'WellnessAchievementNFT'),
        EthereumAddress.fromHex(wellnessNFTAddress),
      );

      _wellnessSystemContract = DeployedContract(
        ContractAbi.fromJson(wellnessSystemABI, 'WellnessAchievementSystem'),
        EthereumAddress.fromHex(wellnessSystemAddress),
      );

      // Initialize WalletConnect
      _appKitModal = ReownAppKitModal(
        context: context,
        projectId: '58c3eec119930a1be0c1ba6911349422',
        metadata: PairingMetadata(
          name: 'CalmQ',
          description: 'CalmQ - Your Wellness Companion',
          url: 'https://calmq.app',
          icons: ['https://calmq.app/icon.png'],
        ),
        featuresConfig: FeaturesConfig(
          socials: [
            AppKitSocialOption.Email,
            AppKitSocialOption.Google,
            AppKitSocialOption.Apple,
          ],
          showMainWallets: true,
        ),
      );

      // Listen to connection events
      _appKitModal?.onModalConnect.subscribe((event) async {
        if (event?.session != null) {
          _walletAddress = event!.session.getAddress('eip155');
          _isConnected = true;
          await _saveWalletAddress(_walletAddress!);
          await _saveWalletAddressToFirebase(_walletAddress!);
          _loadWalletData();
          notifyListeners();
        }
      });

      _appKitModal?.onModalDisconnect.subscribe((event) async {
        _walletAddress = null;
        _isConnected = false;
        await _removeWalletAddress();
        _clearWalletData();
        notifyListeners();
      });

      await _appKitModal!.init();

      // Try to load wallet address from Firebase first
      final savedAddress = await _loadWalletAddressFromFirebase();
      if (savedAddress != null) {
        _walletAddress = savedAddress;
        _isConnected = true;
        _loadWalletData();
      } else {
        // Fallback to local storage
        final prefs = await SharedPreferences.getInstance();
        _walletAddress = prefs.getString('wallet_address');
        _isConnected = _walletAddress != null;
        if (_isConnected) {
          _loadWalletData();
        }
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize: $e';
      notifyListeners();
    }
  }

  Future<void> _loadWalletData() async {
    if (!_isConnected || _walletAddress == null) return;

    await Future.wait([
      loadWellnessNFTs(),
      loadWellnessTokens(),
      loadEthBalance(),
    ]);
  }

  void _clearWalletData() {
    _wellnessNFTs = [];
    _wellnessTokens = 0;
    _ethBalance = BigInt.zero;
  }

  Future<void> loadEthBalance() async {
    if (!_isConnected || _walletAddress == null) return;

    try {
      _isLoadingBalance = true;
      notifyListeners();

      final userAddress = EthereumAddress.fromHex(_walletAddress!);
      final balance = await _client.getBalance(userAddress);
      _ethBalance = balance.getInWei;

      _isLoadingBalance = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load ETH balance: $e';
      _isLoadingBalance = false;
      notifyListeners();
    }
  }

  Future<void> connectWallet() async {
    try {
      _isConnecting = true;
      _error = null;
      notifyListeners();

      if (_appKitModal == null) {
        throw Exception('AppKit not initialized');
      }

      // Reset any existing session and state
      await _appKitModal!.disconnect();
      _walletAddress = null;
      _isConnected = false;
      _wellnessNFTs = [];
      _wellnessTokens = 0;
      _ethBalance = BigInt.zero;
      notifyListeners();

      // Reinitialize modal before opening
      await _appKitModal!.init();

      // Open the wallet connection modal with error handling
      try {
        await _appKitModal!.openModalView(ReownAppKitModalMainWalletsPage());
      } catch (modalError) {
        debugPrint('Error opening modal: $modalError');
        // Try to reinitialize and open again
        await _appKitModal!.init();
        await _appKitModal!.openModalView(ReownAppKitModalMainWalletsPage());
      }
    } catch (e) {
      _error = 'Failed to connect wallet: $e';
      _isConnected = false;
      debugPrint('Wallet connection error: $e');
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<void> disconnectWallet() async {
    try {
      if (_appKitModal != null) {
        await _appKitModal!.disconnect();
      }
      _walletAddress = null;
      _isConnected = false;
      _error = null;
      _wellnessNFTs = [];
      _wellnessTokens = 0;
      _ethBalance = BigInt.zero;
      _tokenBalance = 0;
      await _removeWalletAddress();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to disconnect wallet: $e';
      notifyListeners();
    }
  }

  Future<String?> requestSignature(String message) async {
    if (!_isConnected || _walletAddress == null) {
      _error = 'Wallet not connected';
      notifyListeners();
      return null;
    }

    try {
      if (_appKitModal?.session == null) {
        _error = 'No active session';
        notifyListeners();
        return null;
      }

      final result = await _appKitModal!.request(
        topic: _appKitModal!.session!.topic,
        chainId: 'eip155:1',
        request: SessionRequestParams(
          method: 'personal_sign',
          params: [
            '0x${utf8.encode(message).map((b) => b.toRadixString(16).padLeft(2, '0')).join('')}',
            _walletAddress,
          ],
        ),
      );

      return result as String?;
    } catch (e) {
      _error = 'Failed to request signature: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> _saveWalletAddress(String address) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('wallet_address', address);
    } catch (e) {
      _error = 'Failed to save wallet address: $e';
      notifyListeners();
    }
  }

  Future<void> _removeWalletAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('wallet_address');
    } catch (e) {
      _error = 'Failed to remove wallet address: $e';
      notifyListeners();
    }
  }

  Future<void> loadWellnessNFTs() async {
    if (!_isConnected || _walletAddress == null) return;

    try {
      _isLoadingNFTs = true;
      notifyListeners();

      final userAddress = EthereumAddress.fromHex(_walletAddress!);
      final getUserAchievements = _wellnessNFTContract.function(
        'getUserAchievements',
      );

      final result = await _client.call(
        contract: _wellnessNFTContract,
        function: getUserAchievements,
        params: [userAddress],
      );

      final tokenIds = (result[0] as List<dynamic>).cast<BigInt>();
      _wellnessNFTs = tokenIds.map((id) => id.toString()).toList();

      _isLoadingNFTs = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load wellness NFTs: $e';
      _isLoadingNFTs = false;
      notifyListeners();
    }
  }

  Future<void> loadWellnessTokens() async {
    if (!_isConnected || _walletAddress == null) return;

    try {
      _isLoadingTokens = true;
      notifyListeners();

      final userAddress = EthereumAddress.fromHex(_walletAddress!);
      final balanceOf = _wellnessTokenContract.function('balanceOf');

      final result = await _client.call(
        contract: _wellnessTokenContract,
        function: balanceOf,
        params: [userAddress],
      );

      _wellnessTokens = (result[0] as BigInt).toInt();
      _isLoadingTokens = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load wellness tokens: $e';
      _isLoadingTokens = false;
      notifyListeners();
    }
  }

  Future<void> completeAchievement(
    String id,
    String title,
    String feature,
    int difficulty,
    String description,
  ) async {
    if (!_isConnected || _walletAddress == null) {
      throw Exception('Wallet not connected');
    }

    try {
      final data = _wellnessSystemContract
          .function('completeAchievement')
          .encodeCall([id, title, feature, difficulty, description]);

      final tx = await _appKitModal!.request(
        topic: _appKitModal!.session!.topic,
        chainId: '11155111', // Sepolia testnet
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [
            {
              'from': _walletAddress,
              'to': wellnessSystemAddress,
              'data': data,
              'value': '0x0',
            },
          ],
        ),
      );

      if (tx == null) {
        throw Exception('Transaction failed');
      }

      await Future.wait([loadWellnessTokens(), loadWellnessNFTs()]);
    } catch (e) {
      _error = 'Failed to complete achievement: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> awardTokens(int amount) async {
    if (!_isConnected || _walletAddress == null) {
      throw Exception('Wallet not connected');
    }

    try {
      final mintFunction = _wellnessTokenContract.function('mint');
      final data = mintFunction.encodeCall([
        EthereumAddress.fromHex(_walletAddress!),
        BigInt.from(amount),
      ]);

      final tx = await _appKitModal!.request(
        topic: _appKitModal!.session!.topic,
        chainId: '11155111', // Sepolia testnet
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [
            {
              'from': _walletAddress,
              'to': wellnessTokenAddress,
              'data': data,
              'value': '0x0',
            },
          ],
        ),
      );

      if (tx == null) {
        throw Exception('Transaction failed');
      }

      await loadWellnessTokens();
    } catch (e) {
      _error = 'Failed to award tokens: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> mintAchievementNFT(
    String achievementId,
    String title,
    String description,
    String category,
    int difficulty,
    String imageUri,
  ) async {
    if (!_isConnected || _walletAddress == null) {
      throw Exception('Wallet not connected');
    }

    try {
      final mintFunction = _wellnessNFTContract.function('mintAchievement');
      final data = mintFunction.encodeCall([
        EthereumAddress.fromHex(_walletAddress!),
        title,
        description,
        category,
        BigInt.from(difficulty),
        imageUri,
      ]);

      final tx = await _appKitModal!.request(
        topic: _appKitModal!.session!.topic,
        chainId: '11155111', // Sepolia testnet
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [
            {
              'from': _walletAddress,
              'to': wellnessNFTAddress,
              'data': data,
              'value': '0x0',
            },
          ],
        ),
      );

      if (tx == null) {
        throw Exception('Transaction failed');
      }

      await loadWellnessNFTs();
    } catch (e) {
      _error = 'Failed to mint achievement NFT: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _saveWalletAddressToFirebase(String address) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'walletAddress': address,
            'walletConnectedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      debugPrint('Wallet address saved to Firebase for user: ${user.uid}');
    } catch (e) {
      _error = 'Failed to save wallet address to Firebase: $e';
      debugPrint('Error saving wallet address to Firebase: $e');
      notifyListeners();
    }
  }

  Future<String?> _loadWalletAddressFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      return doc.data()?['walletAddress'] as String?;
    } catch (e) {
      _error = 'Failed to load wallet address from Firebase: $e';
      debugPrint('Error loading wallet address from Firebase: $e');
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    _appKitModal?.dispose();
    super.dispose();
  }
}
