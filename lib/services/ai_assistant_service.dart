import '../core/blockchain.dart';
import '../core/crypto_utils.dart';
import '../models/chat_message.dart';
import '../services/wallet_service.dart';

/// AI Assistant service for blockchain education.
/// Provides intelligent responses about cryptocurrency and blockchain concepts.
class AIAssistantService {
  final Map<String, String> _conversationContext = {};

  /// Generates a response to a user's question.
  Future<ChatMessage> generateResponse(String userMessage) async {
    final lowerMessage = userMessage.toLowerCase();

    // Find relevant topic
    final topic = LearningTopic.findByKeyword(userMessage);

    // Check for specific question types
    if (_isGreeting(lowerMessage)) {
      return _createGreetingResponse();
    }

    if (_isAboutWallets(lowerMessage)) {
      return _createWalletResponse(lowerMessage);
    }

    if (_isAboutBlockchain(lowerMessage)) {
      return _createBlockchainResponse(lowerMessage);
    }

    if (_isAboutCryptography(lowerMessage)) {
      return _createCryptographyResponse(lowerMessage);
    }

    if (_isAboutTransactions(lowerMessage)) {
      return _createTransactionResponse(lowerMessage);
    }

    if (_isAboutMining(lowerMessage)) {
      return _createMiningResponse(lowerMessage);
    }

    if (_isAboutSecurity(lowerMessage)) {
      return _createSecurityResponse(lowerMessage);
    }

    if (_isAboutSmartContracts(lowerMessage)) {
      return _createSmartContractResponse(lowerMessage);
    }

    if (_isAboutDefi(lowerMessage)) {
      return _createDefiResponse(lowerMessage);
    }

    if (_isAboutBitcoin(lowerMessage)) {
      return _createBitcoinResponse(lowerMessage);
    }

    if (_isAboutEthereum(lowerMessage)) {
      return _createEthereumResponse(lowerMessage);
    }

    // Default response with suggestions
    return _createDefaultResponse(topic);
  }

  bool _isGreeting(String message) {
    final greetings = ['hello', 'hi', 'hey', 'greetings', 'help', 'start'];
    return greetings.any((g) => message.contains(g));
  }

  bool _isAboutWallets(String message) {
    final keywords = ['wallet', 'mnemonic', 'seed phrase', 'private key', 'public key', 'address', 'backup'];
    return keywords.any((k) => message.contains(k));
  }

  bool _isAboutBlockchain(String message) {
    final keywords = ['blockchain', 'block', 'chain', 'ledger', 'distributed', 'decentralized', 'immutable'];
    return keywords.any((k) => message.contains(k));
  }

  bool _isAboutCryptography(String message) {
    final keywords = ['hash', 'sha256', 'encrypt', 'sign', 'signature', 'ecdsa', 'cryptograph'];
    return keywords.any((k) => message.contains(k));
  }

  bool _isAboutTransactions(String message) {
    final keywords = ['transaction', 'send', 'transfer', 'utxo', 'input', 'output', 'fee', 'gas'];
    return keywords.any((k) => message.contains(k));
  }

  bool _isAboutMining(String message) {
    final keywords = ['mining', 'miner', 'proof of work', 'pow', 'proof of stake', 'pos', 'consensus', 'validator'];
    return keywords.any((k) => message.contains(k));
  }

  bool _isAboutSecurity(String message) {
    final keywords = ['security', 'safe', 'protect', 'scam', 'phishing', 'hack', 'secure'];
    return keywords.any((k) => message.contains(k));
  }

  bool _isAboutSmartContracts(String message) {
    final keywords = ['smart contract', 'solidity', 'evm', 'deploy', 'contract'];
    return keywords.any((k) => message.contains(k));
  }

  bool _isAboutDefi(String message) {
    final keywords = ['defi', 'swap', 'liquidity', 'yield', 'amm', 'lending', 'borrow'];
    return keywords.any((k) => message.contains(k));
  }

  bool _isAboutBitcoin(String message) {
    final keywords = ['bitcoin', 'btc', 'satoshi', 'lightning'];
    return keywords.any((k) => message.contains(k));
  }

