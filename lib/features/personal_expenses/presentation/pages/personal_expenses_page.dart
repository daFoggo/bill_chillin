import 'package:bill_chillin/core/services/injection_container.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_state.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/personal_expenses_bloc.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/personal_expenses_event.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/personal_expenses_state.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/widgets/transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PersonalExpensesPage extends StatelessWidget {
  const PersonalExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final authState = context.read<AuthBloc>().state;
        String userId = '';
        if (authState is AuthAuthenticated) {
          userId = authState.user.id;
        } // Handle unauthenticated state if necessary (though MainScreen guards it)

        return sl<PersonalExpensesBloc>()
          ..add(LoadPersonalExpensesEvent(userId));
      },
      child: const PersonalExpensesView(),
    );
  }
}

class PersonalExpensesView extends StatelessWidget {
  const PersonalExpensesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Personal Expenses"), centerTitle: true),
      body: BlocBuilder<PersonalExpensesBloc, PersonalExpensesState>(
        builder: (context, state) {
          if (state is PersonalExpensesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PersonalExpensesError) {
            return Center(child: Text("Error: ${state.message}"));
          } else if (state is PersonalExpensesLoaded) {
            if (state.transactions.isEmpty) {
              return const Center(child: Text("No transactions yet."));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                return TransactionItem(transaction: state.transactions[index]);
              },
            );
          }
          return const Center(child: Text("Start adding expenses!"));
        },
      ),
    );
  }
}
