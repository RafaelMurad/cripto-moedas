import 'dart:convert';
import 'package:bip39/bip39.dart' as bip39;
import 'package:uuid/uuid.dart';
import '../core/crypto_utils.dart';
import '../models/wallet.dart';

/// Service for managing cryptocurrency wallets.
/// Demonstrates HD wallet concepts and key management.
class WalletService {
  static const _uuid = Uuid();

  /// Generates a new BIP-39 mnemonic phrase.
  /// This is the human-readable backup for your wallet.
  ///
  /// Educational Note:
  /// - 12 words = 128 bits of entropy
  /// - 24 words = 256 bits of entropy
  /// - Each word is from a standardized list of 2048 words
  String generateMnemonic({int strength = 128}) {
    return bip39.generateMnemonic(strength: strength);
  }

  /// Validates a mnemonic phrase.
  bool validateMnemonic(String mnemonic) {
    return bip39.validateMnemonic(mnemonic);
  }

  /// Converts mnemonic to seed bytes.
  /// The seed is used to derive all keys in an HD wallet.
  ///
  /// Educational Note:
  /// - Mnemonic + optional passphrase → seed
  /// - Same mnemonic always produces same seed
  /// - Adding a passphrase creates different seed (plausible deniability)
  List<int> mnemonicToSeed(String mnemonic, {String passphrase = ''}) {
    return bip39.mnemonicToSeed(mnemonic, passphrase: passphrase);
  }

  /// Creates a new wallet from a mnemonic phrase.
  Future<Wallet> createWallet({
    required String name,
    String? mnemonic,
    WalletType type = WalletType.educational,
  }) async {
    // Generate or use provided mnemonic
    final walletMnemonic = mnemonic ?? generateMnemonic();

    if (!validateMnemonic(walletMnemonic)) {
      throw Exception('Invalid mnemonic phrase');
    }

    // Generate key pair from mnemonic
    // In production, this would use proper BIP-32 derivation
    final seed = mnemonicToSeed(walletMnemonic);
    final seedHex = seed.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    // For educational purposes, derive keys from seed hash
    final privateKey = CryptoUtils.sha256Hash(seedHex);
    final keyPair = CryptoUtils.generateKeyPair();

    // Generate address based on wallet type
    String address;
    switch (type) {
      case WalletType.bitcoin:
        address = CryptoUtils.publicKeyToAddress(keyPair['publicKey']!);
        break;
      case WalletType.ethereum:
        address = CryptoUtils.publicKeyToEthereumAddress(keyPair['publicKey']!);
        break;
      case WalletType.educational:
        address = 'EDU${CryptoUtils.sha256Hash(keyPair['publicKey']!).substring(0, 38)}';
        break;
    }

    return Wallet(
      id: _uuid.v4(),
      name: name,
      address: address,
      publicKey: keyPair['publicKey']!,
      encryptedPrivateKey: privateKey, // In production, this would be encrypted
      mnemonic: walletMnemonic,
      type: type,
      createdAt: DateTime.now(),
    );
  }

  /// Recovers a wallet from a mnemonic phrase.
  Future<Wallet> recoverWallet({
    required String mnemonic,
    required String name,
    WalletType type = WalletType.educational,
  }) async {
    if (!validateMnemonic(mnemonic)) {
      throw Exception('Invalid mnemonic phrase');
    }

    return createWallet(
      name: name,
      mnemonic: mnemonic,
      type: type,
    );
  }

  /// Signs a message with the wallet's private key.
  Map<String, String> signMessage(String message, String privateKey) {
    return CryptoUtils.signMessage(message, privateKey);
  }

  /// Verifies a signed message.
  bool verifyMessage(
    String message,
    String publicKey,
    String rHex,
    String sHex,
  ) {
    return CryptoUtils.verifySignature(message, publicKey, rHex, sHex);
  }
}

/// Educational information about wallets.
class WalletEducation {
  static const Map<String, String> concepts = {
    'HD Wallets': '''
HD (Hierarchical Deterministic) Wallets generate all keys from a single seed.

Benefits:
• One backup (mnemonic) protects all addresses
• Can create unlimited addresses
• Organized key hierarchy
• Privacy: use new address for each transaction

BIP Standards:
• BIP-32: HD wallet structure
• BIP-39: Mnemonic word lists
• BIP-44: Multi-account hierarchy

Derivation Path Example:
m/44'/60'/0'/0/0
│  │   │   │  └─ Address index
│  │   │   └──── Change (0=external, 1=internal)
│  │   └─────── Account
│  └────────── Coin type (60=ETH, 0=BTC)
└───────────── Purpose (44=BIP44)
''',
    'Mnemonic Phrases': '''
Mnemonic phrases (seed phrases) are human-readable wallet backups.

How They Work:
1. Generate random entropy (128 or 256 bits)
2. Add checksum (hash of entropy)
3. Split into 11-bit segments
4. Map each segment to a word

Word List:
• 2048 standardized words (BIP-39)
• Available in multiple languages
• First 4 letters uniquely identify each word

Security:
• 12 words = 2^128 combinations (uncrackable)
• 24 words = 2^256 combinations (even more secure)
• NEVER share your mnemonic phrase
• Store offline in multiple secure locations
''',
    'Private Keys': '''
Private keys are the core of cryptocurrency ownership.

What is a Private Key?
• 256-bit random number
• Mathematically linked to public key
• Proves ownership of addresses
• Signs transactions

Key Formats:
• Raw: 64 hexadecimal characters
• WIF (Bitcoin): Base58 encoded with prefix
• Keystore (Ethereum): JSON file with encrypted key

Security Rules:
1. Generate with secure randomness
2. Never share with anyone
3. Never store unencrypted online
4. Have multiple backups
5. Consider hardware wallet for large amounts
''',
    'Address Types': '''
Different address formats serve different purposes.

Bitcoin Addresses:
• P2PKH (1...): Original format, Pay-to-Public-Key-Hash
• P2SH (3...): Script hash, enables multisig
• Bech32 (bc1...): Native SegWit, lower fees

Ethereum Addresses:
• 0x + 40 hex characters
• Checksum via capitalization (EIP-55)
• Same address for ETH and all ERC-20 tokens

Address Generation:
Public Key → Hash → Encode → Address

Always double-check addresses before sending!
One wrong character = lost funds forever.
''',
    'Wallet Security': '''
Protect your wallet with these practices.

Hot Wallet (Connected to Internet):
• Convenient for daily use
• Higher risk of hack
• Keep small amounts only

Cold Wallet (Offline):
• Maximum security
• Hardware wallet recommended
• For long-term storage

Best Practices:
• Use strong, unique passwords
• Enable 2FA where available
• Verify addresses carefully
• Be skeptical of "support" messages
• Test with small amounts first
• Regular security audits
''',
  };
}
