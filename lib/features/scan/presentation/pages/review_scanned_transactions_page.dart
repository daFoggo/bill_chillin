import 'package:bill_chillin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_state.dart';
import 'package:bill_chillin/core/services/injection_container.dart';
import 'package:bill_chillin/features/personal_expenses/domain/entities/transaction_entity.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/personal_expenses_bloc.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/personal_expenses_event.dart';
import 'package:bill_chillin/features/scan/domain/entities/scanned_transaction.dart';
import 'package:bill_chillin/features/group_expenses/domain/usecases/add_group_transaction_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ScanTargetMode {
  personal,
  group,
}

class ReviewScannedTransactionsPage extends StatefulWidget {
  final List<ScannedTransaction> scannedTransactions;
  final String? initialGroupId;
  final Map<String, String> groupMembers; // memberId -> memberName

  const ReviewScannedTransactionsPage({
    super.key,
    this.scannedTransactions = const [],
    this.initialGroupId,
    this.groupMembers = const {},
  });

  @override
  State<ReviewScannedTransactionsPage> createState() =>
      _ReviewScannedTransactionsPageState();
}

class _ReviewScannedTransactionsPageState
    extends State<ReviewScannedTransactionsPage> {
  ScanTargetMode _mode = ScanTargetMode.personal;
  String? _selectedGroupId;
  final Set<String> _selectedMembers = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _selectedGroupId ??= widget.initialGroupId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review scanned transactions'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SegmentedButton<ScanTargetMode>(
              segments: const [
                ButtonSegment(
                  value: ScanTargetMode.personal,
                  icon: Icon(Icons.person),
                  label: Text('Personal'),
                ),
                ButtonSegment(
                  value: ScanTargetMode.group,
                  icon: Icon(Icons.groups_3),
                  label: Text('Group'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (value) {
                setState(() {
                  _mode = value.first;
                });
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _mode == ScanTargetMode.personal
                    ? 'Preview for personal expenses will be shown here'
                    : 'Preview for group expenses with member selection will be shown here',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Detected items: ${widget.scannedTransactions.length}',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 24),
              if (_mode == ScanTargetMode.group) _buildGroupSelectors(theme),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () => _onSave(context),
            child: Text(
              _mode == ScanTargetMode.personal
                  ? 'Save to personal'
                  : 'Save to group',
            ),
          ),
        ),
      ),
    );
  }

  void _onSave(BuildContext context) {
    if (widget.scannedTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No scanned items to save')),
      );
      return;
    }

    if (_mode == ScanTargetMode.personal) {
      _saveToPersonal(context);
    } else {
      _saveToGroup(context);
    }
  }

  void _saveToPersonal(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be signed in to save data')),
      );
      return;
    }

    final userId = authState.user.id;
    final now = DateTime.now();

    final bloc = context.read<PersonalExpensesBloc>();

    for (final scanned in widget.scannedTransactions) {
      final tx = TransactionEntity(
        id: '', // Repository/Firestore will generate the ID
        userId: userId,
        amount: scanned.amount,
        currency: 'VND',
        type: 'expense',
        date: scanned.date,
        categoryId: 'uncategorized',
        categoryName: 'Uncategorized',
        categoryIcon: 'help_outline',
        note: scanned.description,
        searchKeywords: const [],
        status: 'draft',
        imageUrl: null,
        createdAt: now,
        updatedAt: null,
        groupId: null,
        groupName: null,
        payerId: null,
        participants: null,
        splitDetails: null,
      );

      bloc.add(AddPersonalExpenseEvent(tx));
    }

    Navigator.pop(context);
  }

  void _saveToGroup(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be signed in to save data')),
      );
      return;
    }

    if (_selectedGroupId == null || _selectedGroupId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a group')),
      );
      return;
    }

    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one member')),
      );
      return;
    }

    final evenSplitter = _EvenSplitHelper(
      members: _selectedMembers.toList(),
    );
    final now = DateTime.now();
    final addGroupTransaction = sl<AddGroupTransactionUseCase>();

    Future.wait(
      widget.scannedTransactions.map((scanned) async {
        final splitDetails = evenSplitter.split(scanned.amount);
        final tx = TransactionEntity(
          id: '',
          userId: user.uid,
          amount: scanned.amount,
          currency: 'VND',
          type: 'expense',
          date: scanned.date,
          categoryId: 'uncategorized',
          categoryName: 'Uncategorized',
          categoryIcon: 'help_outline',
          note: scanned.description,
          searchKeywords: const [],
          status: 'draft',
          imageUrl: null,
          createdAt: now,
          updatedAt: null,
          groupId: _selectedGroupId,
          groupName: null,
          payerId: user.uid,
          participants: _selectedMembers.toList(),
          splitDetails: splitDetails,
        );

        final result = await addGroupTransaction(
          AddGroupTransactionParams(
            groupId: _selectedGroupId!,
            transaction: tx,
          ),
        );

        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save: ${failure.toString()}')),
          ),
          (_) => null,
        );
      }),
    ).then((_) => Navigator.pop(context));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saving to group...')),
    );
  }

  Widget _buildGroupSelectors(ThemeData theme) {
    final members = widget.groupMembers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Group (optional if passed from previous screen)',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: _selectedGroupId ?? ''),
          decoration: const InputDecoration(
            labelText: 'Group ID',
            hintText: 'Enter group id',
          ),
          onChanged: (value) => _selectedGroupId = value.trim(),
        ),
        const SizedBox(height: 16),
        if (members.isEmpty)
          Text(
            'No member list provided. Please reopen this screen with group members to enable selection.',
            style: theme.textTheme.bodySmall,
          )
        else ...[
          Text(
            'Select members to split evenly',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: members.entries.map((entry) {
              final isSelected = _selectedMembers.contains(entry.key);
              return FilterChip(
                label: Text(entry.value.isNotEmpty ? entry.value : entry.key),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedMembers.add(entry.key);
                    } else {
                      _selectedMembers.remove(entry.key);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _EvenSplitHelper {
  final List<String> members;

  _EvenSplitHelper({required this.members});

  Map<String, double> split(double amount) {
    if (members.isEmpty) return {};
    final share = amount / members.length;
    return {for (final m in members) m: share};
  }
}



