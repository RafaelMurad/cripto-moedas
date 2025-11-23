import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../models/wallet.dart';
import '../utils/theme.dart';

class CreateWalletPage extends StatefulWidget {
  final bool isImport;

  const CreateWalletPage({super.key, this.isImport = false});

  @override
  State<CreateWalletPage> createState() => _CreateWalletPageState();
}

class _CreateWalletPageState extends State<CreateWalletPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mnemonicController = TextEditingController();

  int _currentStep = 0;
  String? _generatedMnemonic;
  bool _mnemonicConfirmed = false;
  WalletType _selectedType = WalletType.educational;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isImport) {
      _generatedMnemonic = context.read<WalletProvider>().generateMnemonic();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mnemonicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isImport ? 'Import Wallet' : 'Create Wallet'),
      ),
      body: widget.isImport ? _buildImportForm() : _buildCreateStepper(),
    );
  }

  Widget _buildCreateStepper() {
    return Stepper(
      currentStep: _currentStep,
      onStepContinue: _onStepContinue,
      onStepCancel: _onStepCancel,
      controlsBuilder: (context, details) {
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: _isCreating ? null : details.onStepContinue,
                child: _isCreating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_currentStep == 2 ? 'Create Wallet' : 'Continue'),
              ),
              if (_currentStep > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
                ),
            ],
          ),
        );
      },
      steps: [
        Step(
          title: const Text('Wallet Name'),
          content: _buildNameStep(),
          isActive: _currentStep >= 0,
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Recovery Phrase'),
          content: _buildMnemonicStep(),
          isActive: _currentStep >= 1,
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Confirm & Create'),
          content: _buildConfirmStep(),
          isActive: _currentStep >= 2,
          state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        ),
      ],
    );
  }

  Widget _buildNameStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Wallet Name',
              hintText: 'My Learning Wallet',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a wallet name';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Select Wallet Type',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _WalletTypeOption(
            type: WalletType.educational,
            title: 'Educational',
            description: 'Perfect for learning blockchain concepts',
            icon: Icons.school,
            isSelected: _selectedType == WalletType.educational,
            onTap: () => setState(() => _selectedType = WalletType.educational),
          ),
          _WalletTypeOption(
            type: WalletType.ethereum,
            title: 'Ethereum Style',
            description: 'Uses Ethereum address format (0x...)',
            icon: Icons.diamond,
            isSelected: _selectedType == WalletType.ethereum,
            onTap: () => setState(() => _selectedType = WalletType.ethereum),
          ),
          _WalletTypeOption(
            type: WalletType.bitcoin,
            title: 'Bitcoin Style',
            description: 'Uses Bitcoin address format (1...)',
            icon: Icons.currency_bitcoin,
            isSelected: _selectedType == WalletType.bitcoin,
            onTap: () => setState(() => _selectedType = WalletType.bitcoin),
          ),
        ],
      ),
    );
  }

  Widget _buildMnemonicStep() {
    final words = _generatedMnemonic?.split(' ') ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.warning, color: AppTheme.warningColor),
                  SizedBox(width: 12),
                  Text(
                    'Important Security Information',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.warningColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '• Write down these 12 words in order\n'
                '• Store them in a safe, offline location\n'
                '• Never share them with anyone\n'
                '• These words are the ONLY way to recover your wallet',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'Your Recovery Phrase',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: words.asMap().entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${entry.key + 1}. ${entry.value}',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        CheckboxListTile(
          value: _mnemonicConfirmed,
          onChanged: (value) {
            setState(() => _mnemonicConfirmed = value ?? false);
          },
          title: const Text('I have written down my recovery phrase'),
          subtitle: const Text('You will need it to recover your wallet'),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.school, color: AppTheme.primaryColor, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Learn: What is a Recovery Phrase?',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'A recovery phrase (or seed phrase) is a series of 12-24 words that represents your wallet\'s master key. Using a standardized word list (BIP-39), your entire wallet can be regenerated from these words. This is why they must be kept secret and stored safely.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Column(
            children: [
              _ConfirmRow(
                label: 'Wallet Name',
                value: _nameController.text,
              ),
              const Divider(height: 24),
              _ConfirmRow(
                label: 'Wallet Type',
                value: _selectedType.name.toUpperCase(),
              ),
              const Divider(height: 24),
              _ConfirmRow(
                label: 'Recovery Phrase',
                value: '12 words (saved)',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.successColor),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your wallet will be created locally on this device. No data is sent to any server.',
                  style: TextStyle(color: AppTheme.successColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImportForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enter your 12-word recovery phrase to restore your wallet.',
                      style: TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Wallet Name',
                hintText: 'My Restored Wallet',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a wallet name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _mnemonicController,
              decoration: const InputDecoration(
                labelText: 'Recovery Phrase',
                hintText: 'Enter your 12 words separated by spaces',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your recovery phrase';
                }
                final words = value.trim().split(' ');
                if (words.length != 12 && words.length != 24) {
                  return 'Recovery phrase must be 12 or 24 words';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            Text(
              'Select Wallet Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            _WalletTypeOption(
              type: WalletType.educational,
              title: 'Educational',
              description: 'Perfect for learning',
              icon: Icons.school,
              isSelected: _selectedType == WalletType.educational,
              onTap: () => setState(() => _selectedType = WalletType.educational),
            ),
            _WalletTypeOption(
              type: WalletType.ethereum,
              title: 'Ethereum Style',
              description: 'Uses 0x... format',
              icon: Icons.diamond,
              isSelected: _selectedType == WalletType.ethereum,
              onTap: () => setState(() => _selectedType = WalletType.ethereum),
            ),
            _WalletTypeOption(
              type: WalletType.bitcoin,
              title: 'Bitcoin Style',
              description: 'Uses 1... format',
              icon: Icons.currency_bitcoin,
              isSelected: _selectedType == WalletType.bitcoin,
              onTap: () => setState(() => _selectedType = WalletType.bitcoin),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _importWallet,
                child: _isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Import Wallet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onStepContinue() async {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_mnemonicConfirmed) {
        setState(() => _currentStep++);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please confirm you have saved your recovery phrase'),
          ),
        );
      }
    } else if (_currentStep == 2) {
      await _createWallet();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _createWallet() async {
    setState(() => _isCreating = true);

    try {
      await context.read<WalletProvider>().createWallet(
            name: _nameController.text,
            type: _selectedType,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wallet created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  Future<void> _importWallet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      await context.read<WalletProvider>().importWallet(
            mnemonic: _mnemonicController.text.trim(),
            name: _nameController.text,
            type: _selectedType,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wallet imported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}

class _WalletTypeOption extends StatelessWidget {
  final WalletType type;
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _WalletTypeOption({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : AppTheme.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.darkBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textMuted,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.primaryColor : null,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;

  const _ConfirmRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
