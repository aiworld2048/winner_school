import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../common/widgets/async_value_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_controller.dart';
import '../models/dictionary_entry.dart';
import '../providers/dictionary_providers.dart';

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  final _searchController = TextEditingController();
  late final FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('en-US');
    _flutterTts.setSpeechRate(0.45);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.text = ref.read(dictionarySearchQueryProvider);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    await _flutterTts.stop();
    await _flutterTts.speak(text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(dictionaryEntriesProvider);
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final user = authState.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictionary'),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(user.userName.isNotEmpty ? user.userName : user.name),
                  Text(
                    user.role.name,
                    style: theme.textTheme.labelSmall?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(dictionarySearchQueryProvider.notifier).state = '';
                          ref.invalidate(dictionaryEntriesProvider);
                        },
                      ),
                hintText: 'Search word or meaning',
              ),
              onChanged: (value) {
                ref.read(dictionarySearchQueryProvider.notifier).state = value;
                ref.invalidate(dictionaryEntriesProvider);
                setState(() {}); // to refresh clear icon
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AsyncValueWidget(
                value: entries,
                builder: (data) {
                  if (data.isEmpty) {
                    return const Center(child: Text('No entries found.'));
                  }
                  return ListView.separated(
                    itemBuilder: (context, index) {
                      final entry = data[index];
                      return _DictionaryCard(
                        entry: entry,
                        onSpeakWord: () => _speak(entry.englishWord),
                        onSpeakExample: entry.example == null ? null : () => _speak(entry.example!),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: data.length,
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

class _DictionaryCard extends StatelessWidget {
  const _DictionaryCard({
    required this.entry,
    required this.onSpeakWord,
    this.onSpeakExample,
  });

  final DictionaryEntry entry;
  final VoidCallback onSpeakWord;
  final VoidCallback? onSpeakExample;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.englishWord,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Pronounce',
                  icon: const Icon(Icons.volume_up_rounded),
                  onPressed: onSpeakWord,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              entry.myanmarMeaning,
              style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.primary),
            ),
            if (entry.example != null && entry.example!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      entry.example!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  if (onSpeakExample != null)
                    IconButton(
                      tooltip: 'Play example',
                      icon: const Icon(Icons.graphic_eq),
                      onPressed: onSpeakExample,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

