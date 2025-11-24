import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/wallet_service.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  bool _loadingBanks = false;
  bool _submitting = false;
  List<WalletBank> _banks = [];
  WalletBank? _selectedBank;

  String _accountName = '';
  String _accountNumber = '';
  String _amount = '';
  String _password = '';
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
        const SnackBar(content: Text('Please login to withdraw.')),
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

    final result = await WalletService.withdraw(
      token: auth.token!,
      paymentTypeId: _selectedBank!.id,
      accountName: _accountName,
      accountNumber: _accountNumber,
      amount: _amount,
      password: _password,
    );

    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
      await auth.refreshProfile();
      setState(() {
        _accountName = '';
        _accountNumber = '';
        _amount = '';
        _password = '';
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
        title: const Text('Withdraw'),
        backgroundColor: const Color(0xFF181A29),
      ),
      body: _loadingBanks
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _WalletBalanceCard(),
                  const SizedBox(height: 16),
                  _BankSelector(
                    banks: _banks,
                    selectedBank: _selectedBank,
                    onChanged: (bank) => setState(() => _selectedBank = bank),
                  ),
                  const SizedBox(height: 24),
                  _WithdrawForm(
                    accountName: _accountName,
                    accountNumber: _accountNumber,
                    amount: _amount,
                    password: _password,
                    fieldErrors: _fieldErrors,
                    onAccountNameChanged: (v) => setState(() => _accountName = v),
                    onAccountNumberChanged: (v) => setState(() => _accountNumber = v),
                    onAmountChanged: (v) => setState(() => _amount = v),
                    onPasswordChanged: (v) => setState(() => _password = v),
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

class _WalletBalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
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
          const Text(
            'Available Balance',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            auth.balance.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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

class _WithdrawForm extends StatelessWidget {
  const _WithdrawForm({
    required this.accountName,
    required this.accountNumber,
    required this.amount,
    required this.password,
    required this.fieldErrors,
    required this.onAccountNameChanged,
    required this.onAccountNumberChanged,
    required this.onAmountChanged,
    required this.onPasswordChanged,
  });

  final String accountName;
  final String accountNumber;
  final String amount;
  final String password;
  final Map<String, List<String>>? fieldErrors;
  final ValueChanged<String> onAccountNameChanged;
  final ValueChanged<String> onAccountNumberChanged;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onPasswordChanged;

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
            label: 'Account Name',
            hint: 'Enter account holder name',
            value: accountName,
            onChanged: onAccountNameChanged,
            errorText: _firstError('account_name'),
          ),
          const SizedBox(height: 16),
          _InputField(
            label: 'Account Number',
            hint: 'Enter account number',
            value: accountNumber,
            onChanged: onAccountNumberChanged,
            errorText: _firstError('account_number'),
          ),
          const SizedBox(height: 16),
          _InputField(
            label: 'Amount',
            hint: 'Enter amount',
            value: amount,
            keyboardType: TextInputType.number,
            onChanged: onAmountChanged,
            errorText: _firstError('amount'),
          ),
          const SizedBox(height: 16),
          _InputField(
            label: 'Password',
            hint: 'Enter password',
            value: password,
            obscureText: true,
            onChanged: onPasswordChanged,
            errorText: _firstError('password'),
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
    this.obscureText = false,
  });

  final String label;
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool obscureText;

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
          obscureText: obscureText,
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
