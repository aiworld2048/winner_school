import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../core/constants/api_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../providers/language_provider.dart';
import '../utils/game_launcher.dart';

class GameSection extends StatefulWidget {
  const GameSection({
    super.key,
    required this.gameProvider,
    required this.onLoginRequired,
    required this.isAuthenticated,
  });

  final GameProvider gameProvider;
  final VoidCallback onLoginRequired;
  final bool isAuthenticated;

  @override
  State<GameSection> createState() => _GameSectionState();
}

class _GameSectionState extends State<GameSection> {
  String? _launchingGameId;

  Future<void> _launchGame(Map<String, dynamic> game) async {
    final auth = context.read<AuthProvider>();
    if (!widget.isAuthenticated || auth.token == null || auth.token!.isEmpty) {
      widget.onLoginRequired();
      return;
    }

    final gameCode = game['game_code']?.toString();
    final productCode =
        (game['product_code'] ?? game['provider_code'])?.toString();
    final gameType = game['game_type']?.toString() ??
        widget.gameProvider.selectedTypeId?.toString();

    if (gameCode == null || productCode == null || gameType == null) {
      _showSnack('Missing game launch data. Please try another game.');
      return;
    }

    final itemId = game['id']?.toString() ?? '$gameCode-$productCode';

    setState(() {
      _launchingGameId = itemId;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.url(ApiConstants.launchGame)),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.token}',
        },
        body: jsonEncode({
          'game_code': gameCode,
          'product_code': productCode,
          'game_type': gameType,
        }),
      );

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final code = decoded['code'];

      if (response.statusCode == 200 && (code == 200 || code == 1)) {
        final url = decoded['url']?.toString() ?? decoded['Url']?.toString();
        final content = decoded['content']?.toString();

        if (!mounted) return;
        await GameLauncher.launch(
          context,
          url: url,
          htmlContent: content,
          title: game['game_name']?.toString() ?? 'Game',
        );
      } else {
        final message = decoded['message']?.toString() ??
            decoded['msg']?.toString() ??
            'Failed to launch game.';
        _showSnack(message);
      }
    } catch (e) {
      _showSnack('Failed to launch game: $e');
    } finally {
      if (mounted) {
        setState(() {
          _launchingGameId = null;
        });
      }
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openBuffalo() {
    GoRouter.of(context).push('/buffalo');
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    final content = language.content;
    final gameProvider = widget.gameProvider;

    if (gameProvider.isLoadingTypes && gameProvider.types.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredTypes = gameProvider.types
        .where((type) {
          final id = int.tryParse(type['id'].toString()) ?? 0;
          return ![6, 12, 13, 14].contains(id);
        })
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GameTabsBar(
          types: filteredTypes,
          provider: gameProvider,
          content: content,
          onBuffaloTap: _openBuffalo,
        ),
        const SizedBox(height: 20),
        if (gameProvider.viewMode == 'hot')
          GameGrid(
            games: gameProvider.currentGames,
            isLoading: gameProvider.isLoadingGames,
            noDataText: content['no_data'] as String? ?? 'No games',
            isAuthenticated: widget.isAuthenticated,
            onLoginRequired: widget.onLoginRequired,
            onLaunchGame: _launchGame,
            launchingGameId: _launchingGameId,
            hasMore: false,
            isLoadingMore: false,
            onLoadMore: null,
          )
        else if (gameProvider.viewMode == 'type' &&
            gameProvider.selectedTypeId != null &&
            gameProvider.selectedProviderId == null)
          ProviderGridSection(
            type: filteredTypes.firstWhere(
              (type) =>
                  int.tryParse(type['id'].toString()) ==
                  gameProvider.selectedTypeId,
              orElse: () => filteredTypes.first,
            ),
            provider: gameProvider,
            onProviderSelected: (typeId, providerId) async {
              await gameProvider.selectType(typeId);
              await gameProvider.selectProvider(providerId);
            },
          )
        else if (gameProvider.viewMode == 'type' &&
            gameProvider.selectedProviderId != null)
          GameGrid(
            games: gameProvider.currentGames,
            isLoading: gameProvider.isLoadingGames,
            noDataText: content['no_data'] as String? ?? 'No games',
            isAuthenticated: widget.isAuthenticated,
            onLoginRequired: widget.onLoginRequired,
            onLaunchGame: _launchGame,
            launchingGameId: _launchingGameId,
            hasMore: gameProvider.hasMoreGames,
            isLoadingMore: gameProvider.isLoadingMoreGames,
            onLoadMore: gameProvider.loadMoreGames,
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: filteredTypes
                .map(
                  (type) => ProviderGridSection(
                    type: type,
                    provider: gameProvider,
                    onProviderSelected: (typeId, providerId) async {
                      await gameProvider.selectType(typeId);
                      await gameProvider.selectProvider(providerId);
                    },
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class GameTabsBar extends StatelessWidget {
  const GameTabsBar({
    super.key,
    required this.types,
    required this.provider,
    required this.content,
    required this.onBuffaloTap,
  });

  final List<Map<String, dynamic>> types;
  final GameProvider provider;
  final Map<String, dynamic> content;
  final VoidCallback onBuffaloTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          const SizedBox(width: 4),
          _BuffaloTabButton(onTap: onBuffaloTap),
          _TabButton(
            label: content['game_type']?['all'] as String? ?? 'All',
            isActive: provider.viewMode == 'all',
            onTap: () => provider.selectAll(),
          ),
          _TabButton(
            label: content['game_type']?['hot'] as String? ?? 'Hot',
            isActive: provider.viewMode == 'hot',
            onTap: () => provider.selectHot(),
          ),
          for (final type in types)
            _TabButton(
              label: type['name']?.toString() ?? 'Type',
              isActive: provider.viewMode == 'type' &&
                  provider.selectedTypeId ==
                      int.tryParse(type['id'].toString()),
              onTap: () {
                final id = int.tryParse(type['id'].toString());
                if (id != null) {
                  provider.selectType(id);
                }
              },
            ),
        ],
      ),
    );
  }
}

class _BuffaloTabButton extends StatelessWidget {
  const _BuffaloTabButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 90,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x33000000)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'lib/assets/buffalo/af.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Buffalo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 90,
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                  )
                : const LinearGradient(
                    colors: [Color(0xFF23243A), Color(0xFF23243A)],
                  ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0x33000000),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Center(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isActive ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProviderGridSection extends StatelessWidget {
  const ProviderGridSection({
    super.key,
    required this.type,
    required this.provider,
    required this.onProviderSelected,
  });

  final Map<String, dynamic> type;
  final GameProvider provider;
  final Future<void> Function(int typeId, int providerId) onProviderSelected;

  @override
  Widget build(BuildContext context) {
    final typeId = int.tryParse(type['id'].toString());
    final typeName = type['name']?.toString() ?? 'Providers';

    if (typeId == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            typeName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: provider.providersForType(typeId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final providers = snapshot.data ?? [];
              if (providers.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No providers available'),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: providers.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final item = providers[index];
                  final imageUrl = resolveImageUrl(item['img_url']?.toString());
                  final label =
                      item['product_title']?.toString() ??
                      item['product_name']?.toString() ??
                      'Provider';
                  final providerId =
                      int.tryParse(item['id'].toString()) ?? index;
                  return GestureDetector(
                    onTap: () => onProviderSelected(typeId, providerId),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0x26FFFFFF)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x59000000),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.black54,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.videogame_asset,
                                    color: Color(0xFFFFD700),
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0x00000000),
                                      Color(0xCC000000),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0x33FFFFFF),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.sports_esports,
                                            size: 14,
                                            color: Color(0xFFFFD700),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'View Games',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class GameGrid extends StatelessWidget {
  const GameGrid({
    super.key,
    required this.games,
    required this.isLoading,
    required this.noDataText,
    required this.onLoginRequired,
    required this.isAuthenticated,
    required this.onLaunchGame,
    required this.launchingGameId,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
  });

  final List<Map<String, dynamic>> games;
  final bool isLoading;
  final String noDataText;
  final VoidCallback onLoginRequired;
  final bool isAuthenticated;
  final Future<void> Function(Map<String, dynamic>) onLaunchGame;
  final String? launchingGameId;
  final bool hasMore;
  final bool isLoadingMore;
  final Future<void> Function()? onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (games.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(noDataText),
        ),
      );
    }
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: games.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.72,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final item = games[index];
            final imageUrl = resolveImageUrl(item['image_url']?.toString());
            final itemId =
                item['id']?.toString() ?? '${item['game_code']}_${item['product_code']}';
            final isLaunching =
                launchingGameId != null && launchingGameId == itemId;
            final providerName = item['provider_name']?.toString() ??
                item['product_title']?.toString() ??
                'Slot';

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFF8A00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x59000000),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.black,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.sports_esports,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x10000000),
                              Color(0xCC000000),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x8C000000),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.flash_on,
                              size: 14,
                              color: Color(0xFFFFD700),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              providerName,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAuthenticated
                                ? const Color(0xFFFFD700)
                                : const Color(0x33000000),
                            foregroundColor: isAuthenticated
                                ? Colors.black
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          onPressed: isAuthenticated
                              ? () => onLaunchGame(item)
                              : onLoginRequired,
                          child: isAuthenticated
                              ? (isLaunching
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Play Now'))
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.lock_open_outlined,
                                      size: 14,
                                    ),
                                    SizedBox(width: 6),
                                    Text('Login to Play'),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (hasMore || isLoadingMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: isLoadingMore ? null : onLoadMore,
              child: isLoadingMore
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Load More'),
            ),
          ),
      ],
    );
  }
}

