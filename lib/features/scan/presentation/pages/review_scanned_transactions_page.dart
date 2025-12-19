import 'package:bill_chillin/core/services/injection_container.dart';
import 'package:bill_chillin/core/util/currency_util.dart';
import 'package:bill_chillin/features/auth/domain/entities/user_entity.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bill_chillin/features/auth/presentation/bloc/auth_state.dart';
import 'package:bill_chillin/features/group_expenses/domain/entities/group_entity.dart';
import 'package:bill_chillin/features/group_expenses/domain/repositories/group_repository.dart';
import 'package:bill_chillin/features/group_expenses/domain/usecases/add_group_transaction_usecase.dart';
import 'package:bill_chillin/features/group_expenses/domain/usecases/get_group_member_details_usecase.dart';
import 'package:bill_chillin/features/group_expenses/presentation/bloc/group_list/group_list_bloc.dart';
import 'package:bill_chillin/features/personal_expenses/domain/entities/transaction_entity.dart';
import 'package:bill_chillin/features/personal_expenses/domain/repositories/personal_expenses_repository.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/widgets/transaction_item.dart';
import 'package:bill_chillin/features/scan/domain/entities/scanned_transaction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

enum ScanTargetMode { personal, group }

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
  String? _selectedPayerId; // Who paid
  Map<String, UserEntity> _memberDetails = {}; // memberId -> UserEntity
  GroupEntity? _selectedGroup;

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.initialGroupId;
    if (widget.groupMembers.isNotEmpty) {
      _memberDetails = {
        for (var entry in widget.groupMembers.entries)
          entry.key: UserEntity(
            id: entry.key,
            email: entry.value,
            name: entry.value,
          ),
      };
    }
    // Set initial mode based on groupId presence
    if (_selectedGroupId != null) {
      _mode = ScanTargetMode.group;
      if (widget.groupMembers.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadGroupMembers(_selectedGroupId!);
        });
      }
    }
  }

  Future<void> _loadGroupMembers(String groupId) async {
    final groupRepo = sl<GroupRepository>();
    final getMemberDetails = sl<GetGroupMemberDetailsUseCase>();

    final groupResult = await groupRepo.getGroupDetails(groupId);
    groupResult.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load group: ${failure.toString()}'),
            ),
          );
        }
      },
      (group) async {
        setState(() {
          _selectedGroup = group;
        });

        final membersResult = await getMemberDetails(group.members);
        membersResult.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to load members: ${failure.toString()}',
                  ),
                ),
              );
            }
          },
          (users) {
            if (mounted) {
              setState(() {
                _memberDetails = {for (var u in users) u.id: u};
                // Pre-select current user as payer if part of group
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null &&
                    group.members.contains(currentUser.uid)) {
                  _selectedPayerId = currentUser.uid;
                } else if (users.isNotEmpty) {
                  _selectedPayerId = users.first.id;
                }

                // Default: select all group members
                _selectedMembers.clear();
                _selectedMembers.addAll(group.members);
              });
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return BlocProvider(
      create: (context) {
        final bloc = sl<GroupListBloc>();
        if (user != null) {
          bloc.add(LoadGroupsEvent(userId: user.uid));
        }
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Review Transactions')),
        body: Column(
          children: [
            // Top Section: Toggle & Stats
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Toggle moved to body as requested
                  SegmentedButton<ScanTargetMode>(
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
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Items',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.scannedTransactions.length}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total Amount',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyUtil.format(_calculateTotalAmount()),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_mode == ScanTargetMode.group) ...[
                    _buildGroupSelectors(theme),
                    const SizedBox(height: 24),
                  ],

                  Text(
                    'Transactions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (widget.scannedTransactions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No transactions found.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                    )
                  else
                    ...widget.scannedTransactions.map((scanned) {
                      // Convert to Entity for display
                      final entity = _mapToEntity(scanned);
                      // We wrap in a block to ensure no tap edits
                      return AbsorbPointer(
                        absorbing: true,
                        child: TransactionItem(transaction: entity),
                      );
                    }),
                ],
              ),
            ),

            // Bottom Action Bar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: () => _onSave(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Text(
                    _mode == ScanTargetMode.personal
                        ? 'Add all to personal expenses'
                        : 'Add all to group expenses',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotalAmount() {
    return widget.scannedTransactions.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );
  }

  TransactionEntity _mapToEntity(ScannedTransaction scanned) {
    return TransactionEntity(
      id: 'preview', // Dummy ID for preview
      userId: 'preview_user',
      amount: scanned.amount,
      currency: 'VND', // Default or detected
      type: 'expense',
      date: scanned.date,
      categoryId: 'uncategorized',
      categoryName: scanned.category.isNotEmpty
          ? scanned.category
          : 'Unclassified',
      categoryIcon: '🧾',
      note: scanned.description,
      searchKeywords: const [],
      status: 'draft',
      createdAt: DateTime.now(),
    );
  }

  Widget _buildGroupSelectors(ThemeData theme) {
    return BlocBuilder<GroupListBloc, GroupListState>(
      builder: (context, state) {
        List<GroupEntity> groups = [];
        if (state is GroupListLoaded) {
          groups = state.groups;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Selection
            Text(
              'Group Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                if (groups.isNotEmpty) {
                  _showGroupSelectionSheet(context, groups);
                } else if (state is GroupListLoading) {
                  // Do nothing
                } else {
                  // Try fetching? or show msg
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No groups found')),
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Selected Group',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.groups_3_outlined),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  _selectedGroup?.name ?? 'Select a group',
                  style: theme.textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Only show members if group is selected
            if (_selectedGroup != null) ...[
              // Payer
              Text('Paid By', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              if (_memberDetails.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _memberDetails.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final memberId = _memberDetails.keys.elementAt(index);
                      final user = _memberDetails[memberId];
                      final isSelected = _selectedPayerId == memberId;
                      return ChoiceChip(
                        label: Text(user?.name ?? 'Unknown'),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedPayerId = memberId);
                          }
                        },
                        avatar: user?.avatarUrl != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(user!.avatarUrl!),
                              )
                            : null,
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),
              // Split
              Text('Split Between', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              if (_memberDetails.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _memberDetails.entries.map((entry) {
                    final memberId = entry.key;
                    final user = entry.value;
                    final isSelected = _selectedMembers.contains(memberId);
                    return FilterChip(
                      label: Text(user.name ?? user.email),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedMembers.add(memberId);
                          } else {
                            _selectedMembers.remove(memberId);
                          }
                        });
                      },
                      avatar: user.avatarUrl != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(user.avatarUrl!),
                            )
                          : null,
                    );
                  }).toList(),
                ),
            ],
          ],
        );
      },
    );
  }

  void _showGroupSelectionSheet(
    BuildContext context,
    List<GroupEntity> groups,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            final isSelected = group.id == _selectedGroupId;
            return ListTile(
              leading: CircleAvatar(
                child: Text(
                  group.name.isNotEmpty ? group.name[0].toUpperCase() : '?',
                ),
              ),
              title: Text(group.name),
              subtitle: Text('${group.members.length} members'),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  _selectedGroupId = group.id;
                  _selectedGroup = group;
                  _selectedMembers.clear();
                  _selectedPayerId = null;
                  _memberDetails.clear();
                });
                _loadGroupMembers(group.id);
                Navigator.pop(sheetContext);
              },
            );
          },
        );
      },
    );
  }

  void _onSave(BuildContext context) {
    if (widget.scannedTransactions.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No items to save')));
      return;
    }

    if (_mode == ScanTargetMode.personal) {
      _saveToPersonal(context);
    } else {
      _saveToGroup(context);
    }
  }

  Future<void> _saveToPersonal(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in to save')));
      return;
    }

    final userId = authState.user.id;
    final repo = sl<PersonalExpensesRepository>();
    final now = DateTime.now();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    int successCount = 0;
    try {
      for (final s in widget.scannedTransactions) {
        final tx = TransactionEntity(
          id: const Uuid().v4(), // Generate ID
          userId: userId,
          amount: s.amount,
          currency: 'VND',
          type: 'expense',
          date: s.date,
          categoryId: 'uncategorized',
          categoryName: s.category.isNotEmpty ? s.category : 'Unclassified',
          categoryIcon: '🧾',
          note: s.description,
          searchKeywords: const [],
          status: 'confirmed', // Auto-confirm
          imageUrl: null,
          createdAt: now,
        );
        await repo.addTransaction(tx);
        successCount++;
      }

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved $successCount transactions successfully'),
          ),
        );
        // Navigate to Personal Expenses (Main Screen)
        context.go('/app');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    }
  }

  Future<void> _saveToGroup(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_selectedGroupId == null || _selectedGroup == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a group')));
      return;
    }

    if (_selectedPayerId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a payer')));
      return;
    }

    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select participants')),
      );
      return;
    }

    final addGroupTransaction = sl<AddGroupTransactionUseCase>();
    final evenSplitter = _EvenSplitHelper(members: _selectedMembers.toList());

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    int successCount = 0;
    try {
      for (final s in widget.scannedTransactions) {
        final splitDetails = evenSplitter.split(s.amount);

        final tx = TransactionEntity(
          id: const Uuid().v4(),
          userId: user.uid,
          amount: s.amount,
          currency: 'VND',
          type: 'expense',
          date: s.date,
          categoryId: 'uncategorized',
          categoryName: s.category.isNotEmpty ? s.category : 'Unclassified',
          categoryIcon: '🧾',
          note: s.description,
          searchKeywords: const [],
          status: 'confirmed',
          createdAt: DateTime.now(),
          groupId: _selectedGroupId,
          groupName: _selectedGroup!.name,
          payerId: _selectedPayerId,
          participants: _selectedMembers.toList(),
          splitDetails: splitDetails,
        );

        final result = await addGroupTransaction(
          AddGroupTransactionParams(
            groupId: _selectedGroupId!,
            transaction: tx,
          ),
        );

        if (result.isRight()) {
          successCount++;
        }
      }

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved $successCount group transactions')),
        );
        // Navigate to Group Detail
        context.pushReplacementNamed(
          'group_detail',
          pathParameters: {'groupId': _selectedGroupId!},
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    }
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
