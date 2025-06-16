import 'dart:convert';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../../web3/providers/web3_provider.dart';

class NFTService {
  final Web3Provider _web3Provider;
  late final DeployedContract _contract;
  static const String CONTRACT_ADDRESS =
      '0x90D85445d55CA4F35B592355D90ecff6AC1F9740';
  static const String CONTRACT_ABI = '''[
    {"inputs":[],"stateMutability":"nonpayable","type":"constructor"},
    {"inputs":[{"name":"user","type":"address"}],"name":"getUserAchievements","outputs":[{"name":"","type":"uint256[]"}],"stateMutability":"view","type":"function"},
    {"inputs":[{"name":"achievementId","type":"uint256"}],"name":"mintAchievement","outputs":[],"stateMutability":"nonpayable","type":"function"}
  ]''';
  static const String PINATA_API_KEY = '178a4d2793e59f46d68e';
  static const String PINATA_SECRET_KEY =
      'fdb96d087e03067cd7c8d4d447b9d09f30e1902779b1727cb327c7872b3ea775';
  static const String PINATA_GATEWAY = 'https://gateway.pinata.cloud/ipfs/';

  // Achievement ID mapping
  static const Map<String, int> achievementIdMap = {
    'first_breathe': 1,
    'breathing_streak_3': 2,
    'breathing_master': 3,
    'breathing_expert': 4,
    'daily_streak': 5,
    'long_session': 6,
    'soundscape_explorer': 7,
  };

  NFTService(this._web3Provider) {
    _contract = _getContract();
  }

  DeployedContract _getContract() {
    try {
      return DeployedContract(
        ContractAbi.fromJson(CONTRACT_ABI, 'AchievementNFT'),
        EthereumAddress.fromHex(CONTRACT_ADDRESS),
      );
    } catch (e) {
      print('Error initializing contract: $e');
      rethrow;
    }
  }

  Future<List<BigInt>> getUserAchievements() async {
    try {
      if (!_web3Provider.isConnected) {
        throw Exception('Wallet not connected');
      }

      final address = _web3Provider.walletAddress;
      if (address == null) {
        throw Exception('No wallet address available');
      }

      // Add retry logic for blockchain calls
      int retries = 3;
      while (retries > 0) {
        try {
          final userAddress = EthereumAddress.fromHex(address);
          final getUserAchievements = _contract.function('getUserAchievements');

          final result = await _web3Provider.client.call(
            contract: _contract,
            function: getUserAchievements,
            params: [userAddress],
          );

          return (result[0] as List<dynamic>).cast<BigInt>();
        } catch (e) {
          retries--;
          if (retries == 0) rethrow;
          await Future.delayed(Duration(seconds: 1));
        }
      }
      throw Exception('Failed to get user achievements after retries');
    } catch (e) {
      print('Error getting user achievements: $e');
      return [];
    }
  }

  Future<String> mintBadge(String achievementId) async {
    try {
      if (!_web3Provider.isConnected) {
        throw Exception('Wallet not connected');
      }

      final numericId = achievementIdMap[achievementId];
      if (numericId == null) {
        throw Exception('Invalid achievement ID');
      }

      // Add retry logic for minting
      int retries = 3;
      while (retries > 0) {
        try {
          final mintFunction = _contract.function('mintAchievement');
          final data = mintFunction.encodeCall([BigInt.from(numericId)]);

          final txHash = await _web3Provider.sendTransaction(
            to: EthereumAddress.fromHex(CONTRACT_ADDRESS),
            data: data,
          );

          if (txHash == null) {
            throw Exception('Transaction failed');
          }

          return txHash;
        } catch (e) {
          retries--;
          if (retries == 0) rethrow;
          await Future.delayed(Duration(seconds: 1));
        }
      }
      throw Exception('Failed to mint badge after retries');
    } catch (e) {
      print('Error minting badge: $e');
      rethrow;
    }
  }

  Future<String> _createAndUploadMetadata(String achievementId) async {
    // Create metadata JSON
    final metadata = {
      'name': 'Achievement Badge #${_getNumericAchievementId(achievementId)}',
      'description': 'Awarded for completing achievement: $achievementId',
      'image':
          'ipfs://Qmbafkreigb3yn5t4dpivd53dypd7w5cknensfjrcibbthbopzg2afkfpr4s4',
      'attributes': [
        {'trait_type': 'Achievement ID', 'value': achievementId},
        {'trait_type': 'Type', 'value': 'Badge'},
      ],
    };

    // Upload metadata to IPFS via Pinata
    final response = await http.post(
      Uri.parse('https://api.pinata.cloud/pinning/pinJSONToIPFS'),
      headers: {
        'Content-Type': 'application/json',
        'pinata_api_key': '178a4d2793e59f46d68e',
        'pinata_secret_api_key':
            'fdb96d087e03067cd7c8d4d447b9d09f30e1902779b1727cb327c7872b3ea775',
      },
      body: json.encode(metadata),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return 'ipfs://${data['IpfsHash']}';
    } else {
      throw Exception('Failed to upload metadata to IPFS: ${response.body}');
    }
  }

  static String? getIpfsImageUrl(String? ipfsUri) {
    if (ipfsUri == null || ipfsUri.isEmpty) return null;

    try {
      // Handle both IPFS and HTTP URIs
      if (ipfsUri.startsWith('ipfs://')) {
        final hash = ipfsUri.replaceFirst('ipfs://', '');
        return 'https://ipfs.io/ipfs/$hash';
      } else if (ipfsUri.startsWith('http')) {
        return ipfsUri;
      }
      return null;
    } catch (e) {
      print('Error parsing IPFS URL: $e');
      return null;
    }
  }

  // Helper method to convert string achievement ID to numeric value
  int _getNumericAchievementId(String achievementId) {
    final numericId = achievementIdMap[achievementId];
    if (numericId == null) {
      throw Exception('Invalid achievement ID: $achievementId');
    }
    return numericId;
  }
}
