import 'package:flutter/material.dart';

class GroupExpensesPage extends StatelessWidget {
  const GroupExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Group Expenses",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const Center(child: Text("Group Expenses Screen")),
    );
  }
}
