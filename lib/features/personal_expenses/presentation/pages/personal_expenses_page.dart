import 'package:bill_chillin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_state.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/personal_expenses_bloc.dart';
import 'package:bill_chillin/features/personal_expenses/domain/entities/transaction_entity.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/personal_expenses_event.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/personal_expenses_state.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/widgets/monthly_tab_widget.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/widgets/total_balance_widget.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/widgets/transaction_bottom_sheet.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/widgets/transaction_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PersonalExpensesPage extends StatelessWidget {
  const PersonalExpensesPage({super.key});

  static void showTransactionBottomSheet(
    BuildContext context, {
    TransactionEntity? transaction,
  }) {
    final authState = context.read<AuthBloc>().state;
    String userId = '';
    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
    }

    if (userId.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return TransactionBottomSheet(
          transaction: transaction,
          userId: userId,
          onSave: (newTransaction) {
            if (transaction == null) {
              context.read<PersonalExpensesBloc>().add(
                AddPersonalExpenseEvent(newTransaction),
              );
            } else {
              context.read<PersonalExpensesBloc>().add(
                UpdateTransactionEvent(newTransaction),
              );
            }
            Navigator.pop(ctx);
          },
          onDelete: transaction != null
              ? () {
                  context.read<PersonalExpensesBloc>().add(
                    DeleteTransactionEvent(transaction.id, userId),
                  );
                  Navigator.pop(ctx);
                }
              : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const PersonalExpensesView();
  }
}

class PersonalExpensesView extends StatefulWidget {
  const PersonalExpensesView({super.key});

  @override
  State<PersonalExpensesView> createState() => _PersonalExpensesViewState();
}

class _PersonalExpensesViewState extends State<PersonalExpensesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final initialIndex = DateTime.now().month - 1;
    _tabController = TabController(
      length: 12,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging)
      return;
    if (!_tabController.indexIsChanging) {
      final selectedMonth = DateTime(
        DateTime.now().year,
        _tabController.index + 1,
      );
      context.read<PersonalExpensesBloc>().add(ChangeMonthEvent(selectedMonth));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PersonalExpensesBloc, PersonalExpensesState>(
      listener: (context, state) {
        if (state is PersonalExpensesOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state is PersonalExpensesLoaded) {
          if (state.currentMonth.month != _tabController.index + 1) {
            _tabController.animateTo(state.currentMonth.month - 1);
          }
        }
      },
      builder: (context, state) {
        if (state is PersonalExpensesLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(strokeCap: StrokeCap.round),
            ),
          );
        }

        List<TransactionEntity> transactions = [];
        double totalBalance = 0;
        SortCriteria currentSort = SortCriteria.dateDesc;

        if (state is PersonalExpensesLoaded) {
          transactions = state.transactions;
          currentSort = state.sortCriteria;
          totalBalance = transactions.fold(0, (sum, t) {
            return sum + (t.type == 'income' ? t.amount : -t.amount);
          });
        }

        return Scaffold(
          body: SafeArea(
            child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Column(
                children: [
                  TotalBalanceWidget(
                    totalBalance: totalBalance,
                    currentSortCriteria: currentSort,
                    onSearch: (query) {
                      context.read<PersonalExpensesBloc>().add(
                        SearchTransactionEvent(query),
                      );
                    },
                    onSortSelected: (criteria) {
                      context.read<PersonalExpensesBloc>().add(
                        ChangeSortCriteriaEvent(criteria),
                      );
                    },
                  ),
                  MonthlyTabWidget(tabController: _tabController),
                  Expanded(
                    child: TransactionListWidget(
                      transactions: transactions,
                      onTap: (transaction) =>
                          PersonalExpensesPage.showTransactionBottomSheet(
                            context,
                            transaction: transaction,
                          ),
                      onDismissed: (transaction) {
                        final userId = transaction.userId;
                        context.read<PersonalExpensesBloc>().add(
                          DeleteTransactionEvent(transaction.id, userId),
                        );
                      },
                      onLongPress: (transaction) {
                
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
