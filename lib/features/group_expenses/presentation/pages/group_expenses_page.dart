import 'package:flutter/material.dart';

class GroupExpensesPage extends StatelessWidget {
  const GroupExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Group Expenses")),
      body: const Center(child: Text("Group Expenses Screen")),
    );
  }
}
