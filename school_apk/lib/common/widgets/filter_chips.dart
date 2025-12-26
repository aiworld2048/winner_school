import 'package:flutter/material.dart';

/// A reusable filter chips widget for status filtering
class StatusFilterChips extends StatelessWidget {
  const StatusFilterChips({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    this.statuses = const ['all', 'published', 'draft'],
    this.labels = const {'all': 'All', 'published': 'Published', 'draft': 'Draft'},
  });

  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;
  final List<String> statuses;
  final Map<String, String> labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((status) {
        final isSelected = selectedStatus == status || (status == 'all' && selectedStatus == null);
        return FilterChip(
          label: Text(labels[status] ?? status),
          selected: isSelected,
          onSelected: (selected) {
            onStatusChanged(selected ? (status == 'all' ? null : status) : null);
          },
        );
      }).toList(),
    );
  }
}

/// A reusable filter section widget
class FilterSection extends StatelessWidget {
  const FilterSection({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }
}

