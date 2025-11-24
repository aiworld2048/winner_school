import 'package:flutter/material.dart';

class BannerTextStrip extends StatelessWidget {
  const BannerTextStrip({
    super.key,
    required this.texts,
  });

  final List<Map<String, dynamic>> texts;

  String _extractText(Map<String, dynamic> item) {
    return (item['banner_text'] ??
            item['text'] ??
            item['title'] ??
            item['message'] ??
            '')
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    if (texts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF181A29),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Welcome to AZM 999!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    final text = _extractText(texts.first);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF181A29),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x66FFD700),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.campaign_outlined,
            color: Color(0xFFFFD700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

