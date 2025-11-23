import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blockchain_provider.dart';
import '../core/blockchain.dart';
import '../utils/theme.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Blockchain'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Blockchain'),
            Tab(text: 'Hashing'),
            Tab(text: 'Signatures'),
            Tab(text: 'Concepts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BlockchainDemo(),
          _HashingDemo(),
          _SignatureDemo(),
          _ConceptsView(),
        ],
      ),
    );
  }
}

class _BlockchainDemo extends StatelessWidget {
  const _BlockchainDemo();

  @override
  Widget build(BuildContext context) {
    return Consumer<BlockchainProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Controls
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: provider.isMining ? null : () => provider.minePendingTransactions(),
                      icon: provider.isMining
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.engineering),
                      label: Text(provider.isMining
                          ? 'Mining... (${provider.miningAttempts} attempts)'
                          : 'Mine Block'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: provider.resetBlockchain,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Reset blockchain',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Validation Status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (provider.validateChain()
                          ? AppTheme.successColor
                          : AppTheme.errorColor)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: provider.validateChain()
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      provider.validateChain() ? Icons.check_circle : Icons.error,
                      color: provider.validateChain()
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      provider.validateChain()
                          ? 'Blockchain is valid'
                          : 'Blockchain has been tampered!',
                      style: TextStyle(
                        color: provider.validateChain()
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Blockchain visualization
              Text(
                'Blockchain (${provider.chain.length} blocks)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              ...provider.chain.map((block) => _BlockCard(
                    block: block,
                    isFirst: block.index == 0,
                    onTamper: block.index > 0
                        ? () => provider.tamperWithBlock(block.index)
                        : null,
                  )),