  bool _isAboutEthereum(String message) {
    final keywords = ['ethereum', 'eth', 'ether', 'erc20', 'erc721', 'layer 2'];
    return keywords.any((k) => message.contains(k));
  }

  ChatMessage _createGreetingResponse() {
    return ChatMessage.assistant(
      '''Welcome to your AI Crypto Learning Assistant! 🎓

I'm here to help you understand blockchain technology and cryptocurrency. Here's what I can teach you:

**Fundamentals**
• Blockchain basics - How distributed ledgers work
• Cryptography - Hashing, signatures, encryption
• Wallets - Keys, addresses, and security

**Intermediate Topics**
• Transactions - How value transfers work
• Mining - Consensus and validation
• Networks - Bitcoin, Ethereum, and more

**Advanced Concepts**
• Smart Contracts - Programmable money
• DeFi - Decentralized finance
• Security - Best practices

**Try asking:**
- "How does blockchain work?"
- "Explain private keys"
- "What is proof of work?"
- "How do I keep my crypto safe?"

What would you like to learn about?''',
      relatedTopics: ['blockchain-basics', 'cryptography', 'wallets'],
    );
  }

  ChatMessage _createWalletResponse(String message) {
    if (message.contains('mnemonic') || message.contains('seed')) {
      return ChatMessage.assistant(
        '''**Mnemonic Phrases (Seed Phrases)**

${WalletEducation.concepts['Mnemonic Phrases']}

**Demo:** In this app, you can create a wallet and see your own mnemonic phrase. Go to Settings → Create New Wallet to try it!

**Security Warning:** Never share your real mnemonic phrase with anyone. The phrase shown in this educational app is for learning only.''',
        relatedTopics: ['wallets', 'security'],
        codeBlocks: [
          '''// Generate a mnemonic phrase
final mnemonic = bip39.generateMnemonic();
// Output: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"

// Convert to seed
final seed = bip39.mnemonicToSeed(mnemonic);''',
        ],
      );
    }

    if (message.contains('private key')) {
      return ChatMessage.assistant(
        '''**Private Keys**

${WalletEducation.concepts['Private Keys']}

**How Private Keys Work in Code:**''',
        relatedTopics: ['wallets', 'cryptography', 'security'],
        codeBlocks: [
          '''// Private key is a 256-bit random number
// Usually displayed as 64 hex characters
final privateKey = "e9873d79c6d87dc0fb6a5778633389f4..."

// Public key is derived using elliptic curve math
final publicKey = derivePublicKey(privateKey);

// Address is derived from public key via hashing
final address = publicKeyToAddress(publicKey);''',
        ],
      );
    }

    return ChatMessage.assistant(
      '''**Cryptocurrency Wallets**

${WalletEducation.concepts['HD Wallets']}

**Try It:** Create a new wallet in the Settings tab to see these concepts in action!''',
      relatedTopics: ['wallets', 'security', 'cryptography'],
    );
  }

  ChatMessage _createBlockchainResponse(String message) {
    if (message.contains('block')) {
      return ChatMessage.assistant(
        '''**Blockchain Blocks**

${BlockchainEducation.concepts['Blocks']}

**Block Structure in Code:**''',
        relatedTopics: ['blockchain-basics', 'mining'],
        codeBlocks: [
          '''class Block {
  int index;           // Position in chain
  DateTime timestamp;  // When created
  List transactions;   // Data in block
  String previousHash; // Link to prior block
  int nonce;          // Mining solution
  String hash;        // Block fingerprint
}''',
        ],
      );
    }

    return ChatMessage.assistant(
      '''**What is Blockchain?**

${BlockchainEducation.concepts['Blockchain']}

**Explore:** Check the "Learn" tab to see a live blockchain simulation!''',
      relatedTopics: ['blockchain-basics', 'mining', 'consensus'],
    );
  }

