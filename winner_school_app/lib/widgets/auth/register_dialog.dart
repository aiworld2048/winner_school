import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';

class RegisterDialog extends StatefulWidget {
  const RegisterDialog({super.key});

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _referralController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  Map<String, dynamic>? _accountInfo;
  String? _copiedField;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final result = await auth.register(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      confirmPassword: _confirmController.text.trim(),
      referralCode: _referralController.text.trim().isEmpty
          ? null
          : _referralController.text.trim(),
    );
    if (result != null && mounted) {
      setState(() {
        final user = result['user'] as Map<String, dynamic>?;
        _accountInfo = {
          'username': user?['user_name'] ?? '',
          'password': result['password'] as String? ?? '',
          'phone': user?['phone'] ?? _phoneController.text.trim(),
          'name': user?['name'] ?? _nameController.text.trim(),
        };
      });
    }
  }

  Future<void> _copyToClipboard(String text, String field) async {
    await Clipboard.setData(ClipboardData(text: text));
    setState(() {
      _copiedField = field;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copiedField = null;
        });
      }
    });
  }

  void _resetForm() {
    _nameController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmController.clear();
    _referralController.clear();
    setState(() {
      _accountInfo = null;
      _copiedField = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().content;
    final auth = context.watch<AuthProvider>();
    final authStrings = language['auth'] as Map<String, dynamic>? ?? {};

    return AlertDialog(
      backgroundColor: const Color(0xFF181A29),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        _accountInfo != null
            ? 'Registration Successful!'
            : (authStrings['register'] as String? ?? 'Register').toUpperCase(),
        style: const TextStyle(
          color: Color(0xFFFFD700),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: _accountInfo != null
            ? _buildAccountInfoBox()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildField(
                    controller: _nameController,
                    label: authStrings['name'] as String? ?? 'Name',
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _phoneController,
                    label: authStrings['phone'] as String? ?? 'Phone',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _passwordController,
                    label: authStrings['password'] as String? ?? 'Password',
                    obscureText: _obscurePassword,
                    toggleObscure: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _confirmController,
                    label: authStrings['confirm_password'] as String? ??
                        'Confirm Password',
                    obscureText: _obscureConfirm,
                    toggleObscure: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _referralController,
                    label: authStrings['ref_code'] as String? ?? 'Referral Code',
                  ),
                  if (auth.errors != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        auth.errors?['message']?.toString() ??
                            auth.errors?.values.first.toString() ??
                            'Registration failed',
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 12),
                      ),
                    ),
                ],
              ),
      ),
      actions: _accountInfo != null
          ? [
              ElevatedButton(
                onPressed: () {
                  _resetForm();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Close'),
              ),
            ]
          : [
              TextButton(
                onPressed:
                    auth.isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: auth.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                ),
                child: auth.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(authStrings['register'] as String? ?? 'Register'),
              ),
            ],
    );
  }

  Widget _buildAccountInfoBox() {
    final fieldLabels = {
      'username': 'Username',
      'password': 'Password',
      'phone': 'Phone',
      'name': 'Name',
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1b2e),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFD700), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Account Information',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      final allInfo = _accountInfo!.entries
                          .where((e) => e.value != null && e.value.toString().isNotEmpty)
                          .map((e) =>
                              '${fieldLabels[e.key] ?? e.key}: ${e.value}')
                          .join('\n');
                      _copyToClipboard(allInfo, 'all');
                    },
                    icon: Icon(
                      _copiedField == 'all' ? Icons.check : Icons.copy,
                      size: 16,
                      color: const Color(0xFFFFD700),
                    ),
                    label: Text(
                      _copiedField == 'all' ? 'Copied!' : 'Copy All',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 12,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side: const BorderSide(color: Color(0xFFFFD700)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ..._accountInfo!.entries.map((entry) {
                if (entry.value == null || entry.value.toString().isEmpty) {
                  return const SizedBox.shrink();
                }
                final label = fieldLabels[entry.key] ?? entry.key;
                final value = entry.value.toString();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$label:',
                            style: const TextStyle(
                              color: Color(0xFFaaaaaa),
                              fontSize: 12,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _copyToClipboard(value, entry.key),
                            icon: Icon(
                              _copiedField == entry.key
                                  ? Icons.check
                                  : Icons.copy,
                              size: 16,
                              color: _copiedField == entry.key
                                  ? Colors.green
                                  : const Color(0xFFFFD700),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Copy',
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0f1015),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    VoidCallback? toggleObscure,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFF23243A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        suffixIcon: toggleObscure == null
            ? null
            : IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: toggleObscure,
              ),
      ),
    );
  }
}

