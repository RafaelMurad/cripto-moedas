import 'package:equatable/equatable.dart';

/// Represents a message in the AI chat.
class ChatMessage extends Equatable {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final List<String>? codeBlocks;
  final List<String>? relatedTopics;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.codeBlocks,
    this.relatedTopics,
  });

  @override
  List<Object?> get props => [id];

  factory ChatMessage.user(String content) => ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        role: MessageRole.user,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.assistant(
    String content, {
    List<String>? codeBlocks,
    List<String>? relatedTopics,
  }) =>
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
        codeBlocks: codeBlocks,
        relatedTopics: relatedTopics,
      );

  factory ChatMessage.system(String content) => ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        role: MessageRole.system,
        timestamp: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'role': role.name,
        'timestamp': timestamp.toIso8601String(),
        'codeBlocks': codeBlocks,
        'relatedTopics': relatedTopics,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'],
        content: json['content'],
        role: MessageRole.values.byName(json['role']),
        timestamp: DateTime.parse(json['timestamp']),
        codeBlocks: json['codeBlocks'] != null
            ? List<String>.from(json['codeBlocks'])
            : null,
        relatedTopics: json['relatedTopics'] != null
            ? List<String>.from(json['relatedTopics'])
            : null,
      );
}

enum MessageRole {
  user,
  assistant,
  system,
}

/// Topics that the AI assistant can teach about.
class LearningTopic {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> keywords;
  final String? prerequisite;

  const LearningTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.keywords,
    this.prerequisite,
  });

  static const List<LearningTopic> allTopics = [
    LearningTopic(
      id: 'blockchain-basics',
      title: 'Blockchain Basics',
      description: 'Learn the fundamentals of blockchain technology',
      category: 'Fundamentals',
      keywords: ['blockchain', 'distributed ledger', 'decentralization'],
    ),
    LearningTopic(
      id: 'cryptography',
      title: 'Cryptography in Blockchain',
      description: 'Understand hashing, digital signatures, and encryption',
      category: 'Fundamentals',
      keywords: ['hash', 'sha256', 'encryption', 'digital signature', 'ecdsa'],
    ),
    LearningTopic(
      id: 'wallets',
      title: 'Cryptocurrency Wallets',
      description: 'How wallets work, private keys, and security',
      category: 'Fundamentals',
      keywords: ['wallet', 'private key', 'public key', 'seed phrase', 'mnemonic'],
    ),
    LearningTopic(
      id: 'transactions',
      title: 'Transactions',
      description: 'How cryptocurrency transactions work',
      category: 'Fundamentals',
      keywords: ['transaction', 'utxo', 'gas', 'fee', 'confirmation'],
    ),
    LearningTopic(
      id: 'mining',
      title: 'Mining & Consensus',
      description: 'Proof of work, proof of stake, and consensus mechanisms',
      category: 'Advanced',
      keywords: ['mining', 'proof of work', 'proof of stake', 'consensus', 'validator'],
      prerequisite: 'blockchain-basics',
    ),
    LearningTopic(
      id: 'smart-contracts',
      title: 'Smart Contracts',
      description: 'Self-executing contracts on the blockchain',
      category: 'Advanced',
      keywords: ['smart contract', 'solidity', 'evm', 'defi'],
      prerequisite: 'transactions',
    ),
    LearningTopic(
      id: 'defi',
      title: 'Decentralized Finance (DeFi)',
      description: 'Learn about DeFi protocols and applications',
      category: 'Applications',
      keywords: ['defi', 'amm', 'liquidity', 'yield', 'lending'],
      prerequisite: 'smart-contracts',
    ),
    LearningTopic(
      id: 'nfts',
      title: 'NFTs & Digital Ownership',
      description: 'Non-fungible tokens and digital collectibles',
      category: 'Applications',
      keywords: ['nft', 'erc721', 'digital art', 'collectibles'],
      prerequisite: 'smart-contracts',
    ),
    LearningTopic(
      id: 'security',
      title: 'Security Best Practices',
      description: 'Protecting your cryptocurrency assets',
      category: 'Security',
      keywords: ['security', 'phishing', 'scam', 'hardware wallet', 'backup'],
    ),
    LearningTopic(
      id: 'bitcoin',
      title: 'Bitcoin Deep Dive',
      description: 'Technical details of the Bitcoin protocol',
      category: 'Specific Chains',
      keywords: ['bitcoin', 'btc', 'satoshi', 'lightning network'],
      prerequisite: 'blockchain-basics',
    ),
    LearningTopic(
      id: 'ethereum',
      title: 'Ethereum Deep Dive',
      description: 'The Ethereum network and ecosystem',
      category: 'Specific Chains',
      keywords: ['ethereum', 'eth', 'gas', 'erc20', 'layer 2'],
      prerequisite: 'blockchain-basics',
    ),
    LearningTopic(
      id: 'layer2',
      title: 'Layer 2 Solutions',
      description: 'Scaling solutions for blockchain networks',
      category: 'Advanced',
      keywords: ['layer 2', 'rollup', 'lightning', 'polygon', 'arbitrum'],
      prerequisite: 'ethereum',
    ),
  ];

  static LearningTopic? findByKeyword(String keyword) {
    final lowerKeyword = keyword.toLowerCase();
    for (final topic in allTopics) {
      if (topic.keywords.any((k) => k.contains(lowerKeyword))) {
        return topic;
      }
    }
    return null;
  }
}
