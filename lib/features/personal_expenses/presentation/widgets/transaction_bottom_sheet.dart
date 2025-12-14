import 'package:bill_chillin/features/personal_expenses/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class TransactionBottomSheet extends StatefulWidget {
  final TransactionEntity? transaction;
  final String userId;
  final Function(TransactionEntity) onSave;
  final VoidCallback? onDelete;

  const TransactionBottomSheet({
    super.key,
    this.transaction,
    required this.userId,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<TransactionBottomSheet> createState() => _TransactionBottomSheetState();
}

class _TransactionBottomSheetState extends State<TransactionBottomSheet> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late String _type;
  late DateTime _selectedDate;

  // Dummy Categories (for now)
  final List<Map<String, String>> _categories = [
    {'id': '1', 'name': 'Food & Drink', 'icon': '🍔'},
    {'id': '2', 'name': 'Transport', 'icon': '🚗'},
    {'id': '3', 'name': 'Shopping', 'icon': '🛍️'},
    {'id': '4', 'name': 'Entertainment', 'icon': '🎬'},
    {'id': '5', 'name': 'Bills', 'icon': '💡'},
    {'id': '6', 'name': 'Salary', 'icon': '💰'}, // Income example
  ];
  late Map<String, String> _selectedCategory;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _amountController = TextEditingController(
      text: t != null ? t.amount.toStringAsFixed(0) : '',
    );
    _noteController = TextEditingController(text: t?.note ?? '');
    _type = t?.type ?? 'expense';
    _selectedDate = t?.date ?? DateTime.now();

    if (t != null) {
      // Try to find existing category or default
      _selectedCategory = _categories.firstWhere(
        (c) => c['id'] == t.categoryId,
        orElse: () => {
          'id': t.categoryId,
          'name': t.categoryName,
          'icon': t.categoryIcon,
        },
      );
    } else {
      _selectedCategory = _categories.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.transaction != null;

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
            isEditing ? "Edit Transaction" : "New Transaction",
            style: theme.textTheme.titleLarge,
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

          // Amount
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Amount",
              suffixText: "đ",
              border: OutlineInputBorder(),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),

          // Category Selector
          InkWell(
            onTap: _showCategorySelectionSheet,
            borderRadius: BorderRadius.circular(4),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              child: Row(
                children: [
                  Text(_selectedCategory['icon']!),
                  const SizedBox(width: 8),
                  Text(_selectedCategory['name']!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Date Picker
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: "Date",
                border: OutlineInputBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Note
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: "Note",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              if (isEditing && widget.onDelete != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete),
                    label: const Text("Delete"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                  ),
                ),
              if (isEditing && widget.onDelete != null)
                const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _submit,
                  child: Text(isEditing ? "Save" : "Create"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _submit() {
    final amountText = _amountController.text;
    if (amountText.isEmpty) return;

    final amount = double.tryParse(amountText) ?? 0;

    final transaction = TransactionEntity(
      id: widget.transaction?.id ?? const Uuid().v4(), // Generate ID if new
      userId: widget.userId,
      amount: amount,
      type: _type,
      date: _selectedDate,
      categoryId: _selectedCategory['id']!,
      categoryName: _selectedCategory['name']!,
      categoryIcon: _selectedCategory['icon']!,
      note: _noteController.text,
      createdAt: widget.transaction?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(transaction);
  }

  void _showCategorySelectionSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      scrollControlDisabledMaxHeightRatio: 0.8,
      builder: (context) {
        return SizedBox(
          // height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Select Category",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _categories.length,
                  itemBuilder: (ctx, index) {
                    final cat = _categories[index];
                    final isSelected = cat['id'] == _selectedCategory['id'];
                    return ListTile(
                      leading: Text(
                        cat['icon']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(cat['name']!),
                      selected: isSelected,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      trailing: isSelected ? const Icon(Icons.check) : null,
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
