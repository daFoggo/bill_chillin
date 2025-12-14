import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinancialTrendChartCard extends StatelessWidget {
  final Map<int, double> monthlyExpenseTrends;
  final Map<int, double> monthlyIncomeTrends;

  const FinancialTrendChartCard({
    super.key,
    required this.monthlyExpenseTrends,
    required this.monthlyIncomeTrends,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Prepare spots
    final expenseSpots = _prepareSpots(monthlyExpenseTrends);
    final incomeSpots = _prepareSpots(monthlyIncomeTrends);

    // Calculate Max Y for scale
    double maxY = 0;
    for (final spot in [...expenseSpots, ...incomeSpots]) {
      if (spot.y > maxY) maxY = spot.y;
    }
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100000;

    return Card(
      elevation: 0,
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Financial Trends",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Legend
                Row(
                  children: [
                    _LegendItem(color: theme.colorScheme.tertiary, label: "Exp"),
                    const SizedBox(width: 8),
                    _LegendItem(color: theme.colorScheme.primary, label: "Inc"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1, 
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          );
                          String text;
                          switch (value.toInt()) {
                            case 1: text = 'Jan'; break;
                            case 3: text = 'Mar'; break;
                            case 5: text = 'May'; break;
                            case 7: text = 'Jul'; break;
                            case 9: text = 'Sep'; break;
                            case 11: text = 'Nov'; break;
                            default: return Container();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(text, style: style),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 1,
                  maxX: 12,
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    // Expense Line
                    LineChartBarData(
                      spots: expenseSpots,
                      isCurved: true,
                      color: theme.colorScheme.tertiary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                    ),
                    // Income Line
                    LineChartBarData(
                      spots: incomeSpots,
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                  // Tooltips
                  showingTooltipIndicators: [
                    ...expenseSpots.where((s) => s.y > 0).map((s) => ShowingTooltipIndicators([
                      LineBarSpot(
                        LineChartBarData(spots: expenseSpots),
                        0,
                        s,
                      )
                    ])),
                    ...incomeSpots.where((s) => s.y > 0).map((s) => ShowingTooltipIndicators([
                      LineBarSpot(
                         LineChartBarData(spots: incomeSpots),
                         1,
                         s,
                      )
                    ])),
                  ],
                  lineTouchData: LineTouchData(
                     enabled: false,
                     touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => Colors.transparent,
                        tooltipPadding: const EdgeInsets.only(bottom: 8),
                         getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((barSpot) {
                            final formatter = NumberFormat.compact();
                            final isIncome = barSpot.barIndex == 1; // 1 is Income
                            return LineTooltipItem(
                              formatter.format(barSpot.y),
                              TextStyle(
                                color: isIncome ? theme.colorScheme.primary : theme.colorScheme.tertiary, 
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            );
                          }).toList();
                        },
                     ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _prepareSpots(Map<int, double> data) {
    final List<FlSpot> spots = [];
    for (int i = 1; i <= 12; i++) {
        spots.add(FlSpot(i.toDouble(), data[i] ?? 0));
    }
    return spots;
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
