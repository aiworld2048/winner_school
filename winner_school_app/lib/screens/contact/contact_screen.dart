import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/general_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/api_constants.dart';
import '../../utils/url_launcher_helper.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().content;
    final general = context.watch<GeneralProvider>();
    final contacts = general.contacts;

    return Scaffold(
      backgroundColor: const Color(0xFF101223),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A29),
        title: Text(language['nav']?['contact'] as String? ?? 'Contact'),
      ),
      body: general.isLoading
          ? const Center(child: CircularProgressIndicator())
          : contacts.isEmpty
              ? Center(
                  child: Text(
                    language['no_data']?.toString() ??
                        'No contact channels available.',
                    style: const TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final item = contacts[index];
                    final imageUrl = resolveImageUrl(item['image']?.toString());
                    final name = item['name']?.toString() ?? 'Channel';
                    final link = item['link']?.toString() ??
                        item['phone']?.toString() ??
                        '';

                    return ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      tileColor: const Color(0xFF181A29),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Colors.white12),
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl.isEmpty
                            ? const Icon(Icons.headset_mic_rounded,
                                color: Colors.white)
                            : Image.network(
                                imageUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        link.isEmpty ? 'Tap for more info' : link,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: const Icon(Icons.open_in_new,
                          color: Colors.white70),
                      onTap: link.isEmpty
                          ? null
                          : () {
                              UrlLauncherHelper.launch(link);
                            },
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemCount: contacts.length,
                ),
    );
  }
}

