import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/general_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/api_constants.dart';

class PromotionScreen extends StatelessWidget {
  const PromotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().content;
    final general = context.watch<GeneralProvider>();
    final promotions = general.promotions;
    final title = language['nav']?['promotion'] as String? ?? 'Promotion';

    return Scaffold(
      backgroundColor: const Color(0xFF101223),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A29),
        title: Text(title),
      ),
      body: general.isLoading
          ? const Center(child: CircularProgressIndicator())
          : promotions.isEmpty
              ? Center(
                  child: Text(
                    language['no_data']?.toString() ??
                        'No promotions available yet.',
                    style: const TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final item = promotions[index];
                    final imageUrl = resolveImageUrl(item['img_url']?.toString());

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFF181A29),
                        border: Border.all(color: Colors.white12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20)),
                              child: Image.network(
                                imageUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 180,
                                  color: Colors.black12,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image_not_supported,
                                      color: Colors.white54),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title']?.toString() ?? 'Promotion',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['description']?.toString() ??
                                      'Check out this promotion.',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemCount: promotions.length,
                ),
    );
  }
}

