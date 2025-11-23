import 'package:flutter/foundation.dart';
import '../core/blockchain.dart';
import '../core/crypto_utils.dart';

/// Provider for blockchain simulation and learning.
class BlockchainProvider extends ChangeNotifier {
  Blockchain _blockchain = Blockchain(difficulty: 2);
  bool _isMining = false;
  String? _lastMinedBlockHash;
  int _miningAttempts = 0;
  String _minerAddress = 'EDU_MINER_001';

  // Hashing demo state
  String _hashInput = '';
  String _hashOutput = '';

  // Signing demo state
  Map<String, String>? _demoKeyPair;
  String _signatureMessage = '';
  Map<String, String>? _signature;
  bool _signatureValid = false;

  Blockchain get blockchain => _blockchain;
  List<Block> get chain => _blockchain.chain;
  bool get isMining => _isMining;
  String? get lastMinedBlockHash => _lastMinedBlockHash;
  int get miningAttempts => _miningAttempts;
  String get minerAddress => _minerAddress;

  String get hashInput => _hashInput;
  String get hashOutput => _hashOutput;

  Map<String, String>? get demoKeyPair => _demoKeyPair;
  String get signatureMessage => _signatureMessage;
  Map<String, String>? get signature => _signature;
  bool get signatureValid => _signatureValid;

  BlockchainProvider() {
    _initializeDemo();
  }

  void _initializeDemo() {
    // Generate demo key pair
    _demoKeyPair = CryptoUtils.generateKeyPair();

    // Add some initial transactions and mine a block
    _addSampleTransactions();
  }

  void _addSampleTransactions() {
    final tx1 = Transaction(
      id: Transaction.generateId('Alice', 'Bob', 10.0, DateTime.now()),
      fromAddress: 'Alice',
      toAddress: 'Bob',
      amount: 10.0,
      timestamp: DateTime.now(),
    );

    final tx2 = Transaction(
      id: Transaction.generateId('Bob', 'Charlie', 5.0, DateTime.now()),
      fromAddress: 'Bob',
      toAddress: 'Charlie',
      amount: 5.0,
      timestamp: DateTime.now(),
    );

    _blockchain.addTransaction(tx1);
    _blockchain.addTransaction(tx2);
  }

  /// Add a transaction to pending
  void addTransaction({
    required String from,
    required String to,
    required double amount,
  }) {
    final transaction = Transaction(
      id: Transaction.generateId(from, to, amount, DateTime.now()),
      fromAddress: from,
      toAddress: to,
      amount: amount,
      timestamp: DateTime.now(),
    );

    _blockchain.addTransaction(transaction);
    notifyListeners();
  }