              if (provider.blockchain.pendingTransactions.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Pending Transactions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...provider.blockchain.pendingTransactions.map(
                  (tx) => _TransactionCard(transaction: tx),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BlockCard extends StatelessWidget {
  final Block block;
  final bool isFirst;
  final VoidCallback? onTamper;

  const _BlockCard({
    required this.block,
    required this.isFirst,
    this.onTamper,
  });

  @override
  Widget build(BuildContext context) {
    final isValid = block.hash == block.recalculateHash();

    return Column(
      children: [
        if (!isFirst) ...[
          Container(
            width: 2,
            height: 20,
            color: AppTheme.primaryColor,
          ),
          const Icon(Icons.arrow_downward, color: AppTheme.primaryColor, size: 20),
        ],
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isValid ? AppTheme.darkBorder : AppTheme.errorColor,
              width: isValid ? 1 : 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFirst
                          ? AppTheme.primaryColor.withValues(alpha: 0.2)
                          : AppTheme.secondaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isFirst ? 'Genesis Block' : 'Block #${block.index}',
                      style: TextStyle(
                        color: isFirst ? AppTheme.primaryColor : AppTheme.secondaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (!isValid)
                    const Chip(
                      label: Text('INVALID', style: TextStyle(fontSize: 10)),
                      backgroundColor: AppTheme.errorColor,
                      padding: EdgeInsets.zero,
                    ),
                  if (onTamper != null && isValid)
                    TextButton.icon(
                      onPressed: onTamper,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Tamper'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.warningColor,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _InfoRow(label: 'Timestamp', value: block.timestamp.toString()),
              _InfoRow(label: 'Nonce', value: block.nonce.toString()),
              _InfoRow(
                label: 'Hash',
                value: block.hash.substring(0, 20) + '...',
                isMono: true,
              ),
              _InfoRow(
                label: 'Prev Hash',
                value: block.previousHash.substring(0, 20) + '...',
                isMono: true,
              ),
              if (block.transactions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${block.transactions.length} transaction(s)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.pending, color: AppTheme.warningColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${transaction.fromAddress} → ${transaction.toAddress}',
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${transaction.amount} EDU',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _HashingDemo extends StatelessWidget {
  const _HashingDemo();

  @override
  Widget build(BuildContext context) {
    return Consumer<BlockchainProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SHA-256 Hashing Demo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Type any text to see how hashing works. Notice how even small changes produce completely different hashes.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              TextField(
                decoration: const InputDecoration(
                  labelText: 'Input Text',
                  hintText: 'Enter any text to hash...',
                ),
                onChanged: provider.updateHashInput,
              ),
              const SizedBox(height: 24),

              if (provider.hashOutput.isNotEmpty) ...[
                Text(
                  'SHA-256 Output',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        provider.hashOutput,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '64 hexadecimal characters = 256 bits',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Double SHA-256 (Bitcoin-style)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: SelectableText(
                    provider.getDoubleSha256(provider.hashInput),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
              _ConceptCard(
                title: 'Hash Properties',
                content: '''
• Deterministic: Same input = same output
• One-way: Cannot reverse hash to find input
• Fast: Quick to compute
• Avalanche: Small change = different hash
• Collision-resistant: Hard to find two inputs with same hash
''',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SignatureDemo extends StatelessWidget {
  const _SignatureDemo();

  @override
  Widget build(BuildContext context) {
    return Consumer<BlockchainProvider>(
      builder: (context, provider, _) {
        final keyPair = provider.demoKeyPair;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Digital Signatures Demo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Digital signatures prove ownership without revealing the private key.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Key Pair
              Row(
                children: [
                  Text(
                    'Key Pair (ECDSA secp256k1)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: provider.generateNewKeyPair,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('New Keys'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (keyPair != null) ...[
                _KeyDisplay(
                  label: 'Private Key (SECRET!)',
                  value: keyPair['privateKey']!,
                  isSecret: true,
                ),
                const SizedBox(height: 12),
                _KeyDisplay(
                  label: 'Public Key',
                  value: keyPair['publicKey']!,
                ),
              ],
              const SizedBox(height: 24),

              // Sign Message
              Text(
                'Sign a Message',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Message to Sign',
                  hintText: 'Enter a message...',
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    provider.signMessage(value);
                  }
                },
              ),

              if (provider.signature != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Signature',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text('r: ${provider.signature!['r']!.substring(0, 32)}...'),
                      const SizedBox(height: 4),
                      Text('s: ${provider.signature!['s']!.substring(0, 32)}...'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (provider.signatureValid
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              provider.signatureValid
                                  ? Icons.verified
                                  : Icons.error,
                              color: provider.signatureValid
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              provider.signatureValid
                                  ? 'Signature Valid'
                                  : 'Signature Invalid',
                              style: TextStyle(
                                color: provider.signatureValid
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: provider.tamperMessage,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Tamper Message (breaks signature)'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
              _ConceptCard(
                title: 'How Signatures Work',
                content: '''
1. Sign: message + private key → signature
2. Verify: message + public key + signature → valid/invalid
3. The signature proves you have the private key
4. Changing the message invalidates the signature
5. Anyone can verify, but only you can sign
''',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KeyDisplay extends StatelessWidget {
  final String label;
  final String value;
  final bool isSecret;

  const _KeyDisplay({
    required this.label,
    required this.value,
    this.isSecret = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSecret
            ? AppTheme.errorColor.withValues(alpha: 0.1)
            : AppTheme.darkCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSecret ? AppTheme.errorColor : AppTheme.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isSecret)
                const Icon(Icons.warning, size: 16, color: AppTheme.errorColor),
              if (isSecret) const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSecret ? AppTheme.errorColor : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${value.substring(0, 40)}...',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConceptsView extends StatelessWidget {
  const _ConceptsView();

  @override
  Widget build(BuildContext context) {
    return Consumer<BlockchainProvider>(
      builder: (context, provider, _) {
        final cryptoConcepts = provider.getCryptoEducation();
        final blockchainConcepts = provider.getBlockchainEducation();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Cryptography Concepts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...cryptoConcepts.entries.map(
              (e) => _ExpandableConceptCard(title: e.key, content: e.value),
            ),
            const SizedBox(height: 24),
            Text(
              'Blockchain Concepts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...blockchainConcepts.entries.map(
              (e) => _ExpandableConceptCard(title: e.key, content: e.value),
            ),
          ],
        );
      },
    );
  }
}

class _ExpandableConceptCard extends StatelessWidget {
  final String title;
  final String content;

  const _ExpandableConceptCard({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(title),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            content.trim(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ConceptCard extends StatelessWidget {
  final String title;
  final String content;

  const _ConceptCard({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content.trim(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMono;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isMono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: isMono ? 'monospace' : null,
                fontSize: isMono ? 11 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
