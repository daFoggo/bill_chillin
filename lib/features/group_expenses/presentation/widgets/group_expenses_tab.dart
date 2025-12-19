import 'package:bill_chillin/core/services/injection_container.dart';
import 'package:bill_chillin/features/group_expenses/presentation/bloc/group_detail/group_detail_bloc.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/category_bloc.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/widgets/monthly_tab_widget.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/widgets/total_balance_widget.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/widgets/transaction_bottom_sheet.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/widgets/transaction_list_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupExpensesTab extends StatefulWidget {
  final GroupDetailLoaded state;

  const GroupExpensesTab({super.key, required this.state});

  @override
  State<GroupExpensesTab> createState() => _GroupExpensesTabState();
}

class _GroupExpensesTabState extends State<GroupExpensesTab>
    with SingleTickerProviderStateMixin {
  late TabController _monthlyTabController;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    final initialIndex = DateTime.now().month - 1;
    _monthlyTabController = TabController(
      length: 12,
      vsync: this,
      initialIndex: initialIndex,
    );
    _monthlyTabController.addListener(_onMonthlyTabChanged);
  }

  @override
  void dispose() {
    _monthlyTabController.removeListener(_onMonthlyTabChanged);
    _monthlyTabController.dispose();
    super.dispose();
  }

  void _onMonthlyTabChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Filter transactions by selected month
    final selectedMonth = _monthlyTabController.index + 1;

    // Get available years from transactions
    final years =
        widget.state.transactions.map((tx) => tx.date.year).toSet().toList()
          ..sort((a, b) => b.compareTo(a)); // Descending order

    if (years.isEmpty) {
      years.add(DateTime.now().year);
    }

    // Ensure selected year is valid
    if (!years.contains(_selectedYear)) {
      if (years.contains(DateTime.now().year)) {
        _selectedYear = DateTime.now().year;
      } else {
        _selectedYear = years.first;
      }
    }

    final filteredTransactions = widget.state.transactions.where((tx) {
      return tx.date.month == selectedMonth && tx.date.year == _selectedYear;
    }).toList();

    final totalMonthExpense = filteredTransactions
        .where((tx) => tx.type != 'settlement')
        .fold(0.0, (sum, tx) => sum + tx.amount);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Year', style: Theme.of(context).textTheme.titleMedium),
              DropdownButton<int>(
                value: _selectedYear,
                items: years.map((year) {
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(year.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedYear = value;
                    });
                  }
                },
                underline: Container(), // Remove default underline
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        TotalBalanceWidget(totalBalance: totalMonthExpense),
        MonthlyTabWidget(tabController: _monthlyTabController),

        Expanded(
          child: filteredTransactions.isEmpty
              ? const Center(child: Text("No transactions this month"))
              : TransactionListWidget(
                  transactions: filteredTransactions,
                  onTap: (tx) => _showEditTransactionSheet(context, tx),
                  onDismissed: (tx) {
                    context.read<GroupDetailBloc>().add(
                      DeleteGroupTransactionEvent(
                        groupId: widget.state.group.id,
                        transactionId: tx.id,
                      ),
                    );
                  },
                  onLongPress: (tx) {},
                ),
        ),
      ],
    );
  }

  void _showEditTransactionSheet(BuildContext context, dynamic tx) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return MultiBlocProvider(
          providers: [BlocProvider(create: (_) => sl<CategoryBloc>())],
          child: TransactionBottomSheet(
            userId: user.uid,
            group: widget.state.group,
            memberDetails: widget.state.memberDetails,
            transaction: tx,
            onSave: (updatedTx) {
              context.read<GroupDetailBloc>().add(
                UpdateGroupTransactionEvent(transaction: updatedTx),
              );
              Navigator.pop(ctx);
            },
            onDelete: () {
              context.read<GroupDetailBloc>().add(
                DeleteGroupTransactionEvent(
                  groupId: widget.state.group.id,
                  transactionId: tx.id,
                ),
              );
              Navigator.pop(ctx);
            },
          ),
        );
      },
    );
  }
}