  ChatMessage _createCryptographyResponse(String message) {
    if (message.contains('hash') || message.contains('sha256')) {
      return ChatMessage.assistant(
        '''**Cryptographic Hashing**

${CryptoEducation.concepts['SHA-256']}

**Try It:** In the Learn tab, you can hash your own text and see the output!''',
        relatedTopics: ['cryptography', 'blockchain-basics'],
        codeBlocks: [
          '''// SHA-256 produces a 256-bit (64 hex char) output
sha256("Hello") = "185f8db32271fe25f561a6fc938b2e264306ec304eda518007d1764826381969"
sha256("hello") = "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"

// Notice: small change = completely different hash''',
        ],
      );
    }

    if (message.contains('sign') || message.contains('ecdsa')) {
      return ChatMessage.assistant(
        '''**Digital Signatures (ECDSA)**

${CryptoEducation.concepts['ECDSA']}

**How Signing Works:**''',
        relatedTopics: ['cryptography', 'transactions'],
        codeBlocks: [
          '''// 1. Create message hash
final messageHash = sha256(transactionData);

// 2. Sign with private key
final signature = ecdsa.sign(messageHash, privateKey);

// 3. Anyone can verify with public key
final isValid = ecdsa.verify(messageHash, signature, publicKey);''',
        ],
      );
    }

    return ChatMessage.assistant(
      '''**Cryptography in Blockchain**

Cryptography is the foundation of blockchain security. Key concepts:

**Hashing (SHA-256)**
${CryptoEducation.concepts['SHA-256']?.split('\n').take(6).join('\n')}

**Digital Signatures (ECDSA)**
${CryptoEducation.concepts['ECDSA']?.split('\n').take(6).join('\n')}

What specific aspect would you like to explore?''',
      relatedTopics: ['cryptography', 'security'],
    );
  }

  ChatMessage _createTransactionResponse(String message) {
    if (message.contains('gas') || message.contains('fee')) {
      return ChatMessage.assistant(
        '''**Transaction Fees (Gas)**

Transaction fees incentivize miners/validators to include your transaction.

**Bitcoin Fees:**
• Measured in satoshis per byte
• Higher fee = faster confirmation
• Fee market: compete for block space

**Ethereum Gas:**
• Gas = unit of computational work
• Gas Price = how much you pay per unit
• Gas Limit = max gas you'll use
• Total Fee = Gas Used × Gas Price

**Gas Example:**
```
Simple ETH transfer: ~21,000 gas
Token transfer: ~65,000 gas
Complex DeFi: 100,000+ gas

If gas price = 30 gwei:
21,000 × 30 gwei = 630,000 gwei = 0.00063 ETH
```

**Tips:**
• Check gas prices before transacting
• Use off-peak hours for lower fees
• Layer 2 solutions offer much lower fees''',
        relatedTopics: ['transactions', 'ethereum'],
      );
    }

    return ChatMessage.assistant(
      '''**How Transactions Work**

A transaction transfers value from one address to another.

**Transaction Components:**
• From address: Sender (must have balance)
• To address: Recipient
• Amount: How much to send
• Fee: Payment to miners/validators
• Signature: Proves sender authorization
• Nonce: Prevents replay attacks

**Transaction Lifecycle:**
1. **Create**: Build transaction data
2. **Sign**: Use private key to sign
3. **Broadcast**: Send to network
4. **Pending**: Waiting in mempool
5. **Confirmed**: Included in a block
6. **Finalized**: Multiple confirmations

**Security Note:** Transactions are irreversible! Always double-check the recipient address.''',
      relatedTopics: ['transactions', 'wallets'],
      codeBlocks: [
        '''// Simplified transaction structure
{
  "from": "0x123...",
  "to": "0x456...",
  "value": 1.5,
  "gasLimit": 21000,
  "gasPrice": 30,
  "nonce": 5,
  "signature": "0xabc..."
}''',
      ],
    );
  }

