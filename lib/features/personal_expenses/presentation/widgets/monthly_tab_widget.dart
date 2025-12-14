import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyTabWidget extends StatelessWidget {
  final TabController tabController;

  const MonthlyTabWidget({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    // Generate list of months for the current year
    final now = DateTime.now();
    final months = List.generate(12, (index) {
      return DateTime(now.year, index + 1);
    });

    return TabBar(
      controller: tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      tabs: months.map((month) {
        return Tab(text: DateFormat('MMM').format(month));
      }).toList(),
    );
  }
}
