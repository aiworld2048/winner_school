import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/async_value_widget.dart';
import '../../../common/widgets/empty_state.dart';
import '../../media/providers/media_providers.dart';

class MediaHubScreen extends ConsumerWidget {
  const MediaHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promotions = ref.watch(mediaPromotionsProvider);
    final contacts = ref.watch(mediaContactsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('School updates')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Promotions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          AsyncValueWidget(
            value: promotions,
            builder: (items) {
              if (items.isEmpty) {
                return const EmptyState(title: 'No promotions for now');
              }
              return Column(
                children: items
                    .map(
                      (item) => Card(
                        child: ListTile(
                          title: Text(item.title),
                          subtitle: Text(item.body),
                          leading: const Icon(Icons.star_outline),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Contacts', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          AsyncValueWidget(
            value: contacts,
            builder: (items) {
              if (items.isEmpty) {
                return const EmptyState(title: 'Contact info unavailable');
              }
              return Column(
                children: items
                    .map(
                      (item) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.phone_outlined),
                          title: Text(item.label),
                          subtitle: Text(item.value),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

