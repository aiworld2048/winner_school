import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'empty_state.dart';
import 'error_state.dart';

/// A reusable refreshable list widget that handles loading, error, and empty states
class RefreshableList<T> extends ConsumerWidget {
  const RefreshableList({
    super.key,
    required this.asyncValue,
    required this.itemBuilder,
    required this.onRefresh,
    this.emptyTitle,
    this.emptyMessage,
    this.emptyIcon,
    this.errorTitle,
    this.onRetry,
    this.padding,
    this.separatorBuilder,
    this.shrinkWrap = false,
    this.physics,
  });

  final AsyncValue<List<T>> asyncValue;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Future<void> Function() onRefresh;
  final String? emptyTitle;
  final String? emptyMessage;
  final IconData? emptyIcon;
  final String? errorTitle;
  final VoidCallback? onRetry;
  final EdgeInsets? padding;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: asyncValue.when(
        data: (items) {
          if (items.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: EmptyState(
                  title: emptyTitle ?? 'No items found',
                  message: emptyMessage,
                  icon: emptyIcon ?? Icons.inbox_outlined,
                ),
              ),
            );
          }

          if (separatorBuilder != null) {
            return ListView.separated(
              shrinkWrap: shrinkWrap,
              physics: physics ?? const AlwaysScrollableScrollPhysics(),
              padding: padding ?? const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: separatorBuilder!,
              itemBuilder: (context, index) => itemBuilder(context, items[index], index),
            );
          }

          return ListView.builder(
            shrinkWrap: shrinkWrap,
            physics: physics ?? const AlwaysScrollableScrollPhysics(),
            padding: padding ?? const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) => itemBuilder(context, items[index], index),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          final errorMessage = ErrorState.extractErrorMessage(error);
          return ErrorState(
            title: errorTitle ?? 'Error loading items',
            message: errorMessage,
            onRetry: onRetry,
          );
        },
      ),
    );
  }
}

