import 'package:bill_chillin/core/util/currency_util.dart';
import 'package:flutter/material.dart';

import '../pages/review_scanned_transactions_page.dart';

class ReviewSummaryCard extends StatelessWidget {
  final ScanTargetMode selectedMode;
  final int totalItemCount;
  final double totalAmount;
  final ValueChanged<ScanTargetMode> onModeChanged;

  const ReviewSummaryCard({
    super.key,
    required this.selectedMode,
    required this.totalItemCount,
    required this.totalAmount,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<ScanTargetMode>(
            segments: const [
              ButtonSegment(
                value: ScanTargetMode.personal,
                icon: Icon(Icons.person),
                label: Text('Personal'),
              ),
              ButtonSegment(
                value: ScanTargetMode.group,
                icon: Icon(Icons.groups_3),
                label: Text('Group'),
              ),
            ],
            selected: {selectedMode},
            onSelectionChanged: (value) {
              onModeChanged(value.first);
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Items',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalItemCount',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Total amount value
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Amount',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyUtil.format(totalAmount),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
