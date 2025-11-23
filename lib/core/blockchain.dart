import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Represents a single block in the blockchain.
/// This is an educational implementation showing how blocks work.
class Block {
  final int index;
  final DateTime timestamp;
  final List<Transaction> transactions;
  final String previousHash;
  final int nonce;
  final String hash;

  Block({
    required this.index,
    required this.timestamp,
    required this.transactions,
    required this.previousHash,
    required this.nonce,
    required this.hash,
  });

  /// Creates a block and calculates its hash.
  factory Block.create({
    required int index,
    required List<Transaction> transactions,
    required String previousHash,
    int nonce = 0,
  }) {
    final timestamp = DateTime.now();
    final hash = _calculateHash(index, timestamp, transactions, previousHash, nonce);
    return Block(
      index: index,
      timestamp: timestamp,
      transactions: transactions,
      previousHash: previousHash,
      nonce: nonce,
      hash: hash,
    );
  }

  /// Creates the genesis block (first block in the chain).
  factory Block.genesis() {
    return Block.create(
      index: 0,
      transactions: [],
      previousHash: '0' * 64,
    );
  }

  /// Calculates the hash of a block.
  static String _calculateHash(
    int index,
    DateTime timestamp,
    List<Transaction> transactions,
    String previousHash,
    int nonce,
  ) {
    final transactionData = transactions.map((t) => t.toJson()).join();
    final blockData = '$index$timestamp$transactionData$previousHash$nonce';
    return sha256.convert(utf8.encode(blockData)).toString();
  }

  /// Recalculates the hash for verification.
  String recalculateHash() {
    return _calculateHash(index, timestamp, transactions, previousHash, nonce);
  }

  /// Mines a block with proof of work.
  /// This demonstrates how mining works - finding a hash with leading zeros.
  static Block mine({
    required int index,
    required List<Transaction> transactions,
    required String previousHash,
    required int difficulty,
  }) {
    final timestamp = DateTime.now();
    final target = '0' * difficulty;
    int nonce = 0;
    String hash;

    do {
      nonce++;
      hash = _calculateHash(index, timestamp, transactions, previousHash, nonce);
    } while (!hash.startsWith(target));

    return Block(
      index: index,
      timestamp: timestamp,
      transactions: transactions,
      previousHash: previousHash,
      nonce: nonce,
      hash: hash,
    );
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'timestamp': timestamp.toIso8601String(),
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'previousHash': previousHash,
        'nonce': nonce,
        'hash': hash,
      };

  factory Block.fromJson(Map<String, dynamic> json) => Block(
        index: json['index'],
        timestamp: DateTime.parse(json['timestamp']),
        transactions: (json['transactions'] as List)
            .map((t) => Transaction.fromJson(t))
            .toList(),
        previousHash: json['previousHash'],
        nonce: json['nonce'],
        hash: json['hash'],
      );
}

/// Represents a transaction in the blockchain.
class Transaction {
  final String id;
  final String fromAddress;
  final String toAddress;
  final double amount;
  final DateTime timestamp;
  final String? signature;

  Transaction({
    required this.id,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.timestamp,
    this.signature,
  });

  /// Creates a unique transaction ID.
  static String generateId(String from, String to, double amount, DateTime time) {
    final data = '$from$to$amount${time.toIso8601String()}';
    return sha256.convert(utf8.encode(data)).toString().substring(0, 16);
  }

  /// Creates the data string that gets signed.
  String getSignatureData() {
    return '$fromAddress$toAddress$amount${timestamp.toIso8601String()}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromAddress': fromAddress,
        'toAddress': toAddress,
        'amount': amount,
        'timestamp': timestamp.toIso8601String(),
        'signature': signature,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        fromAddress: json['fromAddress'],
        toAddress: json['toAddress'],
        amount: json['amount'],
        timestamp: DateTime.parse(json['timestamp']),
        signature: json['signature'],
      );

  Transaction copyWith({String? signature}) => Transaction(
        id: id,
        fromAddress: fromAddress,
        toAddress: toAddress,
        amount: amount,
        timestamp: timestamp,
        signature: signature ?? this.signature,
      );
}

/// A simple blockchain implementation for educational purposes.
class Blockchain {
  final List<Block> chain;
  final int difficulty;
  final List<Transaction> pendingTransactions;
  final double miningReward;

  Blockchain({
    List<Block>? chain,
    this.difficulty = 2,
    List<Transaction>? pendingTransactions,
    this.miningReward = 50.0,
  })  : chain = chain ?? [Block.genesis()],
        pendingTransactions = pendingTransactions ?? [];

  /// Gets the latest block in the chain.
  Block get latestBlock => chain.last;

  /// Adds a transaction to pending transactions.
  void addTransaction(Transaction transaction) {
    if (transaction.fromAddress.isEmpty || transaction.toAddress.isEmpty) {
      throw Exception('Transaction must have from and to addresses');
    }
    pendingTransactions.add(transaction);
  }