  ChatMessage _createMiningResponse(String message) {
    if (message.contains('proof of stake') || message.contains('pos')) {
      return ChatMessage.assistant(
        '''**Proof of Stake (PoS)**

Proof of Stake is an alternative to Proof of Work.

**How it Works:**
• Validators stake (lock up) cryptocurrency
• Selection based on stake amount + randomness
• Validators propose and attest to blocks
• Misbehavior = stake gets "slashed"

**Advantages:**
• Energy efficient (no mining hardware)
• Lower barrier to participation
• Economic security model
• Enables sharding for scalability

**Disadvantages:**
• "Rich get richer" concern
• Nothing-at-stake problem (mitigated)
• Requires careful protocol design

**Examples:**
• Ethereum (after "The Merge")
• Cardano
• Solana
• Polkadot''',
        relatedTopics: ['mining', 'consensus', 'ethereum'],
      );
    }

    return ChatMessage.assistant(
      '''**Mining and Proof of Work**

${BlockchainEducation.concepts['Mining']}

**Try Mining:** In the Learn tab, you can simulate mining a block and see how nonces and difficulty work!''',
      relatedTopics: ['mining', 'blockchain-basics'],
      codeBlocks: [
        '''// Mining simulation
int nonce = 0;
String hash;
do {
  nonce++;
  hash = sha256(blockData + nonce.toString());
} while (!hash.startsWith("0000")); // difficulty = 4 zeros

print("Found! Nonce: \$nonce, Hash: \$hash");''',
      ],
    );
  }

  ChatMessage _createSecurityResponse(String message) {
    return ChatMessage.assistant(
      '''**Cryptocurrency Security Best Practices**

${WalletEducation.concepts['Wallet Security']}

**Common Threats:**

**1. Phishing**
• Fake websites that look real
• Always verify URLs
• Bookmark important sites

**2. Malware**
• Can steal private keys
• Use hardware wallets
• Keep software updated

**3. Social Engineering**
• "Support" asking for seed phrase
• Fake giveaways
• No legitimate service needs your private key

**4. Smart Contract Risks**
• Only interact with audited contracts
• Revoke unused approvals
• Start with small amounts

**Remember:** There's no customer support in crypto. Lost funds are usually gone forever.''',
      relatedTopics: ['security', 'wallets'],
    );
  }

  ChatMessage _createSmartContractResponse(String message) {
    return ChatMessage.assistant(
      '''**Smart Contracts**

Smart contracts are self-executing programs on the blockchain.

**What They Do:**
• Automatically enforce agreements
• Hold and transfer value
• No middleman needed
• Transparent and immutable

**How They Work:**
1. Developer writes contract code
2. Code is deployed to blockchain
3. Contract gets an address
4. Users interact by sending transactions
5. Contract executes automatically

**Example Use Cases:**
• Token creation (ERC-20)
• NFTs (ERC-721)
• Decentralized exchanges
• Lending protocols
• DAOs (governance)

**Languages:**
• Solidity (Ethereum)
• Rust (Solana)
• Move (Aptos, Sui)''',
      relatedTopics: ['smart-contracts', 'ethereum', 'defi'],
      codeBlocks: [
        '''// Simple Solidity smart contract
contract SimpleStorage {
    uint256 private value;

    function store(uint256 newValue) public {
        value = newValue;
    }

    function retrieve() public view returns (uint256) {
        return value;
    }
}''',
      ],
    );
  }

  ChatMessage _createDefiResponse(String message) {
    return ChatMessage.assistant(
      '''**Decentralized Finance (DeFi)**

DeFi recreates financial services without intermediaries.

**Key Concepts:**

**Automated Market Makers (AMMs)**
• Liquidity pools instead of order books
• Anyone can provide liquidity
• Prices determined by math formula
• Examples: Uniswap, SushiSwap

**Lending/Borrowing**
• Deposit crypto to earn interest
• Borrow against collateral
• No credit checks
• Examples: Aave, Compound

**Yield Farming**
• Provide liquidity, earn rewards
• Stack multiple protocols
• Higher reward = higher risk

**Risks:**
• Smart contract bugs
• Impermanent loss
• Liquidation
• Regulatory uncertainty

**Getting Started:**
1. Start with small amounts
2. Understand what you're doing
3. Use established protocols
4. Monitor your positions''',
      relatedTopics: ['defi', 'smart-contracts', 'security'],
    );
  }

