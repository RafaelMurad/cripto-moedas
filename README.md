# AI Crypto Wallet

An educational AI-powered cryptocurrency wallet built with Flutter. Learn about blockchain technology, cryptography, and wallet security through interactive demonstrations.

## Features

### Wallet Management
- Create new wallets with BIP-39 mnemonic generation
- Import existing wallets using recovery phrases
- Support for multiple wallet types (Educational, Ethereum-style, Bitcoin-style)
- Simulated portfolio with real-time price updates

### AI Learning Assistant
- Interactive chatbot for blockchain education
- Learn about cryptography, transactions, mining, and more
- Code examples and visual explanations
- Suggested questions for deeper learning

### Interactive Learning Lab
- **Blockchain Simulation**: Create blocks, add transactions, mine, and see the chain grow
- **Hashing Demo**: Experiment with SHA-256 hashing and see the avalanche effect
- **Digital Signatures**: Create key pairs, sign messages, and verify signatures
- **Tamper Detection**: See how modifying data breaks the blockchain

### Educational Content
Topics covered include:
- Blockchain fundamentals
- Cryptographic hashing (SHA-256)
- Public/private key cryptography
- Digital signatures (ECDSA)
- HD wallets and BIP-39 mnemonics
- Proof of Work vs Proof of Stake
- Transaction mechanics
- Smart contracts basics
- DeFi concepts
- Security best practices

## Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Cryptography**:
  - `crypto` - SHA-256 hashing
  - `pointycastle` - ECDSA signatures, secp256k1 curve
  - `bip39` - Mnemonic generation
- **Storage**: SharedPreferences, Flutter Secure Storage
- **UI**: Material Design 3, Google Fonts

## Project Structure

```
lib/
├── core/
│   ├── blockchain.dart      # Block, Transaction, Blockchain classes
│   └── crypto_utils.dart    # Hashing, signing, key generation
├── models/
│   ├── wallet.dart          # Wallet, CryptoAsset, Transaction models
│   └── chat_message.dart    # AI chat message models
├── services/
│   ├── wallet_service.dart      # Wallet creation and management
│   ├── ai_assistant_service.dart # AI chatbot logic
│   └── price_service.dart       # Price simulation
├── providers/
│   ├── wallet_provider.dart     # Wallet state management
│   ├── chat_provider.dart       # Chat state management
│   └── blockchain_provider.dart # Blockchain demo state
├── pages/
│   ├── home_page.dart           # Main navigation
│   ├── dashboard_page.dart      # Wallet dashboard
│   ├── send_page.dart           # Send crypto page
│   ├── receive_page.dart        # Receive crypto page
│   ├── ai_chat_page.dart        # AI assistant chat
│   ├── learn_page.dart          # Interactive learning demos
│   ├── settings_page.dart       # App settings
│   └── create_wallet_page.dart  # Wallet creation flow
├── widgets/
│   ├── asset_card.dart          # Crypto asset display
│   └── transaction_tile.dart    # Transaction list item
├── utils/
│   └── theme.dart               # App theming
└── main.dart                    # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart SDK 3.0+

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd cripto-moedas
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## Screenshots

The app features:
- Dark-themed modern UI
- Wallet dashboard with portfolio overview
- AI chat interface for learning
- Interactive blockchain and cryptography demos
- QR code for receiving crypto

## Educational Disclaimer

**This app is for educational purposes only.** While it demonstrates real cryptographic concepts and generates actual cryptographic keys, it should NOT be used to store real cryptocurrency. The simulated transactions do not interact with any real blockchain network.

For storing real cryptocurrency, always use established, audited wallet applications.

## Key Concepts Demonstrated

### Cryptography
- **SHA-256**: Secure hashing with avalanche effect demonstration
- **ECDSA**: Elliptic Curve Digital Signature Algorithm on secp256k1
- **Key Derivation**: From mnemonic to seed to keys to address

### Blockchain
- **Block Structure**: Index, timestamp, transactions, previous hash, nonce
- **Chain Integrity**: How changing one block invalidates subsequent blocks
- **Mining**: Finding nonces that produce hashes with leading zeros
- **Consensus**: Why the longest valid chain wins

### Wallets
- **HD Wallets**: Hierarchical Deterministic wallet concepts
- **BIP-39**: Mnemonic word lists and seed generation
- **Address Formats**: Bitcoin (P2PKH) and Ethereum address creation

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

This project is for educational purposes. Feel free to use and modify for learning.
