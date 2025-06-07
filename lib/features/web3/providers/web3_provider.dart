import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Web3Provider with ChangeNotifier {
  ReownAppKitModal? _appKitModal;
  String? _walletAddress;
  bool _isConnecting = false;
  bool _isConnected = false;
  String? _error;

  String? get walletAddress => _walletAddress;
  bool get isConnecting => _isConnecting;
  bool get isConnected => _isConnected;
  String? get error => _error;

  Future<void> initialize(BuildContext context) async {
    try {
      _appKitModal = ReownAppKitModal(
        context: context,
        projectId:
            '58c3eec119930a1be0c1ba6911349422', // Replace with your WalletConnect Project ID
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
        featuredWalletIds: {
          'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96', // Metamask
          'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa', // Coinbase
          '1ae92b26df02f0abca6304df07debccd18262fdf5fe82daa81593582dac9a369', // Rainbow
        },
      );

      // Listen to connection events
      _appKitModal?.onModalConnect.subscribe((event) {
        if (event?.session != null) {
          _walletAddress = event!.session.getAddress('eip155');
          _isConnected = true;
          _saveWalletAddress(_walletAddress!);
          notifyListeners();
        }
      });

      _appKitModal?.onModalDisconnect.subscribe((event) {
        _walletAddress = null;
        _isConnected = false;
        _removeWalletAddress();
        notifyListeners();
      });

      await _appKitModal!.init();

      final prefs = await SharedPreferences.getInstance();
      _walletAddress = prefs.getString('wallet_address');
      _isConnected = _walletAddress != null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize: $e';
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

      await _appKitModal!.openModalView(ReownAppKitModalMainWalletsPage());
    } catch (e) {
      _error = 'Failed to connect wallet: $e';
      _isConnected = false;
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

  @override
  void dispose() {
    _appKitModal?.dispose();
    super.dispose();
  }
}
