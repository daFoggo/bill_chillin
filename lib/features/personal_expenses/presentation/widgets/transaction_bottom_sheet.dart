import 'package:bill_chillin/features/auth/domain/entities/user_entity.dart';
import 'package:bill_chillin/core/util/thousands_separator_input_formatter.dart';
import 'package:bill_chillin/core/util/currency_util.dart';
import 'package:bill_chillin/features/group_expenses/domain/entities/group_entity.dart';
import 'package:bill_chillin/features/personal_expenses/domain/entities/transaction_entity.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/category_bloc.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/category_event.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/category_state.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/widgets/create_category_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class TransactionBottomSheet extends StatefulWidget {
  final TransactionEntity? transaction;
  final String userId;
  final GroupEntity? group;
  final Function(TransactionEntity) onSave;
  final VoidCallback? onDelete;
  final Map<String, UserEntity> memberDetails;

  const TransactionBottomSheet({
    super.key,
    this.transaction,
    required this.userId,
    this.group,
    required this.onSave,
    this.onDelete,
    this.memberDetails = const {},
  });

  @override
  State<TransactionBottomSheet> createState() => _TransactionBottomSheetState();
}

class _TransactionBottomSheetState extends State<TransactionBottomSheet> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late String _type;
  late DateTime _selectedDate;
  List<Map<String, String>> _categories = [];
  late Map<String, String> _selectedCategory;

  // Group fields
  late String _payerId;
  late List<String> _selectedParticipants;

  // Default fallback categories
  final List<Map<String, String>> _defaultCategories = [
    {'id': '1', 'name': 'Food & Drink', 'icon': '🍔'},
    {'id': '2', 'name': 'Transport', 'icon': '🚗'},
    {'id': '3', 'name': 'Shopping', 'icon': '🛍️'},
    {'id': '4', 'name': 'Entertainment', 'icon': '🎬'},
    {'id': '5', 'name': 'Bills', 'icon': '💡'},
    {'id': '6', 'name': 'Salary', 'icon': '💰'},
  ];

  @override
  void initState() {
    super.initState();
    // Load fresh categories
    context.read<CategoryBloc>().add(LoadCategoriesEvent(widget.userId));

    _initializeData();
  }

  void _initializeData() {
    final t = widget.transaction;
    _amountController = TextEditingController(
      text: t != null ? CurrencyUtil.formatAmount(t.amount) : '',
    );
    _noteController = TextEditingController(text: t?.note ?? '');
    _type = t?.type ?? 'expense';
    _selectedDate = t?.date ?? DateTime.now();

    // Group defaults
    _payerId = t?.payerId ?? widget.userId;
    if (widget.group != null) {
      _selectedParticipants =
          t?.participants ?? List.from(widget.group!.members);
      // Ensure current user is in participants if new transaction default
      if (t == null && !_selectedParticipants.contains(widget.userId)) {
        // Assuming users usually pay for themselves too, or default to all group members
      }
    } else {
      _selectedParticipants = [];
    }

    // Initial category setup (will be updated by bloc listener if needed)
    if (t != null) {
      _selectedCategory = {
        'id': t.categoryId,
        'name': t.categoryName,
        'icon': t.categoryIcon,
      };
    } else {
      _selectedCategory = _defaultCategories.first;
    }
    _categories = List.from(_defaultCategories);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.transaction != null;
    final isGroupExpense = widget.group != null;

    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryLoaded) {
          setState(() {
            // Merge defaults with loaded dynamic categories
            final dynamicCats = state.categories
                .map(
                  (e) => {
                    'id': e.id,
                    'name': e.name,
                    'icon': e.icon,
                    'type': e.type,
                  },
                )
                .toList();

            // Optionally filter by type if needed, or just show all
            _categories = [..._defaultCategories, ...dynamicCats];
          });
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing
                    ? "Edit Transaction"
                    : (isGroupExpense
                          ? "New Group Expense"
                          : "New Transaction"),
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              if (!isGroupExpense) ...[
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
              ],

              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  suffixText: "đ",
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  ThousandsSeparatorInputFormatter(),
                ],
              ),
              const SizedBox(height: 16),

              if (isGroupExpense) ...[
                // Payer Selection
                InkWell(
                  onTap: _showPayerSelectionSheet,
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Paid By",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    child: Text(
                      _payerId == widget.userId
                          ? 'You'
                          : (widget.memberDetails[_payerId]?.name ??
                                widget.memberDetails[_payerId]?.email ??
                                _payerId),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Split Logic (Participants)
                ExpansionTile(
                  title: Text(
                    "Split Between (${_selectedParticipants.length})",
                  ),
                  children: widget.group!.members.map((memberId) {
                    final user = widget.memberDetails[memberId];
                    final displayName = memberId == widget.userId
                        ? 'You'
                        : (user?.name ?? user?.email ?? memberId);
                    return CheckboxListTile(
                      title: Text(displayName),
                      secondary: CircleAvatar(
                        backgroundImage: user?.avatarUrl != null
                            ? NetworkImage(user!.avatarUrl!)
                            : null,
                        child: user?.avatarUrl == null
                            ? Text(
                                displayName.isEmpty
                                    ? '?'
                                    : displayName[0].toUpperCase(),
                              )
                            : null,
                      ),
                      value: _selectedParticipants.contains(memberId),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedParticipants.add(memberId);
                          } else {
                            if (_selectedParticipants.length > 1) {
                              // Prevent empty
                              _selectedParticipants.remove(memberId);
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

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

              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: "Note",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

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
        ),
      ),
    );
  }

  void _submit() {
    final amountText = _amountController.text;
    if (amountText.isEmpty) return;

    final amount =
        double.tryParse(amountText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    Map<String, double>? splitDetails;
    if (widget.group != null) {
      // Split Logic: Equal split
      if (_selectedParticipants.isEmpty) {
        // Không có participants, không thể split
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one participant'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final splitAmount = amount / _selectedParticipants.length;
      splitDetails = {};
      for (var p in _selectedParticipants) {
        splitDetails[p] = splitAmount;
      }
    }

    // Đảm bảo transaction luôn có ID hợp lệ
    String transactionId;
    if (widget.transaction?.id != null && widget.transaction!.id.isNotEmpty) {
      transactionId = widget.transaction!.id;
    } else {
      transactionId = const Uuid().v4();
    }

    final transaction = TransactionEntity(
      id: transactionId,
      userId: widget.userId,
      amount: amount,
      type: widget.group != null ? 'expense' : _type,
      date: _selectedDate,
      categoryId: _selectedCategory['id']!,
      categoryName: _selectedCategory['name']!,
      categoryIcon: _selectedCategory['icon']!,
      note: _noteController.text,
      createdAt: widget.transaction?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      groupId: widget.group?.id,
      payerId: widget.group != null ? _payerId : null,
      participants: widget.group != null ? _selectedParticipants : null,
      splitDetails: splitDetails,
      status: widget.group != null ? 'confirmed' : 'completed',
    );

    // Gọi onSave và xử lý cả sync và async
    final result = widget.onSave(transaction);
    // Nếu onSave trả về Future, không cần await ở đây vì onSave callback sẽ tự xử lý
    // Nhưng để đảm bảo, nếu result là Future thì có thể log
    if (result is Future) {
      result.catchError((error) {
        debugPrint('Error in onSave callback: $error');
      });
    }
  }

  void _showCategorySelectionSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      scrollControlDisabledMaxHeightRatio: 0.8,
      builder: (modalContext) {
        return SizedBox(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select Category",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // Use 'context' from State, not 'modalContext'
                        final categoryBloc = context.read<CategoryBloc>();
                        Navigator.pop(modalContext); // Close selection sheet
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          builder: (_) => BlocProvider.value(
                            value: categoryBloc,
                            child: CreateCategorySheet(userId: widget.userId),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Create"),
                    ),
                  ],
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

  void _showPayerSelectionSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      scrollControlDisabledMaxHeightRatio: 0.8,
      builder: (modalContext) {
        return SizedBox(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select Payer",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.group!.members.length,
                  itemBuilder: (ctx, index) {
                    final memberId = widget.group!.members[index];
                    final user = widget.memberDetails[memberId];
                    final displayName = memberId == widget.userId
                        ? 'You'
                        : (user?.name ?? user?.email ?? memberId);
                    final isSelected = memberId == _payerId;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user?.avatarUrl != null
                            ? NetworkImage(user!.avatarUrl!)
                            : null,
                        child: user?.avatarUrl == null
                            ? Text(
                                displayName.isEmpty
                                    ? '?'
                                    : displayName[0].toUpperCase(),
                              )
                            : null,
                      ),
                      title: Text(displayName),
                      selected: isSelected,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      trailing: isSelected ? const Icon(Icons.check) : null,
                      onTap: () {
                        setState(() {
                          _payerId = memberId;
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