  /// Mine pending transactions
  Future<void> minePendingTransactions() async {
    if (_isMining) return;
    if (_blockchain.pendingTransactions.isEmpty) {
      _addSampleTransactions();
    }

    _isMining = true;
    _miningAttempts = 0;
    notifyListeners();

    // Simulate mining with updates
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      // Create mining simulation
      final previousHash = _blockchain.latestBlock.hash;
      final transactions = List<Transaction>.from(_blockchain.pendingTransactions);

      // Add mining reward
      final rewardTx = Transaction(
        id: Transaction.generateId('SYSTEM', _minerAddress, _blockchain.miningReward, DateTime.now()),
        fromAddress: 'SYSTEM',
        toAddress: _minerAddress,
        amount: _blockchain.miningReward,
        timestamp: DateTime.now(),
      );
      transactions.add(rewardTx);

      // Simulate mining attempts
      int nonce = 0;
      String hash;
      final target = '0' * _blockchain.difficulty;
      final blockData = '${_blockchain.chain.length}${DateTime.now()}${transactions.map((t) => t.toJson()).join()}$previousHash';

      do {
        nonce++;
        _miningAttempts = nonce;

        // Update UI periodically
        if (nonce % 100 == 0) {
          notifyListeners();
          await Future.delayed(const Duration(milliseconds: 10));
        }

        hash = CryptoUtils.sha256Hash('$blockData$nonce');
      } while (!hash.startsWith(target) && nonce < 100000);

      // Create the mined block
      final newBlock = Block(
        index: _blockchain.chain.length,
        timestamp: DateTime.now(),
        transactions: transactions,
        previousHash: previousHash,
        nonce: nonce,
        hash: hash,
      );

      _blockchain.chain.add(newBlock);
      _blockchain.pendingTransactions.clear();
      _lastMinedBlockHash = hash;
    } finally {
      _isMining = false;
      notifyListeners();
    }
  }

  /// Reset the blockchain
  void resetBlockchain() {
    _blockchain = Blockchain(difficulty: 2);
    _lastMinedBlockHash = null;
    _miningAttempts = 0;
    notifyListeners();
  }

  /// Set mining difficulty
  void setDifficulty(int difficulty) {
    _blockchain = Blockchain(
      chain: _blockchain.chain,
      difficulty: difficulty,
      pendingTransactions: _blockchain.pendingTransactions,
    );
    notifyListeners();
  }

  /// Validate the blockchain
  bool validateChain() {
    return _blockchain.isValid();
  }

  /// Tamper with a block (for demonstration)
  void tamperWithBlock(int index) {
    if (index > 0 && index < _blockchain.chain.length) {
      final block = _blockchain.chain[index];
      if (block.transactions.isNotEmpty) {
        // Modify transaction amount
        final tamperedTx = Transaction(
          id: block.transactions.first.id,
          fromAddress: block.transactions.first.fromAddress,
          toAddress: block.transactions.first.toAddress,
          amount: block.transactions.first.amount + 1000, // Tampered!
          timestamp: block.transactions.first.timestamp,
        );

        final tamperedBlock = Block(
          index: block.index,
          timestamp: block.timestamp,
          transactions: [tamperedTx, ...block.transactions.skip(1)],
          previousHash: block.previousHash,
          nonce: block.nonce,
          hash: block.hash, // Hash is now invalid!
        );

        _blockchain.chain[index] = tamperedBlock;
        notifyListeners();
      }
    }
  }

  // Hashing Demo Methods

  /// Update hash demo input
  void updateHashInput(String input) {
    _hashInput = input;
    if (input.isNotEmpty) {
      _hashOutput = CryptoUtils.sha256Hash(input);
    } else {
      _hashOutput = '';
    }
    notifyListeners();
  }

  /// Get double SHA-256 hash
  String getDoubleSha256(String input) {
    return CryptoUtils.doubleSha256(input);
  }

  // Digital Signature Demo Methods

  /// Generate new key pair for demo
  void generateNewKeyPair() {
    _demoKeyPair = CryptoUtils.generateKeyPair();
    _signature = null;
    _signatureValid = false;
    notifyListeners();
  }

  /// Sign a message
  void signMessage(String message) {
    if (_demoKeyPair == null || message.isEmpty) return;

    _signatureMessage = message;
    _signature = CryptoUtils.signMessage(message, _demoKeyPair!['privateKey']!);
    _signatureValid = true;
    notifyListeners();
  }

  /// Verify a signature
  bool verifySignature() {
    if (_demoKeyPair == null || _signature == null || _signatureMessage.isEmpty) {
      return false;
    }

    _signatureValid = CryptoUtils.verifySignature(
      _signatureMessage,
      _demoKeyPair!['publicKey']!,
      _signature!['r']!,
      _signature!['s']!,
    );
    notifyListeners();
    return _signatureValid;
  }

  /// Tamper with signed message to show signature becomes invalid
  void tamperMessage() {
    if (_signatureMessage.isNotEmpty) {
      _signatureMessage = '${_signatureMessage}_tampered';
      _signatureValid = verifySignature();
      notifyListeners();
    }
  }

  /// Get educational content
  Map<String, String> getCryptoEducation() => CryptoEducation.concepts;
  Map<String, String> getBlockchainEducation() => BlockchainEducation.concepts;
}
