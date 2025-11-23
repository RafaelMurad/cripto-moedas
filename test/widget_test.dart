import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ai_crypto_wallet/main.dart';
import 'package:ai_crypto_wallet/providers/wallet_provider.dart';
import 'package:ai_crypto_wallet/providers/chat_provider.dart';
import 'package:ai_crypto_wallet/providers/blockchain_provider.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const AICryptoWalletApp());
    await tester.pumpAndSettle();

    // Verify the app title appears
    expect(find.text('AI Crypto Wallet'), findsOneWidget);
  });

  testWidgets('Bottom navigation exists', (WidgetTester tester) async {
    await tester.pumpWidget(const AICryptoWalletApp());
    await tester.pumpAndSettle();

    // Verify bottom navigation items
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('AI Assistant'), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
