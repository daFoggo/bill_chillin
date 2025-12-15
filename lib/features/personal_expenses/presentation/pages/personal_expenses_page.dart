import 'package:bill_chillin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_state.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/personal_expenses_bloc.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/category_bloc.dart';
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

    final personalExpensesBloc = context.read<PersonalExpensesBloc>();
    final categoryBloc = context.read<CategoryBloc>();

    if (userId.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: personalExpensesBloc),
            BlocProvider.value(value: categoryBloc),
          ],
          child: TransactionBottomSheet(
            transaction: transaction,
            userId: userId,
            onSave: (newTransaction) {
              if (transaction == null) {
                personalExpensesBloc.add(
                  AddPersonalExpenseEvent(newTransaction),
                );
              } else {
                personalExpensesBloc.add(
                  UpdateTransactionEvent(newTransaction),
                );
              }
              Navigator.pop(ctx);
            },
            onDelete: transaction != null
                ? () {
                    personalExpensesBloc.add(
                      DeleteTransactionEvent(transaction.id, userId),
                    );
                    Navigator.pop(ctx);
                  }
                : null,
          ),
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

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
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
        if (state is PersonalExpensesLoaded && _searchController.text.isEmpty) {
          // Reset search text if needed, or keep it sync if state has query
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
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 0,
            title: SizedBox(
              height: 45,
              child: SearchBar(
                controller: _searchController,
                hintText: "Search transactions...",
                hintStyle: WidgetStateProperty.all(
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                leading: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                elevation: WidgetStateProperty.all(0),
                backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
                onChanged: (query) {
                  context.read<PersonalExpensesBloc>().add(
                    SearchTransactionEvent(query),
                  );
                },
              ),
            ),
            actions: [
              PopupMenuButton<SortCriteria>(
                icon: Icon(
                  Icons.sort,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Theme.of(context).colorScheme.surface,
                surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
                initialValue: currentSort,
                onSelected: (criteria) {
                  context.read<PersonalExpensesBloc>().add(
                    ChangeSortCriteriaEvent(criteria),
                  );
                },
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
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Column(
                children: [
                  TotalBalanceWidget(totalBalance: totalBalance),
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
                      onLongPress: (transaction) {},
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
