import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../providers/auth_provider.dart';
import '../../utils/game_launcher.dart';

class BuffaloGameScreen extends StatefulWidget {
  const BuffaloGameScreen({super.key});

  @override
  State<BuffaloGameScreen> createState() => _BuffaloGameScreenState();
}

class _BuffaloGameScreenState extends State<BuffaloGameScreen> {
  bool _isLaunching = false;
  String? _launchingRoomId;

  final List<_BuffaloRoom> _rooms = const [
    _BuffaloRoom(
      id: '1',
      name: 'African Buffalo',
      minBet: 50,
      rtp: '96%',
      badge: 'Basic',
      label: '(50)',
    ),
    _BuffaloRoom(
      id: '2',
      name: 'African Buffalo',
      minBet: 500,
      rtp: '96%',
      badge: 'Intermediate',
      label: '(500)',
    ),
    _BuffaloRoom(
      id: '3',
      name: 'African Buffalo',
      minBet: 5000,
      rtp: '97%',
      badge: 'High',
      label: '(5000)',
    ),
    _BuffaloRoom(
      id: '4',
      name: 'African Buffalo',
      minBet: 10000,
      rtp: '97%',
      badge: 'VIP',
      label: '(10000)',
    ),
  ];

  Future<void> _launchBuffaloGame(_BuffaloRoom room) async {
    final auth = context.read<AuthProvider>();
    final token = auth.token;

    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to play Buffalo game.')),
      );
      return;
    }

    if (auth.balance < room.minBet) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient balance. Minimum bet is ${room.minBet}.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLaunching = true;
      _launchingRoomId = room.id;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.url('buffalo/launch-game')),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'type_id': 1,
          'provider_id': 23,
          'game_id': 23,
          'room_id': room.id,
        }),
      );

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && decoded['code'] == 1) {
        final url = decoded['Url']?.toString() ?? decoded['game_url']?.toString();
        final content = decoded['content']?.toString();
        if (!mounted) return;
        await GameLauncher.launch(
          context,
          url: url,
          htmlContent: content,
          title: '${room.name} ${room.label}',
        );
      } else {
        final message =
            decoded['msg']?.toString() ?? decoded['message']?.toString() ?? 'Failed to launch Buffalo game.';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Launch failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLaunching = false;
          _launchingRoomId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF101223),
      appBar: AppBar(
        title: const Text('Buffalo'),
        backgroundColor: const Color(0xFF181A29),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'lib/assets/buffalo/af.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'African Buffalo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.isAuthenticated
                              ? 'Balance: ${auth.balance.toStringAsFixed(2)}'
                              : 'Login to view balance',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _rooms.length,
                itemBuilder: (context, index) {
                  final room = _rooms[index];
                  final canPlay = auth.isAuthenticated && auth.balance >= room.minBet;
                  final isLaunching = _isLaunching && _launchingRoomId == room.id;

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: const Color(0xFF181A29),
                      border: Border.all(
                        color: canPlay ? const Color(0xFFFFD700) : Colors.grey.shade600,
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(22),
                            ),
                            child: Image.asset(
                              'lib/assets/buffalo/af.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: canPlay
                                          ? const Color(0xFFFFD700)
                                          : Colors.grey.shade600,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      room.badge,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: canPlay ? Colors.black : Colors.white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    room.rtp,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFD700),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${room.name} ${room.label}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Min Bet: ${room.minBet.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLaunching
                                      ? null
                                      : () => _launchBuffaloGame(room),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: canPlay
                                        ? const Color(0xFFFFD700)
                                        : Colors.grey.shade700,
                                    foregroundColor: canPlay ? Colors.black : Colors.white70,
                                  ),
                                  child: isLaunching
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(canPlay ? 'Play' : 'Locked'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuffaloRoom {
  const _BuffaloRoom({
    required this.id,
    required this.name,
    required this.minBet,
    required this.rtp,
    required this.badge,
    required this.label,
  });

  final String id;
  final String name;
  final double minBet;
  final String rtp;
  final String badge;
  final String label;
}

