import 'dart:async';
import 'dart:math';
import '../models/wallet.dart';

/// Service for managing cryptocurrency prices.
/// Uses simulated data for educational purposes.
class PriceService {
  final _random = Random();
  final _priceController = StreamController<Map<String, CryptoAsset>>.broadcast();

  Stream<Map<String, CryptoAsset>> get priceStream => _priceController.stream;

  Timer? _updateTimer;

  /// Base prices for simulation
  final Map<String, double> _basePrices = {
    'BTC': 45000.0,
    'ETH': 2500.0,
    'SOL': 100.0,
    'ADA': 0.50,
    'DOT': 7.50,
    'AVAX': 35.0,
    'MATIC': 0.85,
    'LINK': 15.0,
    'UNI': 6.0,
    'ATOM': 9.0,
  };

  final Map<String, String> _cryptoNames = {
    'BTC': 'Bitcoin',
    'ETH': 'Ethereum',
    'SOL': 'Solana',
    'ADA': 'Cardano',
    'DOT': 'Polkadot',
    'AVAX': 'Avalanche',
    'MATIC': 'Polygon',
    'LINK': 'Chainlink',
    'UNI': 'Uniswap',
    'ATOM': 'Cosmos',
  };

  Map<String, double> _currentPrices = {};
  Map<String, double> _changes24h = {};

  PriceService() {
    _initializePrices();
  }

  void _initializePrices() {
    _currentPrices = Map.from(_basePrices);
    for (final symbol in _basePrices.keys) {
      _changes24h[symbol] = (_random.nextDouble() - 0.5) * 10; // -5% to +5%
    }
  }

  /// Start real-time price updates (simulated)
  void startPriceUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _updatePrices();
    });
    _emitPrices();
  }

  /// Stop price updates
  void stopPriceUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  void _updatePrices() {
    for (final symbol in _currentPrices.keys) {
      // Simulate small price fluctuations
      final changePercent = (_random.nextDouble() - 0.5) * 0.5; // -0.25% to +0.25%
      _currentPrices[symbol] = _currentPrices[symbol]! * (1 + changePercent / 100);

      // Update 24h change
      _changes24h[symbol] = _changes24h[symbol]! + (_random.nextDouble() - 0.5) * 0.2;
      _changes24h[symbol] = _changes24h[symbol]!.clamp(-15.0, 15.0);
    }
    _emitPrices();
  }

  void _emitPrices() {
    final assets = <String, CryptoAsset>{};
    for (final symbol in _currentPrices.keys) {
      assets[symbol] = CryptoAsset(
        symbol: symbol,
        name: _cryptoNames[symbol] ?? symbol,
        balance: 0,
        priceUsd: _currentPrices[symbol]!,
        change24h: _changes24h[symbol]!,
      );
    }
    _priceController.add(assets);
  }

  /// Get current price for a symbol
  double? getPrice(String symbol) {
    return _currentPrices[symbol.toUpperCase()];
  }

  /// Get all current prices
  Map<String, CryptoAsset> getAllAssets() {
    final assets = <String, CryptoAsset>{};
    for (final symbol in _currentPrices.keys) {
      assets[symbol] = CryptoAsset(
        symbol: symbol,
        name: _cryptoNames[symbol] ?? symbol,
        balance: 0,
        priceUsd: _currentPrices[symbol]!,
        change24h: _changes24h[symbol]!,
      );
    }
    return assets;
  }

  /// Get simulated portfolio with balances
  List<CryptoAsset> getSimulatedPortfolio() {
    return [
      CryptoAsset(
        symbol: 'BTC',
        name: 'Bitcoin',
        balance: 0.5,
        priceUsd: _currentPrices['BTC']!,
        change24h: _changes24h['BTC']!,
      ),
      CryptoAsset(
        symbol: 'ETH',
        name: 'Ethereum',
        balance: 5.0,
        priceUsd: _currentPrices['ETH']!,
        change24h: _changes24h['ETH']!,
      ),
      CryptoAsset(
        symbol: 'SOL',
        name: 'Solana',
        balance: 20.0,
        priceUsd: _currentPrices['SOL']!,
        change24h: _changes24h['SOL']!,
      ),
      CryptoAsset(
        symbol: 'ADA',
        name: 'Cardano',
        balance: 1000.0,
        priceUsd: _currentPrices['ADA']!,
        change24h: _changes24h['ADA']!,
      ),
    ];
  }

  /// Get simulated transaction history
  List<TransactionRecord> getSimulatedTransactions(String address) {
    final now = DateTime.now();
    return [
      TransactionRecord(
        id: '1',
        hash: '0x${_generateRandomHash()}',
        fromAddress: '0x742d35Cc6634C0532925a3b844Bc9e7595f...',
        toAddress: address,
        amount: 0.5,
        symbol: 'ETH',
        feeAmount: 0.002,
        status: TransactionStatus.confirmed,
        type: TransactionType.receive,
        timestamp: now.subtract(const Duration(hours: 2)),
        confirmations: 35,
      ),
      TransactionRecord(
        id: '2',
        hash: '0x${_generateRandomHash()}',
        fromAddress: address,
        toAddress: '0x8ba1f109551bD432803012645Ac136ddd64DBA72',
        amount: 100.0,
        symbol: 'ADA',
        feeAmount: 0.17,
        status: TransactionStatus.confirmed,
        type: TransactionType.send,
        timestamp: now.subtract(const Duration(days: 1)),
        confirmations: 1250,
      ),
      TransactionRecord(
        id: '3',
        hash: '0x${_generateRandomHash()}',
        fromAddress: 'Mining Reward',
        toAddress: address,
        amount: 0.001,
        symbol: 'BTC',
        status: TransactionStatus.confirmed,
        type: TransactionType.receive,
        timestamp: now.subtract(const Duration(days: 3)),
        confirmations: 450,
        memo: 'Mining pool payout',
      ),
      TransactionRecord(
        id: '4',
        hash: '0x${_generateRandomHash()}',
        fromAddress: address,
        toAddress: '0x1234...5678',
        amount: 0.1,
        symbol: 'ETH',
        feeAmount: 0.003,
        status: TransactionStatus.pending,
        type: TransactionType.send,
        timestamp: now.subtract(const Duration(minutes: 5)),
        confirmations: 0,
      ),
    ];
  }

  String _generateRandomHash() {
    const chars = '0123456789abcdef';
    return List.generate(64, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  void dispose() {
    _updateTimer?.cancel();
    _priceController.close();
  }
}
