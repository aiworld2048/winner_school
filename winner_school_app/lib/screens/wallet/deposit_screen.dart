import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/wallet_service.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  bool _loadingBanks = false;
  bool _submitting = false;
  List<WalletBank> _banks = [];
  WalletBank? _selectedBank;
  String _amount = '';
  String _reference = '';
  Map<String, List<String>>? _fieldErrors;

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated || auth.token == null) return;
    setState(() => _loadingBanks = true);
    try {
      final banks = await WalletService.fetchBanks(auth.token!);
      if (mounted) {
        setState(() {
          _banks = banks;
          if (banks.isNotEmpty) {
            _selectedBank = banks.first;
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load banks: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingBanks = false);
      }
    }
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated || auth.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to deposit.')),
      );
      return;
    }
    if (_selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a bank account.')),
      );
      return;
    }

    setState(() {
      _submitting = true;
      _fieldErrors = null;
    });

    final result = await WalletService.deposit(
      token: auth.token!,
      agentPaymentTypeId: _selectedBank!.id,
      amount: _amount,
      reference: _reference,
    );

    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
      await auth.refreshProfile();
      setState(() {
        _amount = '';
        _reference = '';
      });
    } else {
      setState(() => _fieldErrors = result.fieldErrors);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }

    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101223),
      appBar: AppBar(
        title: const Text('Deposit'),
        backgroundColor: const Color(0xFF181A29),
      ),
      body: _loadingBanks
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_selectedBank != null) _SelectedBankCard(bank: _selectedBank!),
                  const SizedBox(height: 16),
                  _BankSelector(
                    banks: _banks,
                    selectedBank: _selectedBank,
                    onChanged: (bank) => setState(() => _selectedBank = bank),
                  ),
                  const SizedBox(height: 24),
                  _DepositForm(
                    amount: _amount,
                    reference: _reference,
                    fieldErrors: _fieldErrors,
                    onAmountChanged: (value) => setState(() => _amount = value),
                    onReferenceChanged: (value) => setState(() => _reference = value),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SelectedBankCard extends StatelessWidget {
  const _SelectedBankCard({required this.bank});

  final WalletBank bank;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
        color: const Color(0xFF181A29),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              bank.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.account_balance, size: 40, color: Colors.white70),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bank.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bank.account,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: bank.account));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account number copied to clipboard.')),
              );
            },
            icon: const Icon(Icons.copy, color: Color(0xFFFFD700)),
            tooltip: 'Copy account',
          ),
        ],
      ),
    );
  }
}

class _BankSelector extends StatelessWidget {
  const _BankSelector({
    required this.banks,
    required this.selectedBank,
    required this.onChanged,
  });

  final List<WalletBank> banks;
  final WalletBank? selectedBank;
  final ValueChanged<WalletBank> onChanged;

  @override
  Widget build(BuildContext context) {
    if (banks.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF181A29),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Choose Bank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          ...banks.map((bank) {
            final isSelected = selectedBank?.id == bank.id;
            return ListTile(
              onTap: () => onChanged(bank),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  bank.imageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.account_balance, color: Colors.white70),
                ),
              ),
              title: Text(
                bank.name,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFFFD700) : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              subtitle: Text(
                bank.account,
                style: const TextStyle(color: Colors.white54),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Color(0xFFFFD700))
                  : const Icon(Icons.circle_outlined, color: Colors.white24),
            );
          }),
        ],
      ),
    );
  }
}

class _DepositForm extends StatelessWidget {
  const _DepositForm({
    required this.amount,
    required this.reference,
    required this.fieldErrors,
    required this.onAmountChanged,
    required this.onReferenceChanged,
  });

  final String amount;
  final String reference;
  final Map<String, List<String>>? fieldErrors;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onReferenceChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF181A29),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InputField(
            label: 'Amount',
            hint: 'Enter amount',
            keyboardType: TextInputType.number,
            value: amount,
            onChanged: onAmountChanged,
            errorText: _firstError('amount'),
          ),
          const SizedBox(height: 16),
          _InputField(
            label: 'Transfer Reference',
            hint: 'Enter last 6 digits',
            value: reference,
            onChanged: onReferenceChanged,
            errorText: _firstError('refrence_no'),
          ),
        ],
      ),
    );
  }

  String? _firstError(String key) {
    final errors = fieldErrors;
    if (errors == null) return null;
    final values = errors[key];
    if (values != null && values.isNotEmpty) {
      return values.first;
    }
    return null;
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFFD700)),
            ),
            errorText: errorText,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
