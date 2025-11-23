import 'package:equatable/equatable.dart';

/// Represents a cryptocurrency wallet.
class Wallet extends Equatable {
  final String id;
  final String name;
  final String address;
  final String publicKey;
  final String encryptedPrivateKey;
  final String mnemonic;
  final WalletType type;
  final DateTime createdAt;
  final bool isBackedUp;

  const Wallet({
    required this.id,
    required this.name,
    required this.address,
    required this.publicKey,
    required this.encryptedPrivateKey,
    required this.mnemonic,
    required this.type,
    required this.createdAt,
    this.isBackedUp = false,
  });

  @override
  List<Object?> get props => [id, address];

  Wallet copyWith({
    String? name,
    bool? isBackedUp,
  }) {
    return Wallet(
      id: id,
      name: name ?? this.name,
      address: address,
      publicKey: publicKey,
      encryptedPrivateKey: encryptedPrivateKey,
      mnemonic: mnemonic,
      type: type,
      createdAt: createdAt,
      isBackedUp: isBackedUp ?? this.isBackedUp,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'publicKey': publicKey,
        'encryptedPrivateKey': encryptedPrivateKey,
        'mnemonic': mnemonic,
        'type': type.name,
        'createdAt': createdAt.toIso8601String(),
        'isBackedUp': isBackedUp,
      };

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        id: json['id'],
        name: json['name'],
        address: json['address'],
        publicKey: json['publicKey'],
        encryptedPrivateKey: json['encryptedPrivateKey'],
        mnemonic: json['mnemonic'],
        type: WalletType.values.byName(json['type']),
        createdAt: DateTime.parse(json['createdAt']),
        isBackedUp: json['isBackedUp'] ?? false,
      );
}

enum WalletType {
  bitcoin,
  ethereum,
  educational,
}

/// Represents a cryptocurrency asset/token.
class CryptoAsset extends Equatable {
  final String symbol;
  final String name;
  final double balance;
  final double priceUsd;
  final double change24h;
  final String? iconUrl;

  const CryptoAsset({
    required this.symbol,
    required this.name,
    required this.balance,
    required this.priceUsd,
    required this.change24h,
    this.iconUrl,
  });

  double get valueUsd => balance * priceUsd;

  @override
  List<Object?> get props => [symbol, balance, priceUsd];

  CryptoAsset copyWith({
    double? balance,
    double? priceUsd,
    double? change24h,
  }) {
    return CryptoAsset(
      symbol: symbol,
      name: name,
      balance: balance ?? this.balance,
      priceUsd: priceUsd ?? this.priceUsd,
      change24h: change24h ?? this.change24h,
      iconUrl: iconUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'balance': balance,
        'priceUsd': priceUsd,
        'change24h': change24h,
        'iconUrl': iconUrl,
      };

  factory CryptoAsset.fromJson(Map<String, dynamic> json) => CryptoAsset(
        symbol: json['symbol'],
        name: json['name'],
        balance: (json['balance'] as num).toDouble(),
        priceUsd: (json['priceUsd'] as num).toDouble(),
        change24h: (json['change24h'] as num).toDouble(),
        iconUrl: json['iconUrl'],
      );
}

/// Represents a transaction record.
class TransactionRecord extends Equatable {
  final String id;
  final String hash;
  final String fromAddress;
  final String toAddress;
  final double amount;
  final String symbol;
  final double? feeAmount;
  final TransactionStatus status;
  final TransactionType type;
  final DateTime timestamp;
  final int? confirmations;
  final String? memo;

  const TransactionRecord({
    required this.id,
    required this.hash,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.symbol,
    this.feeAmount,
    required this.status,
    required this.type,
    required this.timestamp,
    this.confirmations,
    this.memo,
  });

  @override
  List<Object?> get props => [id, hash];

  Map<String, dynamic> toJson() => {
        'id': id,
        'hash': hash,
        'fromAddress': fromAddress,
        'toAddress': toAddress,
        'amount': amount,
        'symbol': symbol,
        'feeAmount': feeAmount,
        'status': status.name,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'confirmations': confirmations,
        'memo': memo,
      };

  factory TransactionRecord.fromJson(Map<String, dynamic> json) =>
      TransactionRecord(
        id: json['id'],
        hash: json['hash'],
        fromAddress: json['fromAddress'],
        toAddress: json['toAddress'],
        amount: (json['amount'] as num).toDouble(),
        symbol: json['symbol'],
        feeAmount: json['feeAmount'] != null
            ? (json['feeAmount'] as num).toDouble()
            : null,
        status: TransactionStatus.values.byName(json['status']),
        type: TransactionType.values.byName(json['type']),
        timestamp: DateTime.parse(json['timestamp']),
        confirmations: json['confirmations'],
        memo: json['memo'],
      );
}

enum TransactionStatus {
  pending,
  confirmed,
  failed,
}

enum TransactionType {
  send,
  receive,
  swap,
}

/// Network configuration for different blockchains.
class NetworkConfig {
  final String name;
  final String symbol;
  final String chainId;
  final String rpcUrl;
  final String explorerUrl;
  final bool isTestnet;

  const NetworkConfig({
    required this.name,
    required this.symbol,
    required this.chainId,
    required this.rpcUrl,
    required this.explorerUrl,
    this.isTestnet = false,
  });

  static const bitcoin = NetworkConfig(
    name: 'Bitcoin',
    symbol: 'BTC',
    chainId: 'bitcoin-mainnet',
    rpcUrl: 'https://bitcoin.example.com',
    explorerUrl: 'https://blockstream.info',
  );

  static const ethereum = NetworkConfig(
    name: 'Ethereum',
    symbol: 'ETH',
    chainId: '1',
    rpcUrl: 'https://ethereum.example.com',
    explorerUrl: 'https://etherscan.io',
  );

  static const ethereumSepolia = NetworkConfig(
    name: 'Ethereum Sepolia',
    symbol: 'ETH',
    chainId: '11155111',
    rpcUrl: 'https://sepolia.example.com',
    explorerUrl: 'https://sepolia.etherscan.io',
    isTestnet: true,
  );

  static const educationalChain = NetworkConfig(
    name: 'Educational Chain',
    symbol: 'EDU',
    chainId: 'edu-local',
    rpcUrl: 'local',
    explorerUrl: 'local',
    isTestnet: true,
  );
}
