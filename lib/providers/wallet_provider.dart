import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallet.dart';
import '../services/wallet_service.dart';
import '../services/price_service.dart';

/// Provider for wallet state management.
class WalletProvider extends ChangeNotifier {
  final WalletService _walletService = WalletService();
  final PriceService _priceService = PriceService();

  Wallet? _currentWallet;
  List<CryptoAsset> _portfolio = [];
  List<TransactionRecord> _transactions = [];
  bool _isLoading = false;
  String? _error;
  Map<String, CryptoAsset> _marketPrices = {};

  Wallet? get currentWallet => _currentWallet;
  List<CryptoAsset> get portfolio => _portfolio;
  List<TransactionRecord> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, CryptoAsset> get marketPrices => _marketPrices;
  bool get hasWallet => _currentWallet != null;

  double get totalBalance {
    return _portfolio.fold(0, (sum, asset) => sum + asset.valueUsd);
  }

  WalletProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadWallet();
    _startPriceUpdates();
  }

  void _startPriceUpdates() {
    _priceService.startPriceUpdates();
    _priceService.priceStream.listen((prices) {
      _marketPrices = prices;
      _updatePortfolioPrices();
      notifyListeners();
    });
    _marketPrices = _priceService.getAllAssets();
  }

  void _updatePortfolioPrices() {
    _portfolio = _portfolio.map((asset) {
      final currentPrice = _marketPrices[asset.symbol];
      if (currentPrice != null) {
        return asset.copyWith(
          priceUsd: currentPrice.priceUsd,
          change24h: currentPrice.change24h,
        );
      }
      return asset;
    }).toList();
  }

  /// Load wallet from storage
  Future<void> loadWallet() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final walletJson = prefs.getString('wallet');

      if (walletJson != null) {
        _currentWallet = Wallet.fromJson(jsonDecode(walletJson));
        _loadPortfolioAndTransactions();
      }
    } catch (e) {
      _error = 'Failed to load wallet: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadPortfolioAndTransactions() {
    if (_currentWallet != null) {
      _portfolio = _priceService.getSimulatedPortfolio();
      _transactions = _priceService.getSimulatedTransactions(_currentWallet!.address);
    }
  }

  /// Create a new wallet
  Future<void> createWallet({
    required String name,
    WalletType type = WalletType.educational,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final wallet = await _walletService.createWallet(
        name: name,
        type: type,
      );

      _currentWallet = wallet;
      await _saveWallet();
      _loadPortfolioAndTransactions();
    } catch (e) {
      _error = 'Failed to create wallet: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Import wallet from mnemonic
  Future<void> importWallet({
    required String mnemonic,
    required String name,
    WalletType type = WalletType.educational,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!_walletService.validateMnemonic(mnemonic)) {
        throw Exception('Invalid mnemonic phrase');
      }

      final wallet = await _walletService.recoverWallet(
        mnemonic: mnemonic,
        name: name,
        type: type,
      );

      _currentWallet = wallet;
      await _saveWallet();
      _loadPortfolioAndTransactions();
    } catch (e) {
      _error = 'Failed to import wallet: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save wallet to storage
  Future<void> _saveWallet() async {
    if (_currentWallet != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('wallet', jsonEncode(_currentWallet!.toJson()));
    }
  }

  /// Mark wallet as backed up
  Future<void> markAsBackedUp() async {
    if (_currentWallet != null) {
      _currentWallet = _currentWallet!.copyWith(isBackedUp: true);
      await _saveWallet();
      notifyListeners();
    }
  }

  /// Delete wallet
  Future<void> deleteWallet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wallet');
    _currentWallet = null;
    _portfolio = [];
    _transactions = [];
    notifyListeners();
  }

  /// Generate new mnemonic (for preview)
  String generateMnemonic() {
    return _walletService.generateMnemonic();
  }

  /// Validate mnemonic
  bool validateMnemonic(String mnemonic) {
    return _walletService.validateMnemonic(mnemonic);
  }

  @override
  void dispose() {
    _priceService.dispose();
    super.dispose();
  }
}
