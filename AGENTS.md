# AI Crypto Wallet

Educational cryptocurrency wallet app for learning blockchain concepts. All data is simulated — no real network calls or transactions.

## Stack

Flutter 3.x, Dart (SDK >=3.0.0 <4.0.0), Provider for state management.
Material Design 3, dark theme only.

## Development

```bash
flutter analyze       # must pass clean
flutter test          # minimal coverage — 2 widget tests
flutter run           # launch on connected device/emulator
```

## Conventions

- Three ChangeNotifier providers: `WalletProvider`, `ChatProvider`, `BlockchainProvider`.
- All crypto prices are simulated in `PriceService` (no HTTP calls despite `http` dependency).
- AI assistant is keyword-matching, not an external API.
- Real cryptography (ECDSA, SHA-256, BIP-39) in `lib/core/` — for education only.
- Wallet data persisted via `SharedPreferences`, not `flutter_secure_storage` (declared but unused).
- Navigation: imperative `Navigator.push` with `MaterialPageRoute`, no named routes.
