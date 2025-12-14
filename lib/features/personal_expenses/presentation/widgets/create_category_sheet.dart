import 'package:bill_chillin/features/personal_expenses/domain/entities/category_entity.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/category_bloc.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/category_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class CreateCategorySheet extends StatefulWidget {
  final String userId;

  const CreateCategorySheet({super.key, required this.userId});

  @override
  State<CreateCategorySheet> createState() => _CreateCategorySheetState();
}

class _CreateCategorySheetState extends State<CreateCategorySheet> {
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();
  String _type = 'expense';

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final icon = _iconController.text.trim();

    if (name.isEmpty || icon.isEmpty) {
      return;
    }

    final newCategory = CategoryEntity(
      id: const Uuid().v4(),
      name: name,
      icon: icon,
      userId: widget.userId,
      type: _type,
    );

    context.read<CategoryBloc>().add(AddCategoryEvent(newCategory));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Create New Category",
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Type Selector
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'expense', label: Text('Expense')),
              ButtonSegment(value: 'income', label: Text('Income')),
            ],
            selected: {_type},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _type = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 16),
          // Name Input
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Category Name",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label),
            ),
          ),
          const SizedBox(height: 16),
          // Icon Input (Emoji)
          TextField(
            controller: _iconController,
            maxLength: 1, // Limit to 1 char (emoji usually)
            decoration: const InputDecoration(
              labelText: "Icon (Emoji)",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.emoji_emotions),
              counterText: "",
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submit,
            child: const Text("Create Category"),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
