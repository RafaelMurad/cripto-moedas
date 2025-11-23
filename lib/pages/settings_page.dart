import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../utils/theme.dart';
import 'create_wallet_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<WalletProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Wallet Section
              Text(
                'Wallet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textMuted,
                    ),
              ),
              const SizedBox(height: 12),

              if (provider.hasWallet) ...[
                _SettingsTile(
                  icon: Icons.account_balance_wallet,
                  title: 'Wallet Details',
                  subtitle: provider.currentWallet!.address.shortenAddress(),
                  onTap: () => _showWalletDetails(context, provider),
                ),
                _SettingsTile(
                  icon: Icons.key,
                  title: 'View Recovery Phrase',
                  subtitle: 'Backup your wallet',
                  onTap: () => _showRecoveryPhrase(context, provider),
                  trailing: !provider.currentWallet!.isBackedUp
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'NOT BACKED UP',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        )
                      : null,
                ),
                _SettingsTile(
                  icon: Icons.delete_outline,
                  title: 'Delete Wallet',
                  subtitle: 'Remove wallet from this device',
                  onTap: () => _confirmDeleteWallet(context, provider),
                  isDestructive: true,
                ),
              ] else ...[
                _SettingsTile(
                  icon: Icons.add_circle_outline,
                  title: 'Create Wallet',
                  subtitle: 'Create a new wallet',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateWalletPage()),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.download,
                  title: 'Import Wallet',
                  subtitle: 'Restore from recovery phrase',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateWalletPage(isImport: true),
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 24),

              // Security Section
              Text(
                'Security',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textMuted,
                    ),
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.fingerprint,
                title: 'Biometric Authentication',
                subtitle: 'Use fingerprint or face ID',
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.lock_outline,
                title: 'Auto-lock',
                subtitle: 'Lock wallet after inactivity',
                trailing: const Text('5 min'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                },
              ),

              const SizedBox(height: 24),

              // About Section
              Text(
                'About',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textMuted,
                    ),
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'About AI Crypto Wallet',
                subtitle: 'Version 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),
              _SettingsTile(
                icon: Icons.school_outlined,
                title: 'Educational Purpose',
                subtitle: 'Learn about this app',
                onTap: () => _showEducationalInfo(context),
              ),

              const SizedBox(height: 32),

              // Disclaimer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.warningColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_amber, color: AppTheme.warningColor),
                        SizedBox(width: 12),
                        Text(
                          'Educational Disclaimer',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.warningColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This app is for educational purposes only. While it demonstrates real cryptographic concepts, it should not be used to store real cryptocurrency. Always use established, audited wallets for real assets.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showWalletDetails(BuildContext context, WalletProvider provider) {
    final wallet = provider.currentWallet!;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wallet Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              _DetailRow(label: 'Name', value: wallet.name),
              _DetailRow(label: 'Type', value: wallet.type.name.toUpperCase()),
              _DetailRow(
                label: 'Created',
                value: wallet.createdAt.toString().split('.')[0],
              ),
              const SizedBox(height: 16),
              const Text(
                'Address',
                style: TextStyle(color: AppTheme.textMuted),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        wallet.address,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: wallet.address));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Address copied!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showRecoveryPhrase(BuildContext context, WalletProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final words = provider.currentWallet!.mnemonic.split(' ');
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning, color: AppTheme.warningColor),
                  const SizedBox(width: 12),
                  Text(
                    'Recovery Phrase',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'Never share your recovery phrase! Anyone with these words can access your wallet.',
                  style: TextStyle(color: AppTheme.errorColor, fontSize: 13),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: words.asMap().entries.map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.darkBorder),
                    ),
                    child: Text(
                      '${entry.key + 1}. ${entry.value}',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    provider.markAsBackedUp();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Wallet marked as backed up')),
                    );
                  },
                  child: const Text('I have saved my recovery phrase'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteWallet(BuildContext context, WalletProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.darkCard,
          title: const Text('Delete Wallet?'),
          content: const Text(
            'This will remove the wallet from this device. Make sure you have saved your recovery phrase, or you will lose access to your funds forever.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.deleteWallet();
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.darkCard,
          title: const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: AppTheme.primaryColor),
              SizedBox(width: 12),
              Text('AI Crypto Wallet'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version 1.0.0'),
              SizedBox(height: 16),
              Text(
                'An educational cryptocurrency wallet built with Flutter. Learn about blockchain technology, cryptography, and wallet security through interactive demonstrations.',
              ),
              SizedBox(height: 16),
              Text(
                'Technologies covered:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('• SHA-256 Hashing'),
              Text('• ECDSA Digital Signatures'),
              Text('• BIP-39 Mnemonic Generation'),
              Text('• HD Wallet Concepts'),
              Text('• Blockchain Structure'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showEducationalInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.darkCard,
          title: const Text('Educational Purpose'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This app teaches blockchain concepts through:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),
                Text('1. Interactive hashing demonstrations'),
                Text('2. Digital signature creation & verification'),
                Text('3. Live blockchain simulation'),
                Text('4. AI-powered learning assistant'),
                Text('5. Real wallet mechanics (educational)'),
                SizedBox(height: 16),
                Text(
                  'What you\'ll learn:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),
                Text('• How blockchains maintain integrity'),
                Text('• Why private keys must stay secret'),
                Text('• How transactions are signed'),
                Text('• What mining actually does'),
                Text('• Why wallets need backups'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it!'),
            ),
          ],
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.errorColor : AppTheme.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.errorColor : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
