import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/async_value_widget.dart';
import '../../../common/widgets/empty_state.dart';
import '../../media/providers/media_providers.dart';
import '../../media/models/media_models.dart';

class MediaHubScreen extends ConsumerWidget {
  const MediaHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banners = ref.watch(mediaBannersProvider);
    final promotions = ref.watch(mediaPromotionsProvider);
    final contacts = ref.watch(mediaContactsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('School updates')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Highlights', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: AsyncValueWidget(
              value: banners,
              builder: (items) => items.isEmpty
                  ? const EmptyState(title: 'No banners')
                  : PageView.builder(
                      controller: PageController(viewportFraction: 0.9),
                      itemCount: items.length,
                      itemBuilder: (_, index) => _BannerCard(item: items[index]),
                    ),
            ),
          ),
          const SizedBox(height: 24),
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

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.item});

  final MediaBanner item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.image.isNotEmpty)
              Image.network(
                item.image,
                fit: BoxFit.cover,
              )
            else
              Container(color: Colors.blueGrey.shade100),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black.withValues(alpha: 0.4),
                child: Text(
                  item.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

