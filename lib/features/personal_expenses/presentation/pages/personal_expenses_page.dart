import 'package:flutter/material.dart';

class PersonalExpensesPage extends StatelessWidget {
  const PersonalExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Personal Expenses")),
      body: const Center(child: Text("Personal Expenses Screen")),
    );
  }
}
