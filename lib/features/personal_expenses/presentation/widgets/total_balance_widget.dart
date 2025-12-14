import 'package:bill_chillin/features/personal_expenses/presentation/bloc/personal_expenses_event.dart';
import 'package:flutter/material.dart';

class TotalBalanceWidget extends StatelessWidget {
  final double totalBalance;
  final Function(String)? onSearch;
  final Function(SortCriteria)? onSortSelected;
  final SortCriteria currentSortCriteria;

  const TotalBalanceWidget({
    super.key,
    required this.totalBalance,
    this.onSearch,
    this.onSortSelected,
    this.currentSortCriteria = SortCriteria.dateDesc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedBalance =
        "${totalBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ";

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: SearchBar(
                    hintText: "Search transactions...",
                    hintStyle: MaterialStateProperty.all(
                      theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    leading: Icon(
                      Icons.search,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    elevation: MaterialStateProperty.all(0),
                    backgroundColor: MaterialStateProperty.all(
                      theme.colorScheme.surfaceContainerHigh,
                    ),
                    onChanged: onSearch,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<SortCriteria>(
                icon: const Icon(Icons.sort),
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: theme.colorScheme.surface,
                surfaceTintColor: theme.colorScheme.surfaceTint,
                style: IconButton.styleFrom(
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                initialValue: currentSortCriteria,
                onSelected: onSortSelected,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: SortCriteria.dateDesc,
                    child: Row(
                      children: [
                        Icon(Icons.arrow_downward),
                        SizedBox(width: 8),
                        Text("Newest"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: SortCriteria.dateAsc,
                    child: Row(
                      children: [
                        Icon(Icons.arrow_upward),
                        SizedBox(width: 8),
                        Text("Oldest"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: SortCriteria.category,
                    child: Row(
                      children: [
                        Icon(Icons.category),
                        SizedBox(width: 8),
                        Text("By Category"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Total Balance",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formattedBalance,
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
