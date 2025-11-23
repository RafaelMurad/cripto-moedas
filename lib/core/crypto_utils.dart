import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';
import 'package:convert/convert.dart';

/// Cryptographic utilities for blockchain operations.
/// This class demonstrates core cryptographic concepts used in cryptocurrencies.
class CryptoUtils {
  /// Generates a SHA-256 hash of the input data.
  /// SHA-256 is used extensively in Bitcoin for:
  /// - Creating transaction hashes
  /// - Mining (proof of work)
  /// - Creating addresses
  static String sha256Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Double SHA-256 hash (used in Bitcoin).
  /// Bitcoin uses double hashing for extra security.
  static String doubleSha256(String input) {
    final firstHash = sha256.convert(utf8.encode(input));
    final secondHash = sha256.convert(firstHash.bytes);
    return secondHash.toString();
  }

  /// Generates a RIPEMD-160 hash (used in Bitcoin address creation).
  /// RIPEMD-160 produces shorter hashes (160 bits vs 256 bits).
  static String ripemd160Hash(Uint8List input) {
    final ripemd160 = RIPEMD160Digest();
    final result = ripemd160.process(input);
    return hex.encode(result);
  }

  /// Creates a Bitcoin-style address from a public key.
  /// Process: Public Key -> SHA-256 -> RIPEMD-160 -> Base58Check
  static String publicKeyToAddress(String publicKeyHex) {
    // Step 1: SHA-256 hash of the public key
    final pubKeyBytes = Uint8List.fromList(hex.decode(publicKeyHex));
    final sha256Hash = sha256.convert(pubKeyBytes);

    // Step 2: RIPEMD-160 hash of the SHA-256 result
    final ripemd160 = RIPEMD160Digest();
    final pubKeyHash = ripemd160.process(Uint8List.fromList(sha256Hash.bytes));

    // Step 3: Add version byte (0x00 for mainnet Bitcoin)
    final versionedPayload = Uint8List(21);
    versionedPayload[0] = 0x00;
    versionedPayload.setRange(1, 21, pubKeyHash);

    // Step 4: Calculate checksum (first 4 bytes of double SHA-256)
    final firstHash = sha256.convert(versionedPayload);
    final secondHash = sha256.convert(firstHash.bytes);
    final checksum = secondHash.bytes.sublist(0, 4);

    // Step 5: Concatenate versioned payload and checksum
    final addressBytes = Uint8List(25);
    addressBytes.setRange(0, 21, versionedPayload);
    addressBytes.setRange(21, 25, checksum);

    // Step 6: Base58 encode
    return base58Encode(addressBytes);
  }

  /// Base58 encoding (used in Bitcoin addresses).
  /// Base58 excludes confusing characters: 0, O, I, l
  static const String _base58Alphabet =
      '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

  static String base58Encode(Uint8List input) {
    if (input.isEmpty) return '';

    // Count leading zeros
    int zeros = 0;
    while (zeros < input.length && input[zeros] == 0) {
      zeros++;
    }

    // Convert to BigInt for calculation
    BigInt value = BigInt.zero;
    for (int byte in input) {
      value = value * BigInt.from(256) + BigInt.from(byte);
    }

    // Convert to base58
    String result = '';
    while (value > BigInt.zero) {
      final remainder = (value % BigInt.from(58)).toInt();
      value = value ~/ BigInt.from(58);
      result = _base58Alphabet[remainder] + result;
    }

    // Add leading '1's for each leading zero byte
    return '1' * zeros + result;
  }

  /// Generates cryptographically secure random bytes.
  static Uint8List generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  /// Generates an ECDSA key pair using secp256k1 curve (Bitcoin's curve).
  static Map<String, String> generateKeyPair() {
    final keyParams = ECKeyGeneratorParameters(ECCurve_secp256k1());
    final secureRandom = FortunaRandom();
    secureRandom.seed(KeyParameter(generateRandomBytes(32)));

    final keyGenerator = ECKeyGenerator();
    keyGenerator.init(ParametersWithRandom(keyParams, secureRandom));

    final keyPair = keyGenerator.generateKeyPair();
    final privateKey = keyPair.privateKey as ECPrivateKey;
    final publicKey = keyPair.publicKey as ECPublicKey;

    return {
      'privateKey': privateKey.d!.toRadixString(16).padLeft(64, '0'),
      'publicKey': _encodePublicKey(publicKey),
    };
  }

  /// Encodes an EC public key to hex format.
  static String _encodePublicKey(ECPublicKey publicKey) {
    final x = publicKey.Q!.x!.toBigInteger()!.toRadixString(16).padLeft(64, '0');
    final y = publicKey.Q!.y!.toBigInteger()!.toRadixString(16).padLeft(64, '0');
    return '04$x$y'; // Uncompressed public key format
  }

  /// Creates a digital signature using ECDSA.
  /// This is how transactions are signed to prove ownership.
  static Map<String, String> signMessage(String message, String privateKeyHex) {
    final privateKeyBigInt = BigInt.parse(privateKeyHex, radix: 16);
    final domainParams = ECCurve_secp256k1();
    final privateKey = ECPrivateKey(privateKeyBigInt, domainParams);

    final signer = ECDSASigner(SHA256Digest());
    final secureRandom = FortunaRandom();
    secureRandom.seed(KeyParameter(generateRandomBytes(32)));

    signer.init(
      true,
      ParametersWithRandom(
        PrivateKeyParameter<ECPrivateKey>(privateKey),
        secureRandom,
      ),
    );

    final messageHash = sha256.convert(utf8.encode(message));
    final signature =
        signer.generateSignature(Uint8List.fromList(messageHash.bytes))
            as ECSignature;

    return {
      'r': signature.r.toRadixString(16),
      's': signature.s.toRadixString(16),
    };
  }