  /// Mines pending transactions into a new block.
  Block minePendingTransactions(String minerAddress) {
    // Create mining reward transaction
    final rewardTx = Transaction(
      id: Transaction.generateId('SYSTEM', minerAddress, miningReward, DateTime.now()),
      fromAddress: 'SYSTEM',
      toAddress: minerAddress,
      amount: miningReward,
      timestamp: DateTime.now(),
    );

    final transactions = [...pendingTransactions, rewardTx];

    // Mine the block
    final newBlock = Block.mine(
      index: chain.length,
      transactions: transactions,
      previousHash: latestBlock.hash,
      difficulty: difficulty,
    );

    chain.add(newBlock);
    pendingTransactions.clear();

    return newBlock;
  }

  /// Gets the balance of an address.
  double getBalance(String address) {
    double balance = 0;

    for (final block in chain) {
      for (final transaction in block.transactions) {
        if (transaction.fromAddress == address) {
          balance -= transaction.amount;
        }
        if (transaction.toAddress == address) {
          balance += transaction.amount;
        }
      }
    }

    return balance;
  }

  /// Gets all transactions for an address.
  List<Transaction> getTransactionsForAddress(String address) {
    final transactions = <Transaction>[];

    for (final block in chain) {
      for (final transaction in block.transactions) {
        if (transaction.fromAddress == address ||
            transaction.toAddress == address) {
          transactions.add(transaction);
        }
      }
    }

    return transactions;
  }

  /// Validates the entire blockchain.
  bool isValid() {
    for (int i = 1; i < chain.length; i++) {
      final currentBlock = chain[i];
      final previousBlock = chain[i - 1];

      // Check if hash is correct
      if (currentBlock.hash != currentBlock.recalculateHash()) {
        return false;
      }

      // Check if previous hash matches
      if (currentBlock.previousHash != previousBlock.hash) {
        return false;
      }
    }
    return true;
  }

  Map<String, dynamic> toJson() => {
        'chain': chain.map((b) => b.toJson()).toList(),
        'difficulty': difficulty,
        'pendingTransactions':
            pendingTransactions.map((t) => t.toJson()).toList(),
        'miningReward': miningReward,
      };
}

/// Educational explanations about blockchain concepts.
class BlockchainEducation {
  static const Map<String, String> concepts = {
    'Blockchain': '''
A blockchain is a distributed, immutable ledger.

Key Components:
• Blocks: Containers of transaction data
• Chain: Blocks linked by cryptographic hashes
• Distributed: Copies exist on many computers
• Immutable: Past data cannot be changed

How it Works:
1. Transactions are broadcast to the network
2. Miners collect transactions into blocks
3. Miners compete to solve a puzzle (proof of work)
4. Winner broadcasts their block
5. Network verifies and adds block to chain
6. Process repeats continuously
''',
    'Blocks': '''
Blocks are the building units of a blockchain.

Block Contents:
• Index: Position in the chain
• Timestamp: When the block was created
• Transactions: List of transfers
• Previous Hash: Links to prior block
• Nonce: Number used for mining
• Hash: Unique fingerprint of this block

Why Blocks are Secure:
• Changing any data changes the hash
• Changed hash breaks link to next block
• Would need to redo all subsequent blocks
• More blocks = more security (confirmations)
''',
    'Mining': '''
Mining is the process of adding blocks to the blockchain.

Proof of Work:
1. Collect pending transactions
2. Create block header with previous hash
3. Try different nonce values
4. Calculate hash each time
5. Find hash with required leading zeros
6. Broadcast winning block to network

Why It Works:
• Finding valid hash requires many attempts
• Verifying is instant (just one hash)
• Difficulty adjusts to maintain block time
• Creates fair lottery for block rewards

Energy Cost = Security:
The computational work makes attacks expensive.
''',
    'Consensus': '''
Consensus mechanisms ensure network agreement.

Proof of Work (PoW):
• Miners compete to solve puzzles
• Most computational work wins
• Used by Bitcoin
• Secure but energy-intensive

Proof of Stake (PoS):
• Validators stake cryptocurrency
• Selection based on stake amount
• Used by Ethereum (after merge)
• More energy efficient

Other Mechanisms:
• Delegated PoS (DPoS)
• Proof of Authority (PoA)
• Proof of History (PoH)
''',
    'Double Spending': '''
Double spending is trying to spend the same coins twice.

The Problem:
• Digital data can be copied
• How to prevent copying money?
• Traditional solution: central authority

Blockchain Solution:
1. All transactions are public
2. Network verifies transaction order
3. First valid spend is accepted
4. Second attempt is rejected
5. Confirmations increase certainty

This is why you wait for confirmations!
''',
  };
}
