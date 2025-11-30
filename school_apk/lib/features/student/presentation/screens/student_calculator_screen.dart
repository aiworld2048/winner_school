import 'dart:math' as math;

import 'package:flutter/material.dart';

class StudentCalculatorScreen extends StatefulWidget {
  const StudentCalculatorScreen({super.key});

  @override
  State<StudentCalculatorScreen> createState() => _StudentCalculatorScreenState();
}

class _StudentCalculatorScreenState extends State<StudentCalculatorScreen> {
  final TextEditingController _displayController = TextEditingController(text: '0');
  double _memory = 0;
  String? _operator;
  bool _shouldReset = false;

  void _append(String value) {
    setState(() {
      if (_shouldReset || _displayController.text == '0') {
        _displayController.text = value;
        _shouldReset = false;
      } else {
        _displayController.text += value;
      }
    });
  }

  double _currentValue() => double.tryParse(_displayController.text) ?? 0;

  void _setOperator(String op) {
    setState(() {
      if (_operator != null) {
        _calculate();
      } else {
        _memory = _currentValue();
      }
      _operator = op;
      _shouldReset = true;
    });
  }

  void _calculate() {
    final current = _currentValue();
    double result = _memory;
    switch (_operator) {
      case '+':
        result += current;
        break;
      case '-':
        result -= current;
        break;
      case '×':
        result *= current;
        break;
      case '÷':
        if (current != 0) result /= current;
        break;
    }
    setState(() {
      _displayController.text = _format(result);
      _memory = result;
      _operator = null;
      _shouldReset = true;
    });
  }

  void _clear() {
    setState(() {
      _displayController.text = '0';
      _memory = 0;
      _operator = null;
      _shouldReset = false;
    });
  }

  void _percent() {
    setState(() {
      final value = _currentValue() / 100;
      _displayController.text = _format(value);
    });
  }

  void _toggleSign() {
    setState(() {
      final value = -_currentValue();
      _displayController.text = _format(value);
    });
  }

  String _format(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ['C', '±', '%', '√'],
      ['sin', 'cos', 'tan', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '.', '⌫', '='],
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Smart calculator',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            'Perfect for Grade 5 - Grade 12 students. Includes percent, roots, and trig (sin/cos/tan).',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _displayController,
            readOnly: true,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              itemCount: buttons.length * 4,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final row = buttons[index ~/ 4];
                final label = row[index % 4];
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: _isOperator(label)
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    foregroundColor: _isOperator(label)
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => _handleInput(label),
                  child: Text(label),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleInput(String label) {
    if (label == 'C') return _clear();
    if (label == '±') return _toggleSign();
    if (label == '%') return _percent();
    if (label == '√') {
      setState(() {
        final value = _currentValue();
        _displayController.text = value >= 0 ? _format(math.sqrt(value)) : 'NaN';
      });
      return;
    }
    if (label == 'sin' || label == 'cos' || label == 'tan') {
      setState(() {
        final radians = _currentValue() * math.pi / 180;
        double result;
        switch (label) {
          case 'sin':
            result = math.sin(radians);
            break;
          case 'cos':
            result = math.cos(radians);
            break;
          default:
            result = math.tan(radians);
            break;
        }
        _displayController.text = _format(result);
      });
      return;
    }
    if (label == '⌫') {
      setState(() {
        final text = _displayController.text;
        if (text.length <= 1) {
          _displayController.text = '0';
        } else {
          _displayController.text = text.substring(0, text.length - 1);
        }
      });
      return;
    }
    if (label == '=') return _calculate();
    if (['+', '-', '×', '÷'].contains(label)) return _setOperator(label);
    if (label == '.') {
      if (!_displayController.text.contains('.')) {
        _append('.');
      }
      return;
    }
    _append(label);
  }

  bool _isOperator(String label) => ['+', '-', '×', '÷', '=', '√', 'sin', 'cos', 'tan'].contains(label);
}