  /// Verifies a digital signature.
  static bool verifySignature(
    String message,
    String publicKeyHex,
    String rHex,
    String sHex,
  ) {
    try {
      final domainParams = ECCurve_secp256k1();
      final publicKeyBytes = hex.decode(publicKeyHex);

      // Parse uncompressed public key (04 prefix + x + y)
      if (publicKeyBytes.length != 65 || publicKeyBytes[0] != 0x04) {
        return false;
      }

      final x = BigInt.parse(
        hex.encode(publicKeyBytes.sublist(1, 33)),
        radix: 16,
      );
      final y = BigInt.parse(
        hex.encode(publicKeyBytes.sublist(33, 65)),
        radix: 16,
      );

      final point = domainParams.curve.createPoint(x, y);
      final publicKey = ECPublicKey(point, domainParams);

      final signer = ECDSASigner(SHA256Digest());
      signer.init(false, PublicKeyParameter<ECPublicKey>(publicKey));

      final messageHash = sha256.convert(utf8.encode(message));
      final signature = ECSignature(
        BigInt.parse(rHex, radix: 16),
        BigInt.parse(sHex, radix: 16),
      );

      return signer.verifySignature(
        Uint8List.fromList(messageHash.bytes),
        signature,
      );
    } catch (e) {
      return false;
    }
  }

  /// Generates an Ethereum-style address from public key.
  /// Ethereum uses Keccak-256 and takes the last 20 bytes.
  static String publicKeyToEthereumAddress(String publicKeyHex) {
    // Remove '04' prefix if present (uncompressed key marker)
    String pubKey = publicKeyHex;
    if (pubKey.startsWith('04')) {
      pubKey = pubKey.substring(2);
    }

    // Keccak-256 hash
    final keccak = KeccakDigest(256);
    final pubKeyBytes = Uint8List.fromList(hex.decode(pubKey));
    final hash = keccak.process(pubKeyBytes);

    // Take last 20 bytes and add '0x' prefix
    final addressBytes = hash.sublist(12);
    return '0x${hex.encode(addressBytes)}';
  }
}

/// Explains cryptographic concepts for educational purposes.
class CryptoEducation {
  static const Map<String, String> concepts = {
    'SHA-256': '''
SHA-256 (Secure Hash Algorithm 256-bit) is a cryptographic hash function.

Key Properties:
• Deterministic: Same input always produces same output
• One-way: Cannot reverse the hash to find the input
• Collision-resistant: Extremely hard to find two inputs with same hash
• Avalanche effect: Small input change creates completely different hash

Uses in Blockchain:
• Creating block hashes for the chain
• Proof-of-work mining calculations
• Transaction ID generation
• Part of address creation process
''',
    'ECDSA': '''
ECDSA (Elliptic Curve Digital Signature Algorithm) secures transactions.

How it works:
1. Private key: Secret 256-bit number (your "password")
2. Public key: Derived from private key using elliptic curve math
3. Signature: Created using private key + message

Security:
• Easy to create public key from private key
• Impossible to derive private key from public key
• Signature proves you have the private key without revealing it

Bitcoin uses the secp256k1 curve - a specific elliptic curve chosen for efficiency.
''',
    'Addresses': '''
Cryptocurrency addresses are derived from public keys.

Bitcoin Address Creation:
1. Generate private key (256-bit random number)
2. Calculate public key (ECDSA on secp256k1)
3. SHA-256 hash of public key
4. RIPEMD-160 hash of result (shorter)
5. Add version byte (network identifier)
6. Calculate checksum (double SHA-256)
7. Base58Check encode (human-readable)

Ethereum Address Creation:
1. Generate private key
2. Calculate public key
3. Keccak-256 hash
4. Take last 20 bytes
5. Add '0x' prefix
''',
    'Private Keys': '''
Private keys are the foundation of cryptocurrency ownership.

What is a Private Key?
• A 256-bit (32-byte) random number
• Must be kept SECRET - anyone with it controls your funds
• Usually displayed as 64 hexadecimal characters

Security Best Practices:
• Never share your private key
• Store securely (hardware wallet, encrypted backup)
• Use a mnemonic phrase for backup
• One private key = one address = full control

If you lose your private key, you lose access to your funds forever.
There is no "forgot password" in cryptocurrency!
''',
    'Merkle Trees': '''
Merkle Trees efficiently verify large data sets.

Structure:
• Leaf nodes: Hashes of individual transactions
• Branch nodes: Hashes of their children combined
• Root: Single hash representing all transactions

Benefits:
• Verify any transaction with just a few hashes (proof)
• Detect tampering anywhere in the tree
• Enable "light clients" that don't need full blockchain

Used in Bitcoin to:
• Summarize all transactions in a block
• Enable SPV (Simplified Payment Verification)
• Efficiently prove transaction inclusion
''',
  };
}
