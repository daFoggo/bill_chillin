import 'package:bill_chillin/features/home/presentation/bloc/home_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DistributionChartCard extends StatefulWidget {
  final List<CategoryDistribution> expenseDistribution;
  final List<CategoryDistribution> incomeDistribution;

  const DistributionChartCard({
    super.key,
    required this.expenseDistribution,
    required this.incomeDistribution,
  });

  @override
  State<DistributionChartCard> createState() => _DistributionChartCardState();
}

class _DistributionChartCardState extends State<DistributionChartCard> {
  DistributionType _selectedType = DistributionType.expense;
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = _selectedType == DistributionType.expense;
    final distribution = isExpense
        ? widget.expenseDistribution
        : widget.incomeDistribution;

    // Fallback if empty
    final isEmpty = distribution.isEmpty;

    return Card(
      elevation: 0,
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Analytics",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Toggle Button
                SegmentedButton<DistributionType>(
                  segments: const [
                    ButtonSegment(
                      value: DistributionType.expense,
                      label: Text('Exp'),
                      icon: Icon(Icons.arrow_upward, size: 16),
                    ),
                    ButtonSegment(
                      value: DistributionType.income,
                      label: Text('Inc'),
                      icon: Icon(Icons.arrow_downward, size: 16),
                    ),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (Set<DistributionType> newSelection) {
                    setState(() {
                      _selectedType = newSelection.first;
                    });
                  },
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((
                      Set<MaterialState> states,
                    ) {
                      if (states.contains(MaterialState.selected)) {
                        return theme.colorScheme.primary;
                      }
                      return theme.colorScheme.secondaryContainer;
                    }),
                    foregroundColor: MaterialStateProperty.resolveWith<Color>((
                      Set<MaterialState> states,
                    ) {
                      if (states.contains(MaterialState.selected)) {
                        return theme.colorScheme.onPrimary;
                      }
                      return theme.colorScheme.onSurface;
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: isEmpty
                  ? Center(
                      child: Text(
                        "No data available",
                        style: TextStyle(color: theme.disabledColor),
                      ),
                    )
                  : PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                                });
                              },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _showingSections(theme, distribution),
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            // Legend
            if (!isEmpty)
              Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: distribution.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final color = _getColor(theme, index);
                  return _Indicator(
                    color: color,
                    text: data.categoryName,
                    isSquare: false,
                    size: 12,
                    textColor: theme.colorScheme.onSecondaryContainer,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _showingSections(
    ThemeData theme,
    List<CategoryDistribution> distribution,
  ) {
    return List.generate(distribution.length, (i) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      final data = distribution[i];
      final color = _getColor(theme, i);

      return PieChartSectionData(
        color: color,
        value: data.percentage * 100,
        title: '${(data.percentage * 100).toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimary,
        ),
      );
    });
  }

  Color _getColor(ThemeData theme, int index) {
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.error,
      theme.colorScheme.primaryContainer,
    ];
    return colors[index % colors.length];
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  const _Indicator({
    required this.color,
    required this.text,
    required this.isSquare,
    required this.size,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