  ChatMessage _createBitcoinResponse(String message) {
    return ChatMessage.assistant(
      '''**Bitcoin (BTC)**

Bitcoin is the first and largest cryptocurrency.

**Key Facts:**
• Created: 2009 by Satoshi Nakamoto
• Supply: Maximum 21 million BTC
• Block time: ~10 minutes
• Consensus: Proof of Work

**Technical Features:**
• UTXO model (Unspent Transaction Outputs)
• Script language for conditions
• SegWit for efficiency
• Taproot for privacy/smart contracts

**Bitcoin Layers:**

**Layer 1 (Main Chain)**
• Maximum security
• Limited throughput (~7 TPS)
• Higher fees for priority

**Lightning Network (Layer 2)**
• Instant payments
• Very low fees
• Payment channels
• Good for small amounts

**Halvings:**
Block reward halves every 210,000 blocks (~4 years):
• 2009: 50 BTC
• 2012: 25 BTC
• 2016: 12.5 BTC
• 2020: 6.25 BTC
• 2024: 3.125 BTC''',
      relatedTopics: ['bitcoin', 'mining', 'layer2'],
    );
  }

  ChatMessage _createEthereumResponse(String message) {
    return ChatMessage.assistant(
      '''**Ethereum (ETH)**

Ethereum is a programmable blockchain platform.

**Key Facts:**
• Created: 2015 by Vitalik Buterin
• Consensus: Proof of Stake (since 2022)
• Block time: ~12 seconds
• Smart contract platform

**Core Concepts:**

**Ethereum Virtual Machine (EVM)**
• Executes smart contracts
• Turing complete
• Gas metering

**Account Types:**
• EOA (Externally Owned Account) - controlled by private key
• Contract Account - controlled by code

**Token Standards:**
• ERC-20: Fungible tokens
• ERC-721: NFTs
• ERC-1155: Multi-token standard

**Scaling Solutions:**

**Layer 2 Rollups:**
• Optimistic Rollups (Arbitrum, Optimism)
• ZK Rollups (zkSync, StarkNet)
• Much lower fees
• Inherit Ethereum security

**Roadmap:**
• Proto-danksharding (EIP-4844)
• Full danksharding
• Continued decentralization''',
      relatedTopics: ['ethereum', 'smart-contracts', 'layer2'],
    );
  }

  ChatMessage _createDefaultResponse(LearningTopic? topic) {
    final suggestions = topic != null
        ? '''Based on your question, you might be interested in: **${topic.title}**

${topic.description}'''
        : '''I'm not sure I understood your question. Here are some topics I can help with:''';

    return ChatMessage.assistant(
      '''$suggestions

**Available Topics:**
• Blockchain basics
• Cryptography (hashing, signatures)
• Wallets and keys
• Transactions
• Mining and consensus
• Smart contracts
• DeFi
• Security

Try asking a specific question like:
- "How does hashing work?"
- "What is a private key?"
- "Explain proof of work"''',
      relatedTopics: ['blockchain-basics', 'cryptography', 'wallets'],
    );
  }

  /// Get suggested follow-up questions based on a topic.
  List<String> getSuggestedQuestions(String topicId) {
    final suggestions = <String, List<String>>{
      'blockchain-basics': [
        'How are blocks connected?',
        'What makes blockchain immutable?',
        'What is a distributed ledger?',
      ],
      'cryptography': [
        'How does SHA-256 work?',
        'What is ECDSA?',
        'Explain digital signatures',
      ],
      'wallets': [
        'What is a mnemonic phrase?',
        'How are addresses created?',
        'How do I backup my wallet?',
      ],
      'transactions': [
        'What are transaction fees?',
        'How long do confirmations take?',
        'What is a nonce?',
      ],
      'mining': [
        'What is proof of work?',
        'How does proof of stake work?',
        'What is mining difficulty?',
      ],
      'security': [
        'How do I protect my crypto?',
        'What is a hardware wallet?',
        'How do I spot scams?',
      ],
    };

    return suggestions[topicId] ?? [
      'What is blockchain?',
      'How do wallets work?',
      'What is cryptocurrency?',
    ];
  }
}
