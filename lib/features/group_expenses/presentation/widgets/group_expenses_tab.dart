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
    setState(() {}); // Rebuild to filter transactions
  }

  @override
  Widget build(BuildContext context) {
    // Filter transactions by selected month
    final selectedMonth = _monthlyTabController.index + 1;
    final currentYear = DateTime.now().year; // Simplified for now

    final filteredTransactions = widget.state.transactions.where((tx) {
      return tx.date.month == selectedMonth && tx.date.year == currentYear;
    }).toList();

    final totalMonthExpense = filteredTransactions
        .where((tx) => tx.type != 'settlement')
        .fold(0.0, (sum, tx) => sum + tx.amount);

    return Column(
      children: [
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
                  onLongPress: (tx) {
                    // TODO: Add options
                  },
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
